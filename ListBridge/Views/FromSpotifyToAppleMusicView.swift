//
//  FromSpotifyToAppleMusicView.swift
//  ListBridge
//
//  Created by Anıl Aygün on 30.10.2025.
//

import SwiftUI

struct FromSpotifyToAppleMusicView: View {
    @State private var playlistURL: String = ""
    @State private var showPlaylists: Bool = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        Image("spotify_icon")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color.white)
                    }
                    
                    Text("Choose a method to start the transfer")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Transfer with Playlist URL", systemImage: "link")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Paste Spotify playlist URL here", text: $playlistURL)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 4)
                        
                        Button(action: {
                            
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Transfer with URL")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(playlistURL.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(playlistURL.isEmpty)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    
                    HStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("or")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 8)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Choose from My Playlists", systemImage: "music.note.list")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            showPlaylists = true
                        }) {
                            HStack {
                                Image(systemName: "square.stack.3d.down.right.fill")
                                Text("Show My Spotify Playlists")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.11, green: 0.73, blue: 0.33))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("Transfer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FromSpotifyToAppleMusicView()
    }
}
