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
//  RMBT_ProgressView.swift
//  RMBT
//
//  Created by Tomas Baculak on 27/02/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//
// Initial color is White, when a color change is needed use setStrokeColor function

import UIKit

///
class RMBT_ProgressView : UIView {
    
    ///
    var strokeThickness: CGFloat = 0.1
    
    ///
    var radius: CGFloat = 0
    
    ///
    var strokeColor = UIColor.whiteColor() {
        didSet {
            for layer in self.layer.sublayers {
                layer.removeFromSuperlayer()
            }
            
            //strokeColor = color
            //self.indefiniteAnimatedLayer.removeAllAnimations()
            layoutAnimatedLayer()
        }
    }
    
    //
    
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    ///
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    ///
    func commonInit() {
        strokeThickness = frame.size.width / 12.0
        radius = frame.size.width / 2 - strokeThickness
        
        backgroundColor = UIColor.clearColor()
        layoutAnimatedLayer()
    }
    
    ///
    func layoutAnimatedLayer() {
        let layer: CALayer = getIndefiniteAnimatedLayer()
        self.layer.addSublayer(layer)
        layer.position = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds) / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds) / 2)
    }

    ///
    func getIndefiniteAnimatedLayer() -> CAShapeLayer {
        let arcCenter = CGPointMake(radius + strokeThickness / 2 + 2, radius + strokeThickness / 2 + 2)
        let rect = CGRectMake(0.0, 0.0, arcCenter.x * 2, arcCenter.y * 2)
        
        let smoothedPath = UIBezierPath(
            arcCenter: arcCenter,
            radius: radius,
            startAngle: CGFloat(M_PI * 3 / 2),
            endAngle: CGFloat(M_PI / 2 + M_PI * 5),
            clockwise: true
        )
        
        let indefiniteAnimatedLayer = CAShapeLayer()
        indefiniteAnimatedLayer.contentsScale = UIScreen.mainScreen().scale
        indefiniteAnimatedLayer.frame = rect
        indefiniteAnimatedLayer.fillColor = UIColor.clearColor().CGColor
        indefiniteAnimatedLayer.strokeColor = strokeColor.CGColor
        indefiniteAnimatedLayer.lineWidth = strokeThickness
        indefiniteAnimatedLayer.lineCap = kCALineCapRound
        indefiniteAnimatedLayer.lineJoin = kCALineJoinBevel
        indefiniteAnimatedLayer.path = smoothedPath.CGPath
        
        var maskLayer = CALayer()
        let image = UIImage(named: "SVProgressHUD.bundle/angle-mask")
        
        maskLayer.contents = image?.CGImage
        maskLayer.frame = indefiniteAnimatedLayer.bounds
        
        indefiniteAnimatedLayer.mask = maskLayer
        
        let animationDuration: NSTimeInterval = 1
        var linearCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        var animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = M_PI * 2
        animation.duration = animationDuration
        animation.timingFunction = linearCurve
        animation.removedOnCompletion = false
        animation.repeatCount = Float.infinity
        animation.fillMode = kCAFillModeForwards
        animation.autoreverses = false
        
        indefiniteAnimatedLayer.addAnimation(animation, forKey: "rotate")
        
        var animationGroup = CAAnimationGroup()
        animationGroup.duration = animationDuration
        animationGroup.repeatCount = Float.infinity
        animationGroup.removedOnCompletion = false
        animationGroup.timingFunction = linearCurve
        
        var strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.fromValue = 0.015
        strokeStartAnimation.toValue = 0.515
        
        var strokeEndAnimation  = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0.885
        strokeEndAnimation.toValue = 0.985
        
        animationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
        indefiniteAnimatedLayer.addAnimation(animationGroup, forKey: "progress")
        
        return indefiniteAnimatedLayer
    }
}
