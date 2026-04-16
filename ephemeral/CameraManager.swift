//
//  CameraManager.swift
//  ephemeral
//
//  Created by yessa on 4/15/26.
//

import Foundation
import AVFoundation
import Combine
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    
    @Published var capturedImage: UIImage?
    @Published var isSessionRunning = false
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    
//    AVFoundation Components
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureMovieFileOutput()
    private var currentInput: AVCaptureDeviceInput?
    
    private let sessionQueue = DispatchQueue(label: "com.customcamera.sessionQueue")
    
    override init(){
        super.init( )
    }
    
    func checkAuthorization(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            authorizationStatus = .authorized
            setupSession()
        case .notDetermined:
            authorizationStatus = .notDetermined
            AVCaptureDevice.requestAccess(for: .video){[weak self] granted in
                DispatchQueue.main.async{
                    self?.authorizationStatus = granted ? .authorized : .denied
                    if granted {
                        self?.setupSession()
                    }
                }}
        case .denied, .restricted:
            authorizationStatus = .denied
            
        @unknown default:
            authorizationStatus = .denied
        }
    }
    
//    config AVSetup
    private func setupSession(){
        sessionQueue.async {
            [weak self] in
            guard let self = self else {return}
            
            // set session preset
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            
            // camera input
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front), let input = try? AVCaptureDeviceInput(device: camera) else {
                print("Failed to access camera")
                self.session.commitConfiguration()
                return
            }
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
                self.currentInput = input
            }
            
            // add photo output
            
            if self.session.canAddOutput(self.photoOutput){
                self.session.addOutput(self.photoOutput)
                
                self.photoOutput.isHighResolutionCaptureEnabled = true
                self.photoOutput.maxPhotoQualityPrioritization = .quality
            }
            
            self.session.commitConfiguration()
            
            // start session
            
            self.session.startRunning()
            DispatchQueue.main.async {
                self.isSessionRunning = self.session.isRunning
            }
        }
    }
}
