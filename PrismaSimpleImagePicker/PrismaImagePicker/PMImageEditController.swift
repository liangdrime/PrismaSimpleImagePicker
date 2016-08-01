//
//  PMImageEditController.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/24.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit

class PMImageEditController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setBackgroundImage(UIImage.init(), forBarPosition: UIBarPosition.Top, barMetrics: UIBarMetrics.Default)
        navigationBar.shadowImage = UIImage.init()
    }
    
    @IBAction func rotateRight(sender: AnyObject) {
        photoPisplayBoard?.rotateDisplayImage(true)
    }
    
    @IBAction func rotateLeft(sender: AnyObject) {
        photoPisplayBoard?.rotateDisplayImage(false)
    }
    
    @IBAction func next(sender: AnyObject) {
        let finalImage = photoPisplayBoard?.croppedImage()
        photoPisplayBoard?.setState(.SingleShow, image: finalImage, selectedRect: CGRectZero, animated: false)
        
        // Push to style vc
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let styleVC = storyBoard.instantiateViewControllerWithIdentifier("styleImageController") as? PMImageProcessController
        navigationController?.pushViewController(styleVC!, animated: true)
    }
    
    @IBAction func back(sender: AnyObject) {
        let navigationController = self.navigationController as? PMNavigationController
        navigationController?.popViewControllerAnimated(true, completion: { (isPush: Bool) in
            if !isPush {
                self.photoPisplayBoard?.setState(PMImageDisplayState.Preivew, image: nil, selectedRect: CGRectZero, animated: true)
            }
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        // Pop handle
        if navigationController == nil {
            self.photoPisplayBoard?.setState(PMImageDisplayState.Preivew, image: nil, selectedRect: CGRectZero, animated: true)
        }
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
