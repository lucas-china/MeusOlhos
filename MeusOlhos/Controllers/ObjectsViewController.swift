//
//  ObjectsViewController.swift
//  MeusOlhos
//
//  Created by Lucas Santana Brito on 12/01/20.
//  Copyright © 2020 lsb.br. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ObjectsViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    lazy var captureManager: CaptureManager = {
       let captureManager = CaptureManager()
        captureManager.videoBufferDelegate = self
        return captureManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        identifierLabel.text = ""
        confidenceLabel.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let previewLayer = captureManager.startCaptureCamera() else { return }
        previewLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(previewLayer)
    }
    
    @IBAction func analyse(_ sender: UIButton) {
        guard let label = identifierLabel.text,
            let word = label.components(separatedBy: ", ").first,
            let confidence = confidenceLabel.text else { return }
       
        let text = "I am \(confidence) confident that this is a \(word)"
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice.init(language: "en-US")
        
        let syntheizer = AVSpeechSynthesizer()
        syntheizer.speak(utterance)
    }
    
}

extension ObjectsViewController: AVCaptureVideoDataOutputSampleBufferDelegate  {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else { return }
            for i in 0...5 {
                print(results[i].identifier, results[i].confidence)
            }
            print("===============================")
            
            guard let firstObservation = results.first else { return }
            DispatchQueue.main.async {
                self.identifierLabel.text = firstObservation.identifier
                let confidence = round(firstObservation.confidence * 1000) / 10
                self.confidenceLabel.text = String(format: "%.0f", confidence) + "%"
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
        
    }
}
