//
//  ViewController.swift
//  Snapshot Protoype 1
//
//  Created by Benton Robertson on 2018-03-02.
//  Copyright © 2018 Snapshot. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var photoOuput: AVCapturePhotoOutput?
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    
    var overLayRotation = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeft = UISwipeGestureRecognizer(target:self, action: #selector (handleSwipe(gesture:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target:self, action: #selector (handleSwipe(gesture:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        //this adds the grid over lay
        addOverlay()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func handleSwipe (gesture: UISwipeGestureRecognizer){
        
        
        if gesture.direction == .left {
            
            overLayRotation = overLayRotation + 1
            print (overLayRotation)
            switch abs(overLayRotation % 3) {
            case 0:
                self.imageView.image = UIImage(named:"grid")
            case 1:
                self.imageView.image = UIImage(named: "peron_outline")
            case 2:
                self.imageView.image = UIImage(named: "mountain_outline")
            default:
                self.imageView.image = UIImage(named:"grid")
            }
        } else if gesture.direction == .right {
    
            overLayRotation = overLayRotation - 1
            print (overLayRotation)
            switch abs(overLayRotation % 3) {
            case 0:
                self.imageView.image = UIImage(named:"grid")
            case 1:
                self.imageView.image = UIImage(named: "peron_outline")
            case 2:
                self.imageView.image = UIImage(named: "mountain_outline")
            default:
                self.imageView.image = UIImage(named:"grid")
            }
        }
        
    }
    
    func setupCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    func setupDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        currentCamera = backCamera
    }
    func setupInputOutput(){
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOuput = AVCapturePhotoOutput()
            photoOuput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:
                [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOuput!)
        } catch {
            print(error)
        }
    }
    func setupPreviewLayer(){
        //set up basic preview layer for viewing photo before taken
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
    
    func addOverlay(){
        self.imageView.image = UIImage(named:"grid")
    }
    

    
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        //performSegue(withIdentifier: "showPhoto_Segue", sender: nil)
        let settings = AVCapturePhotoSettings()
        photoOuput?.capturePhoto(with: settings, delegate: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto_Segue" {
            let previewVC = segue.destination as! PreviewViewController
            previewVC.image = self.image
        }
    }

}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            print(imageData)
            image = UIImage(data: imageData)
            performSegue(withIdentifier: "showPhoto_Segue", sender: nil)
        }
    }
}

