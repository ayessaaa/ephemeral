//
//  ContentView.swift
//  ephemeral
//
//  Created by yessa on 4/15/26.
//

import AVFoundation
import AVKit
import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    var body: some View {
        ZStack {
            if cameraManager.authorizationStatus == .authorized {
                CameraPreview(session: cameraManager.session).ignoresSafeArea()
            } else {
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.gray)
                    Text("Camera Access Required")
                        .font(.title)
                        .foregroundStyle(Color.gray)

                    if cameraManager.authorizationStatus == .denied {
                        Text("Please enable camera in settings")

                        Button("Open settings") {
                            if let settingsURL = URL(
                                string: UIApplication.openSettingsURLString
                            ) {
                                UIApplication.shared.open(settingsURL)
                            }
                        }
                    }
                }
            }
        }
        .onAppear{
            cameraManager.checkAuthorization()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
