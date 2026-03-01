import SwiftUI

struct StaffNote: Identifiable {
    let id = UUID()
    let noteIndex: Int
    let xFraction: CGFloat
}

func staffNoteY(index: Int, staffBottom: CGFloat, halfStep: CGFloat) -> CGFloat {
    let ls = halfStep * 2.0
    switch index {
    case 0:  return staffBottom + halfStep
    case 1:  return staffBottom + halfStep * 0.5
    case 2:  return staffBottom
    case 3:  return staffBottom - halfStep
    case 4:  return staffBottom - ls
    case 5:  return staffBottom - ls - halfStep
    case 6:  return staffBottom - ls * 2
    case 7:  return staffBottom - ls * 2 - halfStep
    default: return staffBottom
    }
}

struct SmallStaffNoteView: View {
    let noteIndex: Int
    let color: Color
    let halfStep: CGFloat
    
    private var headW: CGFloat  { halfStep * 1.4 }
    private var headH: CGFloat  { halfStep * 1.0 }
    private var stemLen: CGFloat { halfStep * 3.0 }
    private var stemThk: CGFloat { max(1.5, halfStep * 0.20) }
    private var stemUp: Bool    { noteIndex < 6 }
    
    var body: some View {
        ZStack {
            if noteIndex == 0 {
                Rectangle()
                    .fill(AppColors.primaryPurple.opacity(0.5))
                    .frame(width: headW * 1.8, height: max(1.2, halfStep * 0.15))
            }
            
            Ellipse()
                .fill(color)
                .frame(width: headW, height: headH)
                .shadow(color: color.opacity(0.35), radius: 2, x: 0, y: 1)
            
            let stemOffX: CGFloat = stemUp ?  (headW * 0.42) : -(headW * 0.42)
            let stemOffY: CGFloat = stemUp ? -(stemLen / 2.0 + headH * 0.08)
                :  (stemLen / 2.0 + headH * 0.08)
            Rectangle()
                .fill(color)
                .frame(width: stemThk, height: stemLen)
                .offset(x: stemOffX, y: stemOffY)
        }
    }
}