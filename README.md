# PrismaSimpleImagePicker


![Logo](https://github.com/Roylee-ML/PrismaSimpleImagePicker/blob/master/ScreenShots/logo.png)


Custom camera, image picker ,image editor and the interface just like Prisma's style.


# Overview

<img src="https://github.com/Roylee-ML/PrismaSimpleImagePicker/blob/master/ScreenShots/screenshot1.gif" width = "272" height = "480" alt="OverView1" align=center />
<img src="https://github.com/Roylee-ML/PrismaSimpleImagePicker/blob/master/ScreenShots/screenshot2.gif" width = "272" height = "480" alt="OverView2" align=center />
<img src="https://github.com/Roylee-ML/PrismaSimpleImagePicker/blob/master/ScreenShots/screenshot3.gif" width = "272" height = "480" alt="OverView3" align=center />



# Introduction

### This is just a client function copy of Prisma, not a pod solution

Prisma is a sucessful APP of photo editing, but it's success is more than just art. And the details of the Prisma is also very good. So, I try to reproduce the client function of Prisma use Swift, and the result is this project.

This is build with Storyboard and xib, just because the Prisma is also used Storyboard and xib. The follow is the struct:

![Struct](https://github.com/Roylee-ML/PrismaSimpleImagePicker/blob/master/ScreenShots/prismanib.png)


### What is the use of this project?

**Firstly**, we can learn how to custom camera use framework AVFoundation.

> * **AVCaptureSession**  A session to manage camera, responsible for the video image management function
> * **AVCaptureDeviceInput**  Do the image acquisition
> * **AVCaptureStillImageOutput** Function for image stream output
> * **AVCaptureVideoPreviewLayer** Video preview layer, used to display the scene of the camera in real time

There is one thing we need to pay attention when we custom a camera, it's the image's orientation. Because the normal orientation of iPhone camera is lanscape left(Home button on the right), so the image orientation is different from our expected result. Below is a comparison.

![Camera position](https://github.com/Roylee-ML/PrismaSimpleImagePicker/blob/master/ScreenShots/possion.png) 


**Secondly**, from this project we can learn about some kowledge of system photo album. Because just support iOS8 above, so I use framework Photos to complete photo select, not the AssetsLibrary frmawork Prisma used. And below is the frameworks Prisma used.

![Frameworks](https://github.com/Roylee-ML/PrismaSimpleImagePicker/blob/master/ScreenShots/frameworks.png)


**Finally**, we could just use the image picker in foder `PrismaImagePicker`, this is an independent function for developer jsut want to have a image picker with Prisma's syle.

**More details, please view my [blog](http://error408.com/2016/08/03/Prisma-%E6%88%90%E5%8A%9F%E7%9A%84%E4%B8%8D%E5%8F%AA%E6%98%AF%E8%89%BA%E6%9C%AF/)(*Only Chinese supported*)**



### How to use PrismaImagePicker?

* Create an object of class `PMImagePickerController`, and just present it from your own view controller.
* If you just have the data source before, you can set the data source of `PMImagePickerController`, so it can be fast because without read the photo album.
* Conform to protocol `PMImagePickerControllerDelegate`, and implement the delegate used.

The PMImagePickerControllerDelegate

```swift
@objc protocol PMImagePickerControllerDelegate: NSObjectProtocol {
    /**
     Call when tap `Use` button of the picker view controller
     
     - parameter picker: The view controller of class PMImagePickerController
     - parameter image:  An cropped image which displayed in the top header after edit
     */
    optional func imagePickerController(picker: PMImagePickerController, didFinishPickingImage image: UIImage)
    
    /**
     Call when tap `Use` button of the picker view controller
     
     - parameter picker:        The view controller of class PMImagePickerController
     - parameter originalImage: An original image which displayed in the top header
     - parameter selectedRect:  A rect displayed of the header
     - parameter zoomScale:     ZoomScale of the image
     */
    optional func imagePickerController(picker: PMImagePickerController, didFinishPickingImage originalImage: UIImage, selectedRect: CGRect, zoomScale:CGFloat)
    
    /**
     Call when tap `Cancel` button of the picker view controller
     
     - parameter picker: The view controller of class PMImagePickerController
     */
    optional func imagePickerControllerDidCancel(picker: PMImagePickerController)
}
```

<br>
Create and use the iamge picker

```swift
// Create image picker
@IBAction func selectPhoto(sender: AnyObject) {
    let nav = PMImagePickerController.init()
    nav.pmDelegate = self
    nav.photoGroups = photoGroups
    nav.photoAssets = photoAssets
    weak var weakSelf = self
    self.presentViewController(nav, animated: true) {
        weakSelf!.session.stopRunning()
    }
}


// PMImagePickerControllerDelegate
func imagePickerController(picker: PMImagePickerController, didFinishPickingImage originalImage: UIImage, selectedRect: CGRect, zoomScale:CGFloat) {
    // Do something with the original image
    ...
}
    
func imagePickerController(picker: PMImagePickerController, didFinishPickingImage image: UIImage) {
    // Dow something with the cropped image
    ...
}

func imagePickerControllerDidCancel(picker: PMImagePickerController) {
    session.startRunning()
}
```

<br>
**Custom your own album kind**

The default album is `Camera`、`Favorites`、`ScreenShots` and `User photos`, and all the operations of image is in `PMImageManger.swift`. 

If you want change the kind of album, you could change the parameters `PHAssetCollectionType` and `PHAssetCollectionSubtype` in function `class func photoLibrarys() -> [PHAssetCollection]`


# License

PrismaSimpleImagePicker is available under the MIT license. See the LICENSE file for more info.
