//
//  PMPhotoHeaderItem.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/26.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit


class PMPhotoHeaderItem: UIScrollView, UIScrollViewDelegate {

    var imageContainerView: UIView = UIView.init()
    var imageView: UIImageView = UIImageView.init()
    var selectedRect: CGRect = CGRectZero
    var targetZoomScale: CGFloat = 1.0
    
    override var frame: CGRect {
        didSet {
            bounds.origin = CGPointZero  // reset zero origin to fit the adjust effect of scroll view
            imageContainerView.frame = bounds
            imageView.frame = imageContainerView.bounds
            resetSubViews()
        }
    }
    var scrollViewDidZoom: ((scrollView: UIScrollView)->Void)?
    var scrollViewBeganDragging: ((scrollView: UIScrollView)->Void)?
    var scrollViewEndDragging: ((scrollView: UIScrollView)->Void)?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configSubviews() {
        
        delegate = self
        bouncesZoom = true
        maximumZoomScale = 3
        multipleTouchEnabled = true
        bounces = true
        alwaysBounceVertical = true
        alwaysBounceHorizontal = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        imageContainerView.frame = bounds
        imageContainerView.clipsToBounds = true
        imageContainerView.backgroundColor = UIColor.whiteColor()
        imageView.clipsToBounds = true
        imageContainerView.addSubview(imageView)
        addSubview(imageContainerView)
        
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(PMPhotoHeaderItem.doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
    }
    
    /**
     Set the image of content image view. And scroll to target rect.
     If parameter zoomScale is not 1, the target rect `scrollToRect` should be the rect with image coordinate
     
     - parameter image:        An image set to display
     - parameter scrollToRect: Target rect to show the image view
     - parameter zoomScale:    Target zoomScale
     */
    func setImage(image: UIImage, scrollToRect: CGRect, zoomScale: CGFloat) {
        imageView.image = image
        selectedRect = scrollToRect
        targetZoomScale = zoomScale
        // Reset contentSize
        resetSubViews()
    }
    
    // MARK: Private
    
    @objc private func doubleTap(tap: UITapGestureRecognizer) {
        zoomOutView(tap)
//        zoomInView(tap)
    }
    
    private func zoomInView(tap: UITapGestureRecognizer) {
        if zoomScale > 1 {
            setZoomScale(1, animated: true)
        } else {
            let touchPoint = tap.locationInView(imageView)
            let newZoomScale = maximumZoomScale
            let xsize = bounds.size.width / newZoomScale
            let ysize = bounds.size.height / newZoomScale
            
            zoomToRect(CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize), animated: true)
        }
    }
    
    private func zoomOutView(tap: UITapGestureRecognizer) {
        guard zoomScale > 1 else {
            return
        }
        zoomScale = 1
        resetSubViews()
    }
    
    private func resetSubViews() {
        if let image = imageView.image {
            let ratio = image.size.width/image.size.height
            let const = bounds.size.width/bounds.size.height
            if ratio > const {
                contentSize = CGSizeMake(ratio * bounds.size.height, bounds.size.height)
            }else {
                contentSize = CGSizeMake(bounds.size.width, bounds.size.width/ratio)
            }
            var frame = imageContainerView.frame
            frame.size = contentSize
            imageContainerView.frame = frame
            imageView.frame = imageContainerView.bounds
            
            // scroll to target rect
            var fitRect = CGRectMake((contentSize.width - bounds.size.width)/2, (contentSize.height - bounds.size.height)/2, bounds.size.width, bounds.size.height)
            if !CGRectEqualToRect(selectedRect, CGRectZero) {
                fitRect = selectedRect
            }
            
            // zoom if need
            if targetZoomScale != 1 {
                let contentSize = CGSizeApplyAffineTransform(self.contentSize, CGAffineTransformMakeScale(targetZoomScale, targetZoomScale))
                fitRect.origin.x = fitRect.origin.x * (contentSize.width/image.size.width)
                fitRect.origin.y = fitRect.origin.y * (contentSize.height/image.size.height)
                
                fitRect = CGRectApplyAffineTransform(fitRect, CGAffineTransformMakeScale(1.0/targetZoomScale, 1.0/targetZoomScale))
                zoomToRect(fitRect, animated: false)
            }else {
                scrollRectToVisible(fitRect, animated: false)
            }
        }
    }
    
    // MARK: Zoom
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let subView = imageContainerView
        
        var offsetX = CGFloat(0)
        if scrollView.bounds.size.width > scrollView.contentSize.width {
            offsetX = (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5
        }
        
        var offsetY = CGFloat(0)
        if scrollView.bounds.size.height > scrollView.contentSize.height {
            offsetY = (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5
        }
        
        subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
        scrollView.contentSize.height * 0.5 + offsetY)
        
        if let action = scrollViewDidZoom {
            action(scrollView: scrollView)
        }
    }
    
    
    // MARK: UIScrollView M
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if let drag = scrollViewBeganDragging {
            drag(scrollView: self)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let endDrag = scrollViewEndDragging {
            endDrag(scrollView: self)
        }
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
