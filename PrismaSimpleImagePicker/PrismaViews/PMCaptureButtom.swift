//
//  PMCaptureButtom.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/28.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit

let touchUpDuration = 0.4

class PMTarget: NSObject {
    var target: AnyObject?
    var action: Selector?
    var touchAction: Selector = #selector(PMTarget.touch(_:))
    
    override init() {
        super.init()
    }
    
    convenience init(target: AnyObject, action: Selector) {
        self.init()
        self.target = target
        self.action = action
    }
    
    func touch(sender: UIButton) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(touchUpDuration * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            if let target = self.target as? NSObject{
                target.performSelector(self.action!, withObject: sender)
            }
        }
    }
}


class PMCaptureButton: UIButton {
    
    var lineWidth: CGFloat = 1
    var lineColor: UIColor = UIColor.RGBColor(78, green: 78, blue: 78)
    var fillColor: UIColor = UIColor.RGBColor(245, green: 245, blue: 245)
    var enabledColor: UIColor = UIColor.init(white: 0.98, alpha: 0.75)
    let content = PMCaptureButtonContent.init()
    var shouldLayout = true
    var targets: [AnyObject] = [AnyObject]()
    
    
    override var enabled: Bool {
        didSet {
            content.enabled = enabled
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        configViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
        configViews()
    }
    
    func configViews() {
        content.backgroundColor = UIColor.clearColor()
        content.frame = bounds
        content.lineColor = lineColor
        content.lineWidth = lineWidth
        content.fillColor = fillColor
        content.enabledColor = enabledColor
        content.userInteractionEnabled = false
        addSubview(content)
        
        addTarget(self, action: #selector(PMCaptureButton.touchDown), forControlEvents: UIControlEvents.TouchDown)
        super.addTarget(self, action: #selector(PMCaptureButton.touchUpInside), forControlEvents: UIControlEvents.TouchUpInside)
        addTarget(self, action: #selector(PMCaptureButton.touchDragExit), forControlEvents: UIControlEvents.TouchDragExit)
        addTarget(self, action: #selector(PMCaptureButton.touchDragEnter), forControlEvents: UIControlEvents.TouchDragEnter)
    }
    
    override func layoutSubviews() {
        guard shouldLayout else {
            return
        }
        content.frame = bounds
    }
    
    override func addTarget(target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControlEvents) {
        if controlEvents == .TouchUpInside {
            if let tar = target {
                let pmTarget = PMTarget.init(target: tar, action: action)
                super.addTarget(pmTarget, action: #selector(PMTarget.touch(_:)), forControlEvents: controlEvents)
                targets.append(pmTarget) // retain ARC, also could associate `pmTarget` property to `target`, and write an extension of NSObject to add a dealloc call back metohod(remove the association).
            }
        }else {
            super.addTarget(target, action: action, forControlEvents: controlEvents)
        }
    }
    
    
    func touchDown() {
        setSelectedState(true)
    }
    
    func touchUpInside() {
        setSelectedState(false)
    }
    
    func touchDragExit() {
        setSelectedState(false)
    }
    
    func touchDragEnter() {
        setSelectedState(true)
    }
    
    func setSelectedState(selected: Bool) {
        if selected {
            shouldLayout = false
            UIView.animateWithDuration(0.05, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.content.transform = CGAffineTransformMakeScale(0.86, 0.86)
                }, completion: { (com: Bool) in
                    self.shouldLayout = true
            })
        }else {
            shouldLayout = false
            UIView.animateWithDuration(touchUpDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.content.transform = CGAffineTransformIdentity
                }, completion: { (com: Bool) in
                    self.shouldLayout = true
            })
        }
    }
}

class PMCaptureButtonContent: UIView {
    
    var lineWidth: CGFloat = 1
    var lineColor: UIColor = UIColor.blackColor()
    var fillColor: UIColor = UIColor.grayColor()
    var enabledColor: UIColor = UIColor.lightGrayColor()
    let screenScale: CGFloat = UIScreen.mainScreen().scale
    var centerOffset: CGFloat = (1.0/UIScreen.mainScreen().scale)/2
    private var _enabled: Bool = true
    var enabled: Bool {
        set {
            _enabled = newValue
            setNeedsDisplay()
        }
        get {
            return _enabled
        }
    }
    
    
    override func drawRect(rect: CGRect) {
        // Draw circle
        let edgeInset: CGFloat = 2
        let centerX = CGFloatPixelRound(bounds.size.width/2)
        let centerY = CGFloatPixelRound(bounds.size.height/2)
        let radius = CGFloatPixelRound(bounds.size.width/2 - 2 * edgeInset)
        if (lineWidth * screenScale)/2 == 0 {
            centerOffset = 0
        }
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetFillColorWithColor(context, fillColor.CGColor)
        CGContextAddArc(context, centerX + centerOffset, centerY + centerOffset, radius, 0, CGFloat(M_PI) * 2, 0)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        
        if enabled == false {
            CGContextSaveGState(context)
            CGContextSetFillColorWithColor(context, enabledColor.CGColor)
            CGContextAddArc(context, centerX + centerOffset, centerY + centerOffset, radius + lineWidth, 0, CGFloat(M_PI) * 2, 0)
            CGContextDrawPath(context, CGPathDrawingMode.Fill)
        }
    }
    
    func CGFloatPixelRound(value: CGFloat) -> CGFloat {
        let scale = screenScale
        return round(value * scale) / scale
    }
}

