import SwiftUI
import UIKit

class BrightnessManager: ObservableObject {
    static let shared = BrightnessManager()
    @AppStorage("brightness") var currentBrightness: Double = 1.0 {
        didSet { applyBrightness() }
    }
    
    init() {
        if UserDefaults.standard.object(forKey: "brightness") == nil {
            currentBrightness = 1.0
        }
        applyBrightness()
    }
    
    func applyBrightness() {
        DispatchQueue.main.async {
            #if targetEnvironment(macCatalyst)
            #else
            UIScreen.main.brightness = CGFloat(self.currentBrightness)
            #endif
        }
    }
}
struct BrightnessModifier: ViewModifier {
    @ObservedObject private var manager = BrightnessManager.shared    
    private let neutral: Double = 0.55
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if manager.currentBrightness < neutral {
                let t = (neutral - manager.currentBrightness) / max(neutral - 0.1, 0.0001) 
                Color.black
                    .opacity(min(max(t, 0), 1) * 0.65)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear { manager.applyBrightness() }
        .onChange(of: manager.currentBrightness) { _, _ in
            manager.applyBrightness()
        }
    }
}

extension View {
    func applySavedBrightness() -> some View {
        modifier(BrightnessModifier())
    }
}
