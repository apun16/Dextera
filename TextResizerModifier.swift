import SwiftUI

class TextSizeManager: ObservableObject {
    static let shared = TextSizeManager()
    
    @AppStorage("textSize") var currentSize: Double = 1.0 {
        didSet { objectWillChange.send() }
    }
    
    var multiplier: Double { currentSize }
    
    func size(_ base: CGFloat) -> CGFloat {
        base * CGFloat(currentSize)
    }
}

private struct TextSizeKey: EnvironmentKey {
    static let defaultValue: Double = 1.0
}

extension EnvironmentValues {
    var textSize: Double {
        get { self[TextSizeKey.self] }
        set { self[TextSizeKey.self] = newValue }
    }
}

struct ScaledText: ViewModifier {
    @AppStorage("textSize") private var textSize: Double = 1.0
    let baseSize: CGFloat
    let weight:   Font.Weight
    let design:   Font.Design
    
    func body(content: Content) -> some View {
        content.font(.system(
            size:   baseSize * CGFloat(textSize),
            weight: weight,
            design: design
        ))
    }
}

extension View {
    func scaledText(
        size:   CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design  = .rounded
    ) -> some View {
        modifier(ScaledText(baseSize: size, weight: weight, design: design))
    }
}
