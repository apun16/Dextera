import SwiftUI
import AVFoundation
import Vision

class HandCameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var detectedFingerIndex: Int? = nil
    @Published var handDetected: Bool = false
    @Published var fingerTipPositions: [CGPoint] = []
    @Published var fingerSegments: [FingerSegment] = []
    @Published var cameraAvailable: Bool = false
    @Published var permissionDenied: Bool = false
    
    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let handPoseRequest: VNDetectHumanHandPoseRequest = {
        let r = VNDetectHumanHandPoseRequest()
        r.maximumHandCount = 2
        return r
    }()
    
    private var lastTriggerTime: Date = .distantPast
    private var isSetup = false
    private let sessionQueue = DispatchQueue(label: "cam.q", qos: .userInteractive)
    
    private let jointConfidenceThreshold: Float = 0.6
    private let triggerCooldown: TimeInterval = 0.55    
    private let extensionFramesRequired: Int = 3
    private var extendedFrameCount: [Int: Int] = [:]
    override init() { super.init() }
    
    func requestAndStart() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            sessionQueue.async { self.setupSession() }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { self.sessionQueue.async { self.setupSession() } }
                else { DispatchQueue.main.async { self.permissionDenied = true } }
            }
        default:
            DispatchQueue.main.async { self.permissionDenied = true }
        }
    }
    
    private func setupSession() {
        guard !isSetup else {
            if !session.isRunning { session.startRunning() }
            return
        }
        isSetup = true
        session.beginConfiguration()
        session.sessionPreset = .vga640x480
        
        var captureDevice: AVCaptureDevice? =
            AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        if captureDevice == nil {
            let ds = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera, .builtInTrueDepthCamera],
                mediaType: .video, position: .unspecified)
            captureDevice = ds.devices.first
        }
        
        guard let device = captureDevice,
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration(); return
        }
        session.addInput(input)
        
        videoOutput.setSampleBufferDelegate(
            self, queue: DispatchQueue(label: "vision.q", qos: .userInteractive))
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        guard session.canAddOutput(videoOutput) else { session.commitConfiguration(); return }
        session.addOutput(videoOutput)
        
        if let conn = videoOutput.connection(with: .video) {
            if conn.isVideoRotationAngleSupported(90) { conn.videoRotationAngle = 90 }
            if conn.isVideoMirroringSupported { conn.isVideoMirrored = (device.position == .front) }
        }
        
        session.commitConfiguration()
        DispatchQueue.main.async { self.cameraAvailable = true }
        session.startRunning()
    }
    
    func stop() {
        sessionQueue.async { if self.session.isRunning { self.session.stopRunning() } }
        extendedFrameCount.removeAll()
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        try? handler.perform([handPoseRequest])
        
        guard let results = handPoseRequest.results, !results.isEmpty else {
            DispatchQueue.main.async {
                self.handDetected = false
                self.fingerTipPositions = []
                self.detectedFingerIndex = nil
                self.extendedFrameCount.removeAll()
            }
            return
        }
        processHands(results)
    }
    private func mappedKey(chirality: VNChirality, fingerIndex: Int) -> Int? {
        switch chirality {
        case .left:
            switch fingerIndex {
            case 0: return 0
            case 1: return 1
            case 2: return 2
            case 4: return 3
            default: return nil
            }
        case .right:
            switch fingerIndex {
            case 0: return 4
            case 1: return 5
            case 2: return 6
            case 4: return 7
            default: return nil
            }
        case .unknown:
            return nil
        @unknown default:
            return nil
        }
    }
    
    private func processHands(_ observations: [VNHumanHandPoseObservation]) {
        let tipJoints: [VNHumanHandPoseObservation.JointName] = [
            .thumbTip, .indexTip, .middleTip, .ringTip, .littleTip
        ]
        let pipJoints: [VNHumanHandPoseObservation.JointName] = [
            .thumbIP, .indexPIP, .middlePIP, .ringPIP, .littlePIP
        ]
        
        var allTips: [CGPoint] = []
        var segments: [FingerSegment] = []
        var triggeredKey: Int? = nil
        
        for obs in observations.prefix(2) {
            let chirality = obs.chirality
            for (fingerIndex, (tipJoint, pipJoint)) in zip(tipJoints, pipJoints).enumerated() {
                let isThumb = fingerIndex == 0
                let confThreshold: Float = isThumb ? 0.5 : jointConfidenceThreshold
                guard
                    let tip = try? obs.recognizedPoint(tipJoint), tip.confidence >= confThreshold,
                    let pip = try? obs.recognizedPoint(pipJoint), pip.confidence >= confThreshold
                else {
                    if let key = mappedKey(chirality: chirality, fingerIndex: fingerIndex) {
                        extendedFrameCount[key] = 0
                    }
                    continue
                }
                
                let extensionThreshold: CGFloat = isThumb ? 0.05 : 0.08
                let isExtended = tip.location.y > pip.location.y + extensionThreshold
                let uiPt = CGPoint(x: tip.location.x, y: 1.0 - tip.location.y)
                allTips.append(uiPt)
                
                let pipPt = CGPoint(x: pip.location.x, y: 1.0 - pip.location.y)
                segments.append(FingerSegment(
                    chirality: chirality,
                    fingerIndex: fingerIndex,
                    pip: pipPt,
                    tip: uiPt,
                    isExtended: isExtended
                ))
                
                if let key = mappedKey(chirality: chirality, fingerIndex: fingerIndex) {
                    if isExtended {
                        let count = (extendedFrameCount[key] ?? 0) + 1
                        extendedFrameCount[key] = count
                        if count >= extensionFramesRequired {
                            triggeredKey = key
                        }
                    } else {
                        extendedFrameCount[key] = 0
                    }
                }
            }
        }
        
        let now = Date()
        let canTrigger = now.timeIntervalSince(lastTriggerTime) > triggerCooldown
        
        DispatchQueue.main.async {
            self.handDetected = true
            self.fingerTipPositions = allTips
            self.fingerSegments = segments
            if canTrigger, let key = triggeredKey {
                self.lastTriggerTime = now
                self.extendedFrameCount[key] = 0
                self.detectedFingerIndex = key
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.detectedFingerIndex = nil
                }
            }
        }
    }
}

struct FingerSegment: Identifiable, Equatable {
    let chirality: VNChirality
    let fingerIndex: Int
    let pip: CGPoint
    let tip: CGPoint
    let isExtended: Bool
    
    var id: String {
        let hand = (chirality == .right) ? "R" : (chirality == .left ? "L" : "U")
        return "\(hand)-\(fingerIndex)"
    }
}

struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> CameraPreviewUIView {
        let v = CameraPreviewUIView(); v.setSession(session); return v
    }
    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.setSession(session)
    }
}

final class CameraPreviewUIView: UIView {
    override static var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    func setSession(_ session: AVCaptureSession) {
        videoPreviewLayer.session = session
        videoPreviewLayer.videoGravity = .resizeAspectFill
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
    }
}
