//
//  PMImageProcessController.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/24.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit

class PMImageProcessController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var stylesCollectionView: UICollectionView!
    var styles: [AnyObject]?
    
    var fromCapture: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage.init(), forBarPosition: UIBarPosition.Top, barMetrics: UIBarMetrics.Default)
        navigationBar.shadowImage = UIImage.init()
        
        let navigationController = self.navigationController as? PMNavigationController
        stylesCollectionView.panGestureRecognizer.requireGestureRecognizerToFail(navigationController!.panGestureRecognizer)
        
        styles = getStyles() as? [AnyObject]
    }
    
    func getStyles() -> AnyObject {
        let dataPath = NSBundle.mainBundle().pathForResource("", ofType: "json")
        let data = NSData.init(contentsOfFile: dataPath!)
        let dataDic: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)

        let styles: AnyObject = dataDic.objectForKey("styles")!
        return styles
    }
    
    @IBAction func back(sender: AnyObject) {
        let navigationController = self.navigationController as? PMNavigationController
        navigationController?.popViewControllerAnimated(true, completion: { (isPush: Bool) in
            if !isPush {
                let state = self.fromCapture ?PMImageDisplayState.Preivew:PMImageDisplayState.EditImage
                self.photoPisplayBoard?.setState(state, image: nil, selectedRect: CGRectZero, zoomScale:1, animated: true)
            }
        })
    }
    
    // MARK: UICollectionView M
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("styleCell", forIndexPath: indexPath) as? PMStyleCell
        
        let style: AnyObject = styles![indexPath.row]
        cell?.loadImage(style)
        
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("click item at \(indexPath.item)")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        // Pop handle
        if navigationController == nil {
            let state = fromCapture ?PMImageDisplayState.Preivew:PMImageDisplayState.EditImage
            self.photoPisplayBoard?.setState(state, image: nil, selectedRect: CGRectZero, zoomScale:1, animated: true)
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
