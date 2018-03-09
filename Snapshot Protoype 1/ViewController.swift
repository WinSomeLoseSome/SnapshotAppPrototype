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
    var cameraDataOutput: AVCaptureVideoDataOutput?
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    
    var overLayRotation = 0
    enum overLayState {
        case mountain
        case portrait
        case grid
    }
    
    var overLay: overLayState = .grid
    
    //icons at bottom of screen
    @IBOutlet weak var portraitIcon: UIImageView!
    @IBOutlet weak var gridIcon: UIImageView!
    @IBOutlet weak var mountainIcon: UIImageView!
    
    
    //vars for brightness meter
    @IBOutlet weak var brightnessPointer: UIImageView!
    var pointerLocation: CGPoint = CGPoint(x: 0, y: 0)
    var timer = Timer()
    @IBOutlet weak var brightIcon: UIImageView!
    @IBOutlet weak var darkIcon: UIImageView!
    @IBOutlet weak var brightnessMeter: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add gesture to view
        let swipeLeft = UISwipeGestureRecognizer(target:self, action: #selector (handleSwipe(gesture:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target:self, action: #selector (handleSwipe(gesture:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        //set up camera
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        //setup default overlay (grid)
        defaultOverlay()
        
         timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(isoToBrightnessPercent), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func isoToBrightnessPercent () {
        let iso: Float = (currentCamera?.iso)!
        let max: Float = (currentCamera?.activeFormat.maxISO)!
        let min: Float = (currentCamera?.activeFormat.minISO)!
        
        let percentage: CGFloat = CGFloat((log2f(iso)-log2f(min))/(log2f(max)-log2f(min)) * 100)
        
        let x_coord: CGFloat = CGFloat(abs(percentage - 100) + 50)
        
        
        pointerLocation = CGPoint(x: x_coord, y: 50)
        
        brightnessPointer.center = pointerLocation
        //print (percentage)
    }
    
    
    @objc func handleSwipe (gesture: UISwipeGestureRecognizer){
        if gesture.direction == .left {
            overLayRotation = overLayRotation + 1
            print (overLayRotation)
            switch overLay {
            case .mountain:
                self.imageView.image = UIImage(named:"grid")
                self.gridIcon.image = UIImage (named:"grid_dark")
                self.portraitIcon.image = UIImage (named: "peron_outline")
                self.mountainIcon.image = UIImage (named: "mountain_outline")
                overLay = .grid
            case .grid:
                self.imageView.image = UIImage(named: "peron_outline")
                self.portraitIcon.image = UIImage (named: "person_dark")
                self.mountainIcon.image = UIImage (named: "mountain_outline")
                self.gridIcon.image = UIImage (named:"grid_icon")
                overLay = .portrait
            case .portrait:
                self.imageView.image = UIImage(named: "mountain_outline")
                self.mountainIcon.image = UIImage (named: "mountain_dark")
                self.portraitIcon.image = UIImage (named: "peron_outline")
                self.gridIcon.image = UIImage (named:"grid_icon")
                overLay = .mountain
            }
        } else if gesture.direction == .right {
    
            overLayRotation = overLayRotation - 1
            print (overLayRotation)
            switch overLay {
            case .portrait:
                self.imageView.image = UIImage(named:"grid")
                self.gridIcon.image = UIImage (named:"grid_dark")
                self.portraitIcon.image = UIImage (named: "peron_outline")
                self.mountainIcon.image = UIImage (named: "mountain_outline")
                overLay = .grid
            case .mountain:
                self.imageView.image = UIImage(named: "peron_outline")
                self.portraitIcon.image = UIImage (named: "person_dark")
                self.mountainIcon.image = UIImage (named: "mountain_outline")
                self.gridIcon.image = UIImage (named:"grid_icon")
                overLay = .portrait
            case .grid:
                self.imageView.image = UIImage(named: "mountain_outline")
                self.mountainIcon.image = UIImage (named: "mountain_dark")
                self.portraitIcon.image = UIImage (named: "peron_outline")
                self.gridIcon.image = UIImage (named:"grid_icon")
                overLay = .mountain
            default:
                self.imageView.image = UIImage(named:"grid")
                self.gridIcon.image = UIImage (named:"grid_dark")
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
    
    func defaultOverlay(){
        self.imageView.image = UIImage(named:"grid")
        
        self.brightnessPointer.image = UIImage (named: "Location_marker")
        self.brightIcon.image = UIImage(named: "sun")
        self.darkIcon.image = UIImage(named:"moon")
        self.brightnessMeter.image = UIImage(named: "bright_meter")
        
        self.portraitIcon.image = UIImage (named: "peron_outline")
        self.mountainIcon.image = UIImage (named: "mountain_outline")
        self.gridIcon.image = UIImage (named:"grid_dark")
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

