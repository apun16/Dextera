import SwiftUI

struct BottomNavBar: View {
    var body: some View {
        HStack(spacing: 0) {
            NavigationLink(destination: PlaySong()) {
                TabButtonContent(title: "new song", icon: "plus.circle")
            }
            
            NavigationLink(destination: FreePlay()) {
                TabButtonContent(title: "free play", icon: "play")
            }
            
            NavigationLink(destination: PastPractice()) {
                TabButtonContent(title: "past practice", icon: "clock.arrow.circlepath")
            }
            
            NavigationLink(destination: Learn()) {
                TabButtonContent(title: "learn", icon: "info.circle")
            }
            
            NavigationLink(destination: Settings()) {
                TabButtonContent(title: "settings", icon: "gearshape")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColors.lightPurple.ignoresSafeArea(edges: .bottom))
    }
}

struct TabButtonContent: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .medium, design: .rounded))
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
        }
        .foregroundColor(AppColors.primaryPurple)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title.capitalized)
        .accessibilityHint("Open \(title) tab")
        .accessibilityAddTraits(.isButton)
    }
}
