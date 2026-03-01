import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()                
                CheckerboardPattern()
                    .opacity(0.35)
                
                GeometryReader { geometry in
                    ZStack {
                        MusicNoteSymbol()
                            .foregroundColor(AppColors.lightPurple.opacity(0.5))
                            .frame(width: 75, height: 85)
                            .position(x: geometry.size.width * 0.12, y: geometry.size.height * 0.2)
                            .rotationEffect(.degrees(-20))
                        
                        MusicNoteSymbol()
                            .foregroundColor(AppColors.lightPurple.opacity(0.5))
                            .frame(width: 70, height: 70)
                            .position(x: geometry.size.width * 0.88, y: geometry.size.height * 0.28)
                            .rotationEffect(.degrees(25))                    
                        
                        MusicNoteSymbol()
                            .foregroundColor(AppColors.lightPurple.opacity(0.5))
                            .frame(width: 85, height: 85)
                            .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.7)
                            .rotationEffect(.degrees(15))
                        
                        MusicNoteSymbol()
                            .foregroundColor(AppColors.lightPurple.opacity(0.5))
                            .frame(width: 50, height: 100)
                            .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.85)
                            .rotationEffect(.degrees(5))
                        
                        MusicNoteSymbol()
                            .foregroundColor(AppColors.lightPurple.opacity(0.5))
                            .frame(width: 50, height: 100)
                            .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.15)
                            .rotationEffect(.degrees(20))
                        
                        MusicNoteSymbol()
                            .foregroundColor(AppColors.lightPurple.opacity(0.5))
                            .frame(width: 50, height: 100)
                            .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.6)
                            .rotationEffect(.degrees(-250))
                    }
                }
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Text("Music That Moves With You.")
                            .font(.system(size: 50, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.primaryPurple)
                        
                        Text("play your favorites")
                            .font(.system(size: 45, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.primaryPurple.opacity(0.7))
                    }
                    
                    Spacer()
                        .frame(height: 40)
                    
                    Text("Dextera")
                        .font(.system(size: 150, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.accentPurple)
                        .tracking(1)
                    
                    Spacer()
                        .frame(height: 50)
                    
                    HStack(spacing: 40) {
                        NavigationLink(destination: PlaySong()) {
                            HStack(spacing: 10) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 35, weight: .semibold, design: .rounded))
                                Text("  play new song")
                                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: 300)
                            .padding(.vertical, 26)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(AppColors.accentPurple)
                            )
                        }
                        
                        NavigationLink(destination: FreePlay()) {
                            HStack(spacing: 10) {
                                Image(systemName: "music.note")
                                    .font(.system(size: 35, weight: .semibold, design: .rounded))
                                Text(" play without notes")
                                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(AppColors.accentPurple)
                            .frame(maxWidth: 300)
                            .padding(.vertical, 26)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(AppColors.accentPurple.opacity(0.3), lineWidth: 1.5)
                                    )
                            )
                        }
                    }
                    
                    Spacer()
                    Spacer()
                        .frame(height: 20)
                }
                .padding(.horizontal, 24)
                
                VStack {
                    Spacer()
                    BottomNavBar()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MusicNoteSymbol: View {
    var body: some View {
        Image(systemName: "music.note")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct CheckerboardPattern: View {
    var body: some View {
        GeometryReader { geometry in
            let stripeHeight: CGFloat = 2
            let spacing: CGFloat = 24
            
            Canvas { context, size in
                let numStripes = Int(size.height / spacing) + 1
                
                for i in 0..<numStripes {
                    let y = CGFloat(i) * spacing
                    let rect = CGRect(x: 0, y: y, width: size.width, height: stripeHeight)
                    context.fill(Path(rect), with: .color(AppColors.lightPurple.opacity(0.35)))
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
