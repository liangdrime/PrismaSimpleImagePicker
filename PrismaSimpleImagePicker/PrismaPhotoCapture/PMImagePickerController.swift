//
//  PMImagePickerController.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/24.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit
import Photos

@objc protocol PMImagePickerControllerDelegate: NSObjectProtocol {
    optional func imagePickerController(picker: PMImagePickerController, didFinishPickingImage image: UIImage)
    optional func imagePickerController(picker: PMImagePickerController, didFinishPickingImage originalImage: UIImage, selectedRect: CGRect)
    optional func imagePickerControllerDidCancel(picker: PMImagePickerController)
}

class PMImagePickerController: UINavigationController {
    
    private var _photoGroups: [PHAssetCollection]? = [PHAssetCollection]()
    private var _photoAssets: [PHAsset]? = [PHAsset]()
    weak var pmDelegate: PMImagePickerControllerDelegate?
    var photoGroups: [PHAssetCollection] {
        set {
            _photoGroups = newValue
            let rootVC = viewControllers[0] as? PMImageViewController
            rootVC?.photoGroups = newValue
        }
        get {
            return _photoGroups!
        }
    }
    var photoAssets: [PHAsset] {
        set {
            _photoAssets = newValue
            let rootVC = viewControllers[0] as? PMImageViewController
            rootVC?.photoAssets = newValue
        }
        get {
            return _photoAssets!
        }
    }
    
    init() {
        let rootVC = PMImageViewController(nibName: "PMImageViewController", bundle: nil)
        super.init(rootViewController: rootVC)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init navigation bar
        let bgImage = UIImage.imageWithColor(UIColor.whiteColor(), size: CGSizeMake(UIScreen.mainScreen().bounds.size.width, 44))
        navigationBar.tintColor = UIColor.blackColor()
        navigationBar.setBackgroundImage(bgImage, forBarPosition: UIBarPosition.Top, barMetrics: UIBarMetrics.Default)
        navigationBar.shadowImage = UIImage.init()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

