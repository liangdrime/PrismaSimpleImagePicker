//
//  PMImageViewController.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/24.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

struct ScreenSize {
    let width: CGFloat = UIScreen.mainScreen().bounds.size.width
    let height: CGFloat = UIScreen.mainScreen().bounds.size.height
}

struct ConstParams {
    let headerTopInset: CGFloat = 44
    let minMoveDistance: CGFloat = 44
    let moveHeaderAnimationDuration: CFTimeInterval = 0.28
    let backHeaderAnimationDuration: CFTimeInterval = 0.15
    let presentGroupAnimationDuration: CFTimeInterval = 0.25
}

class PMImageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var dsiplayHeader: PMPhotoHeaderView!
    @IBOutlet weak var albumCollection: UICollectionView!
    @IBOutlet weak var headerTopConstraints: NSLayoutConstraint!
    private weak var pmNavigationController: PMImagePickerController? {
        get {
            return navigationController as? PMImagePickerController
        }
    }
    var titleButton: PMPickerTitleButton?
    let screenSize: ScreenSize = ScreenSize()
    let constParams: ConstParams = ConstParams()
    var photoGroups = [PHAssetCollection]?()
    var photoAssets = [PHAsset]?()
    var photos = [UIImage]()
    
    var shouldMoveHeaderUp: Bool = false
    var shouldMoveHeaderDown: Bool = false
    var isHeaderMoving: Bool = false
    var contentOffset: CGPoint = CGPointZero
    var selectedIndex: Int = 0
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        var nibNameOrNil = String?("PMImagePickerController")
        if NSBundle.mainBundle().pathForResource(nibNameOrNil, ofType: "xib") == nil {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        edgesForExtendedLayout = .None
        automaticallyAdjustsScrollViewInsets = false
        albumCollection.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        initNavigationBar()
        getPhotos()
        
        // Header tap action
        weak var weakSelf = self
        dsiplayHeader.tapAction = { (view: PMPhotoHeaderView) in
            weakSelf!.dropDownHeader(false)
        }
    }
    
    func initNavigationBar() {
        // Cancel button
        let leftBarItem = UIBarButtonItem.init(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PMImageViewController.cancel))
        // Confirm button
        let rightBarItem = UIBarButtonItem.init(title: "Use", style: UIBarButtonItemStyle.Done, target: self, action: #selector(PMImageViewController.confirm))
        
        // Title select photos
        let image = UIImage.init(named: "albums-arrow")
        let hImage = image!.imageWithColor(UIColor.lightGrayColor())
        titleButton = PMPickerTitleButton.init(type: .Custom)
        if #available(iOS 8.2, *) {
            titleButton?.titleLabel?.font = UIFont.systemFontOfSize(17,weight: UIFontWeightMedium
            )
        } else {
            titleButton?.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
        }
        titleButton?.setTitle("Title", forState: UIControlState.Normal)
        titleButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        titleButton?.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
        titleButton?.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Selected)
        titleButton?.setImage(image, forState: UIControlState.Normal)
        titleButton?.setImage(hImage, forState: UIControlState.Highlighted)
        titleButton?.setImage(hImage, forState: UIControlState.Selected)
        titleButton?.sizeToFit()
        titleButton?.addTarget(self, action: #selector(PMImageViewController.selectPhotoGroup), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.rightBarButtonItem = rightBarItem
        navigationItem.titleView = titleButton
    }
    
    // MARK: Album photos
    
    func getPhotos() {
        
        PMImageManger.photoAuthorization { (granted: Bool) in
            if granted {
                if (self.photoGroups == nil) {
                    self.photoGroups = PMImageManger.photoLibrarys()
                }
                
                let group = self.photoGroups![0]
                if (self.photoAssets == nil) {
                    self.photoAssets = PMImageManger.photoAssetsForAlbum(group)
                }
                
                PMImageManger.imageFromAsset(self.photoAssets!.first!, isOriginal: true, toSize: nil, resultHandler: { (image: UIImage?) in
                    self.dsiplayHeader.setImage(image!, scrollToRect: CGRectZero, zoomScale:1)
                })
                
                for asset: PHAsset in self.photoAssets! {
                    PMImageManger.imageFromAsset(asset, isOriginal: false, toSize: CGSizeMake(150, 150), resultHandler: { (image: UIImage?) in
                        self.photos.append(image!)
                    })
                }
                
                // Title
                self.titleButton?.setTitle(group.localizedTitle, forState: UIControlState.Normal)
                self.titleButton?.sizeToFit()
                // Reload data
                self.albumCollection.reloadData()
            }
        }
    }
    
    // MARK: Handle
    
    func cancel() {
        dismissViewControllerAnimated(true) {
            let navigationController = self.pmNavigationController
            navigationController?.pmDelegate?.imagePickerControllerDidCancel?(navigationController!)
        }
    }
    
    func confirm() {
        var imageRect = CGRectZero
        var finalImage = dsiplayHeader.image
        var x = fmax(dsiplayHeader.imageView.contentOffset.x, 0)
        var y = fmax(dsiplayHeader.imageView.contentOffset.y, 0)
        x = x/dsiplayHeader.imageView.contentSize.width * finalImage.size.width
        y = y/dsiplayHeader.imageView.contentSize.height * finalImage.size.height
        imageRect = CGRectMake(x, y, finalImage.size.height, finalImage.size.height)
        
        let navigationController = self.pmNavigationController
        let responsOriginal = navigationController?.pmDelegate?.respondsToSelector(#selector(PMImagePickerControllerDelegate.imagePickerController(_:didFinishPickingImage:selectedRect:zoomScale:)))
        if (responsOriginal != nil) {
            // Not crop the image just call delegate with original image
            let zoomScale = dsiplayHeader.imageView.zoomScale
            navigationController?.pmDelegate?.imagePickerController!(navigationController!, didFinishPickingImage: finalImage, selectedRect: imageRect, zoomScale:zoomScale)
        }else {
            // Get the final cropped image
            finalImage = PMImageManger.cropImageToRect(finalImage, toRect: imageRect)
            // Call delegate
            navigationController?.pmDelegate?.imagePickerController?(navigationController!, didFinishPickingImage: finalImage)
        }
        
        dismissViewControllerAnimated(true) {
            
        }
    }
    
    func selectPhotoGroup() {
        var status = titleButton!.arrowStatus
        switch status {
        case .down:
            
            let arrow = titleButton?.imageView
            var frame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height)
            let groupVC = PMImageGroupController.init()
            groupVC.photoGroups = photoGroups
            groupVC.view.frame = frame
            view.addSubview(groupVC.view)
            self.addChildViewController(groupVC)
            
            UIView.animateWithDuration(constParams.presentGroupAnimationDuration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                frame.origin.y = 0
                groupVC.view.frame = frame
                arrow?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI - 0.001))
                self.navigationItem.leftBarButtonItem?.customView?.alpha = 0
                self.navigationItem.rightBarButtonItem?.customView?.alpha = 0
                
                }, completion: { (com: Bool) in
                    status = .up
                    self.titleButton?.arrowStatus = status
            })
            
            // action
            weak var weakSelf = self
            groupVC.didSelectGroupAction = { (index: Int) in
                let groupCollection = weakSelf!.photoGroups![index]
                weakSelf?.photoAssets = PMImageManger.photoAssetsForAlbum(groupCollection)
                PMImageManger.imageFromAsset(weakSelf!.photoAssets!.first!, isOriginal: true, toSize: nil, resultHandler: { (image: UIImage?) in
                    if let _image = image {
                        weakSelf!.dsiplayHeader.setImage(_image, scrollToRect: CGRectZero, zoomScale:1)
                    }
                })
                weakSelf!.photos.removeAll()
                for asset: PHAsset in weakSelf!.photoAssets! {
                    PMImageManger.imageFromAsset(asset, isOriginal: false, toSize: CGSizeMake(150, 150), resultHandler: { (image: UIImage?) in
                        weakSelf!.photos.append(image!)
                    })
                }
                weakSelf!.selectedIndex = 0
                weakSelf!.albumCollection.reloadData()
                weakSelf!.dropDownHeader(true)
                weakSelf!.dismissGroup()
            }
            
            break
        case .up:
            dismissGroup()
            break
        }
    }
    
    func dismissGroup() {
        let arrow = titleButton?.imageView
        let groupVC = childViewControllers.first
        var frame = groupVC?.view.frame
        
        UIView.animateWithDuration(constParams.presentGroupAnimationDuration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            
            frame!.origin.y = self.screenSize.height
            groupVC!.view.frame = frame!
            arrow?.transform = CGAffineTransformIdentity
            self.navigationItem.leftBarButtonItem?.customView?.alpha = 1
            self.navigationItem.rightBarButtonItem?.customView?.alpha = 1
            
            }, completion: { (com: Bool) in
                self.titleButton?.arrowStatus = .down
                groupVC?.view.removeFromSuperview()
                groupVC?.removeFromParentViewController()
        })
    }
    
    func dropDownHeader(selectedItem: Bool) {
        if selectedItem {
            if headerTopConstraints.constant == 0 {
                if let cell = albumCollection.cellForItemAtIndexPath(NSIndexPath.init(forItem: selectedIndex, inSection: 0)) {
                    albumCollection.scrollRectToVisible(cell.frame, animated: true)
                }else {
                    albumCollection.setContentOffset(CGPointMake(0, 0), animated: true)
                }
            }else {
                var cellFrame = CGRectZero
                if let cell = albumCollection.cellForItemAtIndexPath(NSIndexPath.init(forItem: selectedIndex, inSection: 0)) {
                    cellFrame = cell.frame
                }
                let cellFrameToHeader = dsiplayHeader.convertRect(cellFrame, fromView: albumCollection)
                let lineSpace = (albumCollection.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing
                let moveDistance = -headerTopConstraints.constant
                var contentOffset = albumCollection.contentOffset
                let adjustDistance = (dsiplayHeader.bounds.size.height + moveDistance + lineSpace!) - CGRectGetMinY(cellFrameToHeader)
                
                contentOffset.y += moveDistance
                if adjustDistance > 0 {
                    contentOffset.y -= adjustDistance
                }
                
                UIView.animateWithDuration(constParams.moveHeaderAnimationDuration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                    // Tip: set `contentOffset` must after set constant of `headerTopConstraints`, otherwise it will not be effect
                    // Also should call `setNeedsLayout` & `layoutIfNeeded` to ensure the animation of collection view, because the cells above the selected cell will be hidden or remove during the animation when we don't call `layoutSubViews` of the collection
                    self.headerTopConstraints.constant = 0
                    self.view.layoutIfNeeded()
                    self.albumCollection.contentOffset = contentOffset
                    self.albumCollection.setNeedsLayout()
                    self.albumCollection.layoutIfNeeded()
                    }, completion: { (com: Bool) in
                        
                })
            }
        }else {
            guard -headerTopConstraints.constant == (screenSize.width - constParams.headerTopInset) else {
                return
            }
            var contentOffset = albumCollection.contentOffset
            let moveDistance = -headerTopConstraints.constant
            contentOffset.y += moveDistance
            UIView.animateWithDuration(constParams.moveHeaderAnimationDuration) {
                self.albumCollection.contentOffset = contentOffset
                self.headerTopConstraints.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: UICollectionView M
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (screenSize.width - 3 * 1)/4
        return CGSizeMake(width, width)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.greenColor()
        var imageV = cell.viewWithTag(888) as? UIImageView
        var maskV = cell.viewWithTag(999)
        if nil == imageV {
            imageV = UIImageView.init(frame: cell.bounds)
            imageV!.tag = 888
            imageV?.contentMode = UIViewContentMode.ScaleAspectFill
            imageV?.layer.masksToBounds = true
            cell.addSubview(imageV!)
        }
        if nil == maskV {
            maskV = UIView.init(frame: cell.bounds)
            maskV?.backgroundColor = UIColor.init(white: 1, alpha: 0.75)
            maskV!.tag = 999
            cell.addSubview(maskV!)
        }
        imageV?.image = photos[indexPath.item]
        maskV?.hidden = selectedIndex != indexPath.item
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.item != selectedIndex else {
            return
        }
        let oldCell = collectionView.cellForItemAtIndexPath(NSIndexPath.init(forItem: selectedIndex, inSection: 0))
        let oldMask = oldCell?.viewWithTag(999)
        oldMask?.hidden = true
        let newCell = collectionView.cellForItemAtIndexPath(indexPath)
        let newMask = newCell?.viewWithTag(999)
        newMask?.hidden = false
        selectedIndex = indexPath.item
        dropDownHeader(true)
        
        // Set image
        PMImageManger.imageFromAsset(photoAssets![indexPath.item], isOriginal: true, toSize: nil, resultHandler: { (image: UIImage?) in
            if let _image = image {
                self.dsiplayHeader.setImage(_image, scrollToRect: CGRectZero, zoomScale:1)
            }
        })
    }
    
    
    // MARK: ScrollView panGesture Swizzle
    
    func scrollViewDidPan(panGestureRecognizer: UIPanGestureRecognizer) {
        let velocity = panGestureRecognizer.velocityInView(albumCollection)
        let tramslation = panGestureRecognizer.translationInView(view)
        let location = panGestureRecognizer.locationInView(dsiplayHeader)
        var touchHeaderBottom: Bool = false
        
        
        // Move up
        if (velocity.y < 0) {
            touchHeaderBottom = location.y < dsiplayHeader!.bounds.size.height
            shouldMoveHeaderDown = false;
            switch (panGestureRecognizer.state) {
            case .Began:
                shouldMoveHeaderUp = location.y < dsiplayHeader!.bounds.size.height && headerTopConstraints.constant > -(screenSize.width - constParams.headerTopInset)
                if shouldMoveHeaderUp {
                    contentOffset = albumCollection.contentOffset
                    panGestureRecognizer.setTranslation(CGPointMake(tramslation.x, 0), inView: view)
                }
                break;
            case .Changed:
                if isHeaderMoving {
                    shouldMoveHeaderUp = true
                }
                if shouldMoveHeaderUp {
                    headerTopConstraints.constant += tramslation.y;
                    
                    if headerTopConstraints.constant > -(screenSize.width - constParams.headerTopInset) {
                        contentOffset.y = fmin(contentOffset.y, albumCollection.contentSize.height - albumCollection.bounds.size.height)
                        albumCollection!.contentOffset = contentOffset
                        panGestureRecognizer.setTranslation(CGPointMake(tramslation.x, 0), inView: view)
                    }else {
                        headerTopConstraints.constant = -(screenSize.width - constParams.headerTopInset)
                        isHeaderMoving = false
                    }
                }else {
                    shouldMoveHeaderUp = touchHeaderBottom && headerTopConstraints.constant > -(screenSize.width - constParams.headerTopInset)
                    if shouldMoveHeaderUp {
                        isHeaderMoving = true
                        contentOffset = albumCollection!.contentOffset
                        if albumCollection.contentSize.height <= albumCollection.bounds.size.height {
                            contentOffset = CGPointMake(0, 0)
                        }
                        panGestureRecognizer.setTranslation(CGPointMake(tramslation.x, 0), inView: view)
                    }
                }
                break;
            case .Ended:
                shouldMoveHeaderUp = false; isHeaderMoving = false
                let isNotOnTheTop: Bool = headerTopConstraints.constant > -(screenSize.width - constParams.headerTopInset)
                if isNotOnTheTop {
                    let shouldAnimationToTop = headerTopConstraints.constant < -constParams.minMoveDistance
                    if shouldAnimationToTop {
                        let distance = screenSize.width - (constParams.headerTopInset + constParams.minMoveDistance)
                        let duration = CFTimeInterval((distance + (constParams.minMoveDistance + headerTopConstraints.constant))/distance) * constParams.moveHeaderAnimationDuration
                        
                        UIView.animateWithDuration(duration, delay: 0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveLinear], animations: {
                            self.headerTopConstraints.constant = -(self.screenSize.width - self.constParams.headerTopInset)
                            self.view.layoutIfNeeded()
                            }, completion: { (finish: Bool) in
                                
                        })
                    }else {
                        UIView.animateWithDuration(self.constParams.backHeaderAnimationDuration, delay: 0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveLinear], animations: {
                            self.headerTopConstraints.constant = 0
                            self.view.layoutIfNeeded()
                            }, completion: { (finish: Bool) in
                                
                        })
                    }
                }
                
                break;
                
            default:
                shouldMoveHeaderUp = false
                break;
            }
        }
        // Move down
        else {
            touchHeaderBottom = location.y < dsiplayHeader!.bounds.size.height && location.y > dsiplayHeader!.bounds.size.height - 20
            shouldMoveHeaderUp = false
            switch (panGestureRecognizer.state) {
            case .Began:
                shouldMoveHeaderDown = albumCollection.contentOffset.y <= 0 && headerTopConstraints.constant < 0
                if shouldMoveHeaderDown {
                    contentOffset.y = 0
                    albumCollection.contentOffset = contentOffset
                    panGestureRecognizer.setTranslation(CGPointMake(tramslation.x, 0), inView: view)
                }
                break;
            case .Changed:
                if isHeaderMoving {
                    shouldMoveHeaderDown = true
                }
                if shouldMoveHeaderDown {
                    headerTopConstraints.constant += tramslation.y;
                    headerTopConstraints.constant = fmin(headerTopConstraints.constant, 0)
                    
                    if headerTopConstraints.constant < 0 {
                        albumCollection.contentOffset = contentOffset
                        panGestureRecognizer.setTranslation(CGPointMake(tramslation.x, 0), inView: view)
                    }else {
                        headerTopConstraints.constant = 0
                        isHeaderMoving = false
                    }
                    
                }else {
                    shouldMoveHeaderDown = (albumCollection.contentOffset.y <= 0 || touchHeaderBottom) && headerTopConstraints.constant < 0
                    if shouldMoveHeaderDown {
                        isHeaderMoving = true
                        contentOffset.y = fmax(albumCollection.contentOffset.y, 0)
                        albumCollection.contentOffset = contentOffset
                        panGestureRecognizer.setTranslation(CGPointMake(tramslation.x, 0), inView: view)
                    }
                }
                break;
            case .Ended:
                shouldMoveHeaderDown = false; isHeaderMoving = false
                let isNotOnTheBottom: Bool = headerTopConstraints.constant < 0
                if isNotOnTheBottom {
                    let shouldAnimationToBottom: Bool = headerTopConstraints.constant > -(screenSize.width - (constParams.minMoveDistance + constParams.headerTopInset))
                    if shouldAnimationToBottom {
                        let distance = screenSize.width - (constParams.minMoveDistance + constParams.headerTopInset)
                        let duration = CFTimeInterval((-headerTopConstraints.constant)/distance) * constParams.moveHeaderAnimationDuration
                        
                        UIView.animateWithDuration(duration, delay: 0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveLinear], animations: {
                            self.headerTopConstraints.constant = 0
                            self.view.layoutIfNeeded()
                            }, completion: { (finish: Bool) in
                                
                        })
                        
                    }else {
                        
                        UIView.animateWithDuration(constParams.backHeaderAnimationDuration, delay: 0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveLinear], animations: {
                            self.headerTopConstraints.constant = -(self.screenSize.width - self.constParams.headerTopInset)
                            self.view.layoutIfNeeded()
                            }, completion: { (finish: Bool) in
                                
                        })
                    }
                }
                break;
                
            default:
                shouldMoveHeaderDown = false
                break;
            }
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


protocol UIScrollViewPanGestureRecognizer {
    func scrollViewDidPan(pan: UIPanGestureRecognizer)
}

extension UIScrollView {
    public override static func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        // Make sure not subclass
        if self !== UIScrollView.self {
            return
        }
        
        dispatch_once(&Static.token) {
            let originalSelector = NSSelectorFromString("handlePan:")
            let swizzledSelector = NSSelectorFromString("pm_handlePan:")
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    }
    
    // MARK: - Method Swizzling
    func pm_handlePan(pan: UIPanGestureRecognizer) {
        pm_handlePan(pan)
        
        if delegate != nil && delegate!.respondsToSelector(NSSelectorFromString("scrollViewDidPan:")) {
            delegate?.performSelector(NSSelectorFromString("scrollViewDidPan:"), withObject: pan)
        }
    }
}
