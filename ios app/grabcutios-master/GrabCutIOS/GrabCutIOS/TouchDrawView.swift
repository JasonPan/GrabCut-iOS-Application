//
//  TouchDrawView.swift
//  FIT1041 GrabCut
//
//  Created by Jason @ Monash on 22/09/2016.
//  Copyright © 2016 Jason Pan. All rights reserved.
//

import UIKit

@objc public enum TouchState: Int {
    case None
    case Rect
    case Plus
    case Minus
}

@objc public class TouchDrawView: UIView {
    
//    public var currentState: TouchState!
    public var currentState: TouchState = .None {
        didSet {
//            if currentState == .Rect {
//                self.rectangle = self.bounds
//                self.drawRect(self.bounds)
//                self.setNeedsDisplay()
//            }
        }
    }
    
//    public func setCurrentState(state: TouchState) {
//        self.currentState = state
//    }
    
    var pts: [CGPoint] = [CGPoint](count: 5, repeatedValue: CGPointZero) // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    var ctr: UInt!
    
    private var rectangle: CGRect!
    
    private var plusPath: UIBezierPath!
    private var minusPath: UIBezierPath!
    private var incrementalImage: UIImage!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initTouchView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initTouchView()
    }
    
    func initTouchView() {
        self.plusPath = UIBezierPath()
        self.plusPath.lineWidth = 6.0
        self.plusPath.lineCapStyle = .Round
        
        self.minusPath = UIBezierPath()
        self.minusPath.lineWidth = 6.0
        self.minusPath.lineCapStyle = .Round
        
        self.currentState = .None
    }
    
    func touchStarted(p: CGPoint) {
        if self.currentState == .Plus || self.currentState == .Minus {
            self.ctr = 0
            self.pts[0] = p
        }
    }
    
    func touchMoved(p: CGPoint) {
        if self.currentState == .Plus || self.currentState == .Minus {
            self.ctr = self.ctr + 1
            self.pts[Int(self.ctr)] = p
            if self.ctr == 4 {
                self.pts[3] = CGPointMake((self.pts[2].x + self.pts[4].x)/2.0, (self.pts[2].y + self.pts[4].y)/2.0) // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
                
                if self.currentState == .Plus {
                    self.plusPath.moveToPoint(self.pts[0])
                    self.plusPath.addCurveToPoint(self.pts[3], controlPoint1: self.pts[1], controlPoint2: self.pts[2]) // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
                }else if self.currentState == .Minus {
                    self.minusPath.moveToPoint(self.pts[0])
                    self.minusPath.addCurveToPoint(self.pts[3], controlPoint1: self.pts[1], controlPoint2: self.pts[2]) // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
                }
                
                self.setNeedsDisplay()
                // replace points and get ready to handle the next segment
                self.pts[0] = self.pts[3]
                self.pts[1] = self.pts[4]
                self.ctr = 1
            }
        }
    }
    
    func touchEnded(p: CGPoint) {
        if self.currentState == .Plus || self.currentState == .Minus {
            // Do nothing.
        }
    }
    
    func drawRectangle(rect: CGRect) {
        self.currentState = .Rect
        self.rectangle = rect
        self.setNeedsDisplay()
    }
    
    func clear() {
//        self.currentState = .None
//        self.plusPath.removeAllPoints()
//        self.minusPath.removeAllPoints()
        self.setNeedsDisplay()
    }
    
    func clearForReal() {
        self.currentState = .None
        self.plusPath.removeAllPoints()
        self.minusPath.removeAllPoints()
        self.setNeedsDisplay()
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    public override func drawRect(rect: CGRect) {
//        guard self.currentState != nil else {
//            return
//        }
        
        // Drawing code
        if self.currentState == .Rect {
            //Get the CGContext from this view
            let context: CGContextRef? = UIGraphicsGetCurrentContext()
            //Draw a rectangle
            CGContextSetFillColorWithColor(context, UIColor.init(red: 1.0, green: 0, blue: 0, alpha: 0.4).CGColor)
            //Define a rectangle
            CGContextAddRect(context, self.rectangle)
            //Draw it
            CGContextFillPath(context)
        }else if self.currentState == .Plus || self.currentState == .Minus {
//        [_incrementalImage drawInRect:rect];
//            self.incrementalImage.drawInRect(rect)      // VERIFY
            
            UIColor.whiteColor().setStroke()
            self.plusPath.stroke()
            UIColor.blackColor().setStroke()
            self.minusPath.stroke()
        }
    }
    
    func maskImageWithPainting() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.renderInContext(context)
            let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return img
        }
        return nil
    }
    
}
