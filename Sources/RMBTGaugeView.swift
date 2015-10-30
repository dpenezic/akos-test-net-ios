/*********************************************************************************
* Copyright 2013 appscape gmbh
* Copyright 2014-2015 SPECURE GmbH
* 
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* 
*   http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*********************************************************************************/

//
//  RMBTGaugeView.swift
//  RMBT
//
//  Created by Benjamin Pucher on 19.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import UIKit

///
public class RMBTGaugeView : UIView {
   
    ///
    private var startAngle: CGFloat!
    
    ///
    private var endAngle: CGFloat!

    ///
    private var foregroundImage: UIImage!
    
    ///
    private var backgroundImage: UIImage!
    
    ///
    private var maskLayer: CAShapeLayer!
    
    ///
    private var ovalRect: CGRect!
    
    ///
    public var clockWiseOrientation: Bool = true
    
    ///
    private var _value: Float = 0
    public var value: Float {
        get {
            return self._value
        }
        set {
            if (self._value == newValue) {
                return
            }
            
            self._value = newValue
            
            if (!clockWiseOrientation) {
                _value = fabsf(1 - newValue)
                
                // hot fix
                if (newValue == 1) {
                    _value = 0.0001
                }
            }
            
            let angle: CGFloat = startAngle + (endAngle - startAngle) * CGFloat(_value)
            
            let path = UIBezierPath(
                arcCenter: CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect)),
                radius: ovalRect.size.width / 2.0,
                startAngle: startAngle,
                endAngle: angle,
                clockwise: clockWiseOrientation
            )
            
            let backEndAngle = startAngle - (2.0 * CGFloat(M_PI))
            let backStartAngle = angle - (2.0 * CGFloat(M_PI))
            
            path.addArcWithCenter(CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect)),
                                radius: (ovalRect.size.width / 2.0) - 15,
                                startAngle: backStartAngle,
                                endAngle: backEndAngle,
                                clockwise: !clockWiseOrientation)
            
            path.closePath()
            
            maskLayer.path = path.CGPath
        }
    }
    
    //
    
    ///
    public required init(frame: CGRect, name: String, startAngle: CGFloat, endAngle: CGFloat, ovalRect: CGRect) {
        super.init(frame: frame)
        
        self.startAngle = (startAngle * CGFloat(M_PI)) / 180.0
        self.endAngle = (endAngle * CGFloat(M_PI)) / 180.0
        self.ovalRect = ovalRect
        //self.value = 0
        
        self.opaque = false
        self.backgroundColor = UIColor.clearColor()
        
        self.foregroundImage = UIImage(named: "gauge_\(name)_active_new")
        self.backgroundImage = UIImage(named: "gauge_\(name)_bg_new")
        
        assert(self.foregroundImage != nil, "Couldn't load image")
        assert(self.backgroundImage != nil, "Couldn't load image")
        
        //
        
        let foregroundLayer = CALayer()
        foregroundLayer.frame = CGRectMake(0, 0, foregroundImage.size.width, foregroundImage.size.height)
        foregroundLayer.contents = foregroundImage.CGImage
        
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)
        backgroundLayer.contents = backgroundImage.CGImage
        
        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(foregroundLayer)
        
        self.maskLayer = CAShapeLayer()
        foregroundLayer.mask = maskLayer
    }
    
    ///
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        assert(false, "init(code:) should never be used on class RMBTGaugeView")
    }
}
