//
//  PNImageCaptureController.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/24.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import Photos
import CoreImage

class PNImageCaptureController: UIViewController {

    
    @IBOutlet weak var captureButton: PMCaptureButton!
    @IBOutlet weak var flashBarItem: UIBarButtonItem!
    @IBOutlet weak var selectPhotoButton: UIButton!
    var session: AVCaptureSession! = AVCaptureSession()
    var deviceIntput: AVCaptureDeviceInput?
    var stillImageOutPut: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoGroups = [PHAssetCollection]()
    var photoAssets = [PHAsset]()
    var isUsingFrontFacingCamera: Bool = false
    let screenSize = ScreenSize()
    let orientationManger: FMDeviceOrientation = FMDeviceOrientation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init view
        initNavigationBar()
        
        // Auth
        PMImageManger.captureAuthorization { (canCapture: Bool) in
            if canCapture {
                self.initAVCapture()
//                self.session.startRunning()
            }else {
//                self.session.stopRunning()
            }
        }
        
        PMImageManger.photoAuthorization { (canAssets: Bool) in
            if canAssets {
                self.photoGroups = PMImageManger.photoLibrarys()
                self.photoAssets = PMImageManger.photoAssetsForAlbum(self.photoGroups.first!)
                PMImageManger.imageFromAsset(self.photoAssets.first!, isOriginal: false, toSize: CGSizeMake(150, 150), resultHandler: { (image: UIImage?) in
                    self.selectPhotoButton.setBackgroundImage(image, forState: .Normal)
                })
            }
        }
    }
    
    func initNavigationBar() {
        // Camera possion
        let image = UIImage.init(named: "flip")
        let hImage = image?.imageWithColor(UIColor.lightGrayColor())
        let titleButton = UIButton.init(type: UIButtonType.Custom)
        titleButton.setImage(image, forState: UIControlState.Normal)
        titleButton.setImage(hImage, forState: UIControlState.Selected)
        titleButton.setImage(hImage, forState: UIControlState.Highlighted)
        titleButton.sizeToFit()
        titleButton.addTarget(self, action: #selector(self.changeCameraPossion), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.titleView = titleButton
    }
    
    func initAVCapture() {
        // Device
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        try! device.lockForConfiguration()
        if device.hasFlash {
            device.flashMode = AVCaptureFlashMode.Off
        }
        if device.isFocusModeSupported(.AutoFocus) {
            device.focusMode = .ContinuousAutoFocus
        }
        if device.isWhiteBalanceModeSupported(.AutoWhiteBalance) {
            device.whiteBalanceMode = .AutoWhiteBalance
        }
        device.unlockForConfiguration()
        
        // Input & Output
        // When init AVCaptureDeviceInput first, system will show alert to confirm the authentication from user.
        // But the best way is send the acces request manual. see `requestAccessForMediaType`
        deviceIntput = try! AVCaptureDeviceInput(device: device)
        stillImageOutPut = AVCaptureStillImageOutput()
        
        // Output settings
        stillImageOutPut?.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG, AVVideoScalingModeKey:AVVideoScalingModeResize]
        
        if session.canAddInput(deviceIntput) {
            session.addInput(deviceIntput)
        }
        if session.canAddOutput(stillImageOutPut) {
            session.addOutput(stillImageOutPut)
        }
        
        session.sessionPreset = AVCaptureSessionPresetPhoto
        // Preview
        previewLayer = AVCaptureVideoPreviewLayer.init(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
    }
    
    // MARK: Capture action
    
    @IBAction func capturePhoto(sender: AnyObject) {
//        return
        let stillImageConnection = stillImageOutPut?.connectionWithMediaType(AVMediaTypeVideo)
        let curDeviceOrientation = UIDevice.currentDevice().orientation
        let avCaptureOrientation = FMDeviceOrientation.avOrientationFromDeviceOrientation(curDeviceOrientation)
        if stillImageConnection!.supportsVideoOrientation {
            stillImageConnection!.videoOrientation = avCaptureOrientation
        }
        stillImageConnection!.videoScaleAndCropFactor = 1
        
        stillImageOutPut?.captureStillImageAsynchronouslyFromConnection(stillImageConnection, completionHandler: { (imageDataSampleBuffer: CMSampleBufferRef!, error: NSError!) in
            let jpegData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
            let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,imageDataSampleBuffer,kCMAttachmentMode_ShouldPropagate)
//            let attachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, nil)
            
            if var image = UIImage(data: jpegData) {
                
                // Fix orientation & crop image
                image = image.fixOrientation()
                image = PMImageManger.cropImage(image,toSize: self.previewLayer!.frame.size)
                
                // Fix interface orientation
                if !self.orientationManger.deviceOrientationMatchesInterfaceOrientation() {
                    let interfaceOrientation = self.orientationManger.orientation()
                    image = image.rotateImageFromInterfaceOrientation(interfaceOrientation)
                }
                
                // Mirror the image
                if self.isUsingFrontFacingCamera {
                    image = UIImage.init(CGImage: image.CGImage!, scale: image.scale, orientation: UIImageOrientation.UpMirrored)
                }
                
                // Save photo
                let authorStatus = ALAssetsLibrary.authorizationStatus()
                if  authorStatus == ALAuthorizationStatus.Restricted || authorStatus == ALAuthorizationStatus.Denied {
                    return
                }
                
                let library = ALAssetsLibrary()
                
                library.writeImageToSavedPhotosAlbum(image.CGImage!, metadata: attachments as? [NSObject:AnyObject] , completionBlock: { (url: NSURL!, error: NSError!) in
                    
                })
            }
            
        })
        
        // Disable the capture button and stop previewlayer
        captureButton.enabled = false
        session.stopRunning()
    }
    
    func changeCameraPossion() {
        var desiredPosition : AVCaptureDevicePosition?
        if (isUsingFrontFacingCamera){
            desiredPosition = AVCaptureDevicePosition.Back
        }else{
            desiredPosition = AVCaptureDevicePosition.Front
        }
        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
            let device = device as! AVCaptureDevice
            if device.position == desiredPosition {
                // Config device
                try! device.lockForConfiguration()
                if device.hasFlash {
                    device.flashMode = AVCaptureFlashMode.Off
                }
                if device.isFocusModeSupported(.AutoFocus) {
                    device.focusMode = .ContinuousAutoFocus
                }
                if device.isWhiteBalanceModeSupported(.AutoWhiteBalance) {
                    device.whiteBalanceMode = .AutoWhiteBalance
                }
                device.unlockForConfiguration()
                // Add device
                let input = try! AVCaptureDeviceInput(device: device)
                session.removeInput(deviceIntput)
                session.addInput(input)
                deviceIntput = input
                break;
            }
        }
        
        isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
    }
    
    @IBAction func selectPhoto(sender: AnyObject) {
        let nav = PMImagePickerController.init()
        nav.photoGroups = photoGroups
        nav.photoAssets = photoAssets
        self.presentViewController(nav, animated: true) {
            
        }
    }
    
    @IBAction func changeFlash(sender: AnyObject) {
        var image: UIImage? = nil
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        try! device.lockForConfiguration()
        if device.hasFlash {
            switch device.flashMode {
            case .Off:
                device.flashMode = .On
                image = UIImage.init(named: "flash-on")
                break
            case .On:
                device.flashMode = .Auto
                image = UIImage.init(named: "flash-auto")
                break
            case .Auto:
                device.flashMode = .Off
                image = UIImage.init(named: "flash")
                break
            }
            // Flash baritem
            navigationItem.leftBarButtonItem?.image = image
        }
        device.unlockForConfiguration()
    }
    
    @IBAction func setting(sender: AnyObject) {
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        session.startRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
