//
//  AuthView.swift
//  ListBridge
//
//  Created by Anıl Aygün on 20.09.2025.
//

import SwiftUI
import WebKit

struct AuthView: View {
    @StateObject var appleMusicController = AppleMusicAuthController()
    @StateObject var spotifyController = SpotifyAuthController()
    @State var openSpotifyLoginPage: Bool = false
    
    var bothAuthorized: Bool {
        spotifyController.isAuthorized && appleMusicController.isAuthorized
    }
    
    var body: some View {
        NavigationStack {
            ZStack{
            if openSpotifyLoginPage, let loginURL = spotifyController.loginSpotifyLink {
                WebView(url: URL(string: loginURL)!, openSpotifyLoginPage: $openSpotifyLoginPage,spotifyController: spotifyController)
                    .ignoresSafeArea(.keyboard)
                    .ignoresSafeArea(.container, edges: .bottom)
            }
            else{
                  VStack(alignment: .center, spacing: 16){
                        Button(action:{
                             
                              guard !spotifyController.isAuthorized else { return }
                              
                              Task{
                                    try await spotifyController.authorizeSpotify()
                                    spotifyController.canOpenWebSpotify = true
                                    openSpotifyLoginPage = true
                              }}
                        ){
                              HStack(spacing:12){
                                    Image("spotify_icon")
                                          .resizable()
                                          .frame(width: 20, height: 20)
                                          .padding()
                                    
                                  Text(spotifyController.isAuthorized ? "Connected to Spotify" : "Sign in with Spotify")
                                        .font(.system(size: 16, weight: .semibold))
                              }
                              .foregroundColor(.white)
                              .frame(maxWidth: 280)
                              .frame(height: 50)
                              .background(
                                    RoundedRectangle(cornerRadius: 25)
                                          .fill(Color(red: 0.11, green: 0.73, blue: 0.33)))
                              .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal, 12)
                        
                        Button(action:{
                              // Don't re-authenticate if already authorized
                              guard !appleMusicController.isAuthorized else { return }
                              
                              Task{
                                    try await appleMusicController.requestAuthorization()
                              }}
                        ){
                              HStack(spacing:12){
                                    Image(systemName:"apple.logo")
                                          .resizable()
                                          .frame(width: 20, height: 20)
                                          .padding()
                                    
                                    Text(appleMusicController.isAuthorized ? "Connected to Apple Music" : "Sign in with Apple Music")
                                        .font(.system(size: 16, weight: .semibold))
                                    
                              }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 280)
                        .frame(height: 50)
                        .background(
                              RoundedRectangle(cornerRadius: 25)
                                    .fill(Color(red: 0.98, green: 0.18, blue: 0.28)))
                        .shadow(color: Color.black.opacity(0.1),radius: 5,x: 0,y: 2)
                        
                  }
                  .padding()
              }
            }
            .navigationDestination(isPresented: .constant(bothAuthorized)) {
                TransferView(
                    spotifyController: spotifyController,
                    appleMusicController: appleMusicController
                )
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct WebView : UIViewRepresentable {
    
    let url : URL
    @Binding var openSpotifyLoginPage: Bool
    @ObservedObject var spotifyController : SpotifyAuthController
    
    func makeUIView(context: Context) -> WKWebView {
        
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.scrollView.keyboardDismissMode = .interactive
        webView.scrollView.bounces = true
        
       
        webView.setContentHuggingPriority(.defaultLow, for: .vertical)
        webView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self,spotifyController:spotifyController)
    }
    
    class Coordinator : NSObject, WKNavigationDelegate {
        var parent : WebView
        var spotifyController : SpotifyAuthController
        
        init(parent: WebView,spotifyController: SpotifyAuthController) {
            self.parent = parent
            self.spotifyController = spotifyController
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            guard let url = navigationAction.request.url else{
                decisionHandler(.cancel)
                return
            }
            
            if url.scheme == "listbridge" {
                    
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                       let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
                       let state = components.queryItems?.first(where: { $0.name == "state" })?.value {
                        
                        print("Spotify code: \(code)")
                        print("Spotify state: \(state)")
                        
                        
                        Task{
                            try await spotifyController.handleSpotifyCallback(code: code,state: state)
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.parent.openSpotifyLoginPage = false
                        }
                    }

                    decisionHandler(.cancel)
                    return
                }

                decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let urlString = webView.url?.absoluteString, urlString.contains("success") else {
                return
            }
            print("geridonenstring:"+urlString)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.parent.openSpotifyLoginPage = false
            }
        }
        
        func webViewDidClose(_ webView: WKWebView) {
            DispatchQueue.main.async {
                self.parent.openSpotifyLoginPage = false
            }
        }
    }
}

#Preview {
    AuthView()
}
