//
//  PMRootViewController.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/24.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit

class PMRootViewController: UIViewController {

    
    @IBOutlet weak var captureHeaderView: UIView!
    var captureController: PNImageCaptureController?
    var photoHeaderView: PMPhotoHeaderView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add navigation 
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let baseNav = storyBoard.instantiateViewControllerWithIdentifier("mainNavigationController") as? PMNavigationController
        baseNav!.frameOrigin = CGPointMake(0, UIScreen.mainScreen().bounds.size.width)
        self.addChildViewController(baseNav!)
        view.addSubview(baseNav!.view)
        
        captureController = baseNav?.viewControllers.first as? PNImageCaptureController
        captureHeaderView.layer.masksToBounds = true
        
        photoHeaderView = PMPhotoHeaderView.init(frame: captureHeaderView.bounds)
        photoHeaderView?.hidden = true
        captureHeaderView.addSubview(photoHeaderView!)
    }
    
    override func viewDidLayoutSubviews() {
        photoHeaderView?.frame = captureHeaderView.bounds
    }
    
    override func viewDidAppear(animated: Bool) {
        // Preview
        if let previewLayer = captureController?.previewLayer {
            previewLayer.frame = captureHeaderView.bounds
            captureHeaderView.layer.insertSublayer(previewLayer, below: photoHeaderView?.layer)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
