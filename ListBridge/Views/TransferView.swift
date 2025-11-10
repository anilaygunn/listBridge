//
//  TransferView.swift
//  ListBridge
//
//  Created by Anıl Aygün on 12.09.2025.
//

import SwiftUI

struct TransferView: View {
    @ObservedObject var spotifyController: SpotifyAuthController
    @ObservedObject var appleMusicController: AppleMusicAuthController
    
    // Direction state - true: Spotify->Apple, false: Apple->Spotify
    @State private var isSpotifyToAppleMusic = true
    @State private var shouldNavigate = false
    
    // Computed properties for dynamic content
    private var fromService: String {
        isSpotifyToAppleMusic ? "Spotify" : "Apple Music"
    }
    
    private var fromIcon: String {
        isSpotifyToAppleMusic ? "spotify_icon" : "apple.logo"
    }
    
    private var toService: String {
        isSpotifyToAppleMusic ? "Apple Music" : "Spotify"
    }
    
    private var toIcon: String {
        isSpotifyToAppleMusic ? "apple.logo" : "spotify_icon"
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isSpotifyToAppleMusic ? [
                Color(red: 0.11, green: 0.73, blue: 0.33),
                Color(red: 0.98, green: 0.26, blue: 0.4)
            ] : [
                Color(red: 0.98, green: 0.26, blue: 0.4),
                Color(red: 0.11, green: 0.73, blue: 0.33)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var destinationView: some View {
        Group {
            if isSpotifyToAppleMusic {
                FromSpotifyToAppleMusicView()
            } else {
                FromAppleMusicToSpotifyView()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    VStack(spacing: 12) {
                        Text("Transfer Your Music")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Choose your direction and go")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 60)

                    Spacer()
                    
                    VStack(spacing: 24) {
                        // Hidden NavigationLink
                        NavigationLink(
                            destination: destinationView,
                            isActive: $shouldNavigate
                        ) {
                            EmptyView()
                        }
                        
                        // Transfer Button
                        TransferButton(
                            fromService: fromService,
                            fromIcon: fromIcon,
                            toService: toService,
                            toIcon: toIcon,
                            gradient: gradient,
                            action: {
                                shouldNavigate = true
                            }
                        )
                        
                        // Change Direction Button
                        ChangeDirectionButton {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                isSpotifyToAppleMusic.toggle()
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
        }
    }
}

struct TransferButton: View {
    let fromService: String
    let fromIcon: String
    let toService: String
    let toIcon: String
    let gradient: LinearGradient
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                
                HStack(spacing: 12) {
                    if fromIcon == "spotify_icon" {
                        Image(fromIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: fromIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                    }
                    
                    Text(fromService)
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 24)
                
               
                Image(systemName: "arrow.right")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                
              
                HStack(spacing: 12) {
                    if toIcon == "spotify_icon" {
                        Image(toIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: toIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                    }
                    
                    Text(toService)
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 24)
            }
            .frame(height: 80)
            .background(gradient)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(TransferButtonStyle())
    }
}


struct TransferButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct ChangeDirectionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Change Direction")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.15),
                        Color.white.opacity(0.05)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
            )
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(TransferButtonStyle())
    }
}

#Preview {
    TransferView(
        spotifyController: SpotifyAuthController(),
        appleMusicController: AppleMusicAuthController()
    )
}

