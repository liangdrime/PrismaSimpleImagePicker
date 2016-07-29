//
//  PMPhotoGridView.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/26.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit

class PMPhotoGridView: UIView {
    
    var lineWidth: CGFloat = 1.0/UIScreen.mainScreen().scale
    var lineOffset: CGFloat = (1.0/UIScreen.mainScreen().scale)/2
    let screenScale: CGFloat = UIScreen.mainScreen().scale
    var lineBgWidth: CGFloat = 5
    var lineColor: UIColor = UIColor.init(white: 1, alpha: 0.85)
    var lineBgColor: UIColor = UIColor.init(white: 0.65, alpha: 0.07)
    

    override var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        drawLine(context!, color: lineBgColor, width: lineBgWidth)
        CGContextSaveGState(context)
        drawLine(context!, color: lineColor, width: lineWidth)
    }
    
    func drawLine(context: CGContext, color: UIColor, width: CGFloat) {
        let width1 = CGFloatPixelRound(bounds.size.width/3)
        let width2 = CGFloatPixelRound(bounds.size.width/3 * 2)
        let height1 = CGFloatPixelRound(bounds.size.height/3)
        let height2 = CGFloatPixelRound(bounds.size.height/3 * 2)
        
        // H line 1
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextMoveToPoint(context, 0, height1 + lineOffset)
        CGContextAddLineToPoint(context, bounds.size.width, height1 + lineOffset)
        CGContextSetLineWidth(context, width)
        CGContextStrokePath(context)
        
        CGContextSaveGState(context)
        
        // H line 2
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextMoveToPoint(context, 0, height2 + lineOffset)
        CGContextAddLineToPoint(context, bounds.size.width, height2 + lineOffset)
        CGContextSetLineWidth(context, width)
        CGContextStrokePath(context)
        
        CGContextRestoreGState(context)
        CGContextSaveGState(context)
        
        
        // V line 1
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextMoveToPoint(context, width1 + lineOffset, 0)
        CGContextAddLineToPoint(context, width1 + lineOffset, bounds.size.height)
        CGContextSetLineWidth(context, width)
        CGContextStrokePath(context)
        
        CGContextRestoreGState(context)
        CGContextSaveGState(context)
        
        // V line 2
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextMoveToPoint(context, width2 + lineOffset, 0)
        CGContextAddLineToPoint(context, width2 + lineOffset, bounds.size.height)
        CGContextSetLineWidth(context, width)
        CGContextStrokePath(context)
    }
    
    func CGFloatPixelRound(value: CGFloat) -> CGFloat {
        let scale = screenScale
        return round(value * scale) / scale
    }
}
