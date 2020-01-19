//
//  CaptureManager.swift
//  MeusOlhos
//
//  Created by Lucas Santana Brito on 12/01/20.
//  Copyright © 2020 lsb.br. All rights reserved.
//

import Foundation
import AVKit

class CaptureManager {
    
    lazy var captureSession: AVCaptureSession = {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        return captureSession
    }()
    
    weak var videoBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    
    init() {
        
    }
    
    func startCaptureCamera() -> AVCaptureVideoPreviewLayer? {
        if askForPermission() {
            guard let captureDevice = AVCaptureDevice.default(for: .video) else { return nil }
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)
            } catch {
                print(error.localizedDescription)
            }
            captureSession.startRunning()
            
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(videoBufferDelegate, queue: DispatchQueue(label: "cameraQueue"))
            captureSession.addOutput(videoDataOutput)
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
            return previewLayer
            
        } else {
            return nil
        }
    }
    
    private func askForPermission() -> Bool {
        var hasPermission = true
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                hasPermission = true
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { (status) in
                    hasPermission = status
                }
            case .restricted, .denied:
                hasPermission = false
            default:
                hasPermission = false
        }
        
        return hasPermission
    }
}
