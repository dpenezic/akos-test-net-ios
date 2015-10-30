/*********************************************************************************
* Copyright 2014-2015 SPECURE GmbH
* 
* Redistribution and use of the RMBT code or any derivative works are 
* permitted provided that the following conditions are met:
* 
*   - Redistributions may not be sold, nor may they be used in a commercial 
*     product or activity.
*   - Redistributions that are modified from the original source must include 
*     the complete source code, including the source code for all components
*     used by a binary built from the modified sources. However, as a special 
*     exception, the source code distributed need not include anything that is 
*     normally distributed (in either source or binary form) with the major 
*     components (compiler, kernel, and so on) of the operating system on which 
*     the executable runs, unless that component itself accompanies the executable.
*   - Redistributions must reproduce the above copyright notice, this list of 
*     conditions and the following disclaimer in the documentation and/or
*     other materials provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
* BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
* OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
* OF THE POSSIBILITY OF SUCH DAMAGE.
*********************************************************************************/

//
//  RMBTUITrafficView.swift
//  RMBT
//
//  Created by Benjamin Pucher on 27.03.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
public class RMBTUITrafficView : UIView {

    ///
    let DEFAULT_COLOR = UIColor.lightGrayColor() // TODO: global config
    
    ///
    let SPEED_COLOR = UIColor.whiteColor() //UIColor.blackColor() // TODO: global config
    
    ///
    private var lowSignal: Bool = false
    
    ///
    private var midSignal: Bool = false
    
    ///
    private var highSignal: Bool = false
    
    ///
    private var lineColor: UIColor!
    
    ///
    public var viewOrientation: Bool = false {
        didSet {
            if (viewOrientation) {
                let transform: CGAffineTransform = CGAffineTransformMakeRotation(deg2rad(180))
                self.transform = transform
            }
        }
    }
    
    ///
    public var signalStrength: String = "none" {
        didSet {
            if (signalStrength == "low") {
                lowSignal = true
                midSignal = false
                highSignal = false
            } else if (signalStrength == "mid") {
                lowSignal = true
                midSignal = true
                highSignal = false
            } else if (signalStrength == "high") {
                lowSignal = true
                midSignal = true
                highSignal = true
            } else {
                lowSignal = false
                midSignal = false
                highSignal = false
            }
            
            setNeedsDisplay()
        }
    }
    
    //
    
    ///
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    ///
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    ///
    private func commonInit() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    ///
    public func setLineColor(lineColor: UIColor) { // TODO: rewrite to property
        self.lineColor = lineColor
        setNeedsDisplay()
    }
    
    ///
    private func deg2rad(x: Double) -> CGFloat {
        return CGFloat(M_PI * (x) / 180)
    }
    
    ///
    public override func drawRect(rect: CGRect) {
        
        // Frames
        let frame: CGRect = self.bounds
        
        // Subframes
        let group: CGRect = CGRectMake(CGRectGetMinX(frame) + 8, CGRectGetMinY(frame) + 5, CGRectGetWidth(frame) - 6, CGRectGetHeight(frame) - 6)
        
        // Bezier Drawing
        let bezierPath = UIBezierPath()
        
        bezierPath.moveToPoint(CGPointMake(CGRectGetMinX(group) + 0.14083 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.35417 * CGRectGetHeight(group)))
        bezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(group) + 0.43667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.58750 * CGRectGetHeight(group)))
        bezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(group) + 0.75000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.35417 * CGRectGetHeight(group)))
        bezierPath.lineCapStyle = kCGLineCapSquare
        
        let bezierPath1 = UIBezierPath(CGPath: bezierPath.CGPath)
        
        bezierPath1.moveToPoint(CGPointMake(CGRectGetMinX(group) + 0.14083 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.05417 * CGRectGetHeight(group)))
        bezierPath1.addLineToPoint(CGPointMake(CGRectGetMinX(group) + 0.43667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.28750 * CGRectGetHeight(group)))
        bezierPath1.addLineToPoint(CGPointMake(CGRectGetMinX(group) + 0.75000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.05417 * CGRectGetHeight(group)))
        bezierPath1.lineCapStyle = kCGLineCapSquare
        
        let bezierPath2 = UIBezierPath(CGPath: bezierPath.CGPath)
        
        bezierPath2.moveToPoint(CGPointMake(CGRectGetMinX(group) + 0.14083 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.65417 * CGRectGetHeight(group)))
        bezierPath2.addLineToPoint(CGPointMake(CGRectGetMinX(group) + 0.43667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.88750 * CGRectGetHeight(group)))
        bezierPath2.addLineToPoint(CGPointMake(CGRectGetMinX(group) + 0.75000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.65417 * CGRectGetHeight(group)))
        bezierPath2.lineCapStyle = kCGLineCapSquare
        
        let lineWidth = CGFloat(frame.size.width) / 10
        
        bezierPath2.lineWidth = lineWidth
        bezierPath1.lineWidth = lineWidth
        bezierPath.lineWidth = lineWidth
        
        if (lowSignal) {
            SPEED_COLOR.setStroke()
        } else {
            DEFAULT_COLOR.setStroke()
        }
        
        bezierPath1.stroke()
        
        if (highSignal) {
            SPEED_COLOR.setStroke()
        } else {
            DEFAULT_COLOR.setStroke()
        }
        
        bezierPath2.stroke()
        
        if (midSignal) {
            SPEED_COLOR.setStroke()
        } else {
            DEFAULT_COLOR.setStroke()
        }
        
        bezierPath.stroke()
    }
}
