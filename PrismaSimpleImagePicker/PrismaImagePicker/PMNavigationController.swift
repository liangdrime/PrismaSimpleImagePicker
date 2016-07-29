//
//  PMNavigationController.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/24.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit

class PMNavigationController: UINavigationController {

    var frameOrigin: CGPoint = CGPointZero
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Config navigation bar
        navigationBar.barTintColor = UIColor.clearColor()
        navigationBar.setBackgroundImage(UIImage.init(), forBarPosition: UIBarPosition.Top, barMetrics: UIBarMetrics.Default)
        navigationBar.shadowImage = UIImage.init()
    }
    
    // MARK: Change the frame of the default view, under the capture view
    override func viewDidLayoutSubviews() {
        var frame = view.frame
        frame.origin.y = frameOrigin.y
        frame.size.height = UIScreen.mainScreen().bounds.size.height - frame.origin.y
        view.frame = frame
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
