import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var textOpacity = 0.0
    @State private var textScale = 0.8
    
    var body: some View {
        if isActive {
            AuthView()
        } else {
            ZStack {
               
                Color.black
                    .ignoresSafeArea()
                
               
                Image("bridge")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8, maxHeight: UIScreen.main.bounds.height * 0.6)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.11, green: 0.73, blue: 0.33),
                                Color(red: 0.98, green: 0.26, blue: 0.4)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(textOpacity)
                    .scaleEffect(textScale)
                    .animation(.easeOut(duration: 2.5), value: textOpacity)
                    .animation(.spring(response: 1.2, dampingFraction: 0.6), value: textScale)
            }
            .onAppear {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                textOpacity = 1.0
                textScale = 1.0
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                isActive = true
            }
        }
    }
}


#Preview {
    SplashView()
}
