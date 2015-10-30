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
//  RMBTSpeedGraphView.swift
//  RMBT
//
//  Created by Benjamin Pucher on 20.04.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

let RMBTSpeedGraphViewContentFrame = CGRect(x: (320 - 200)/2.0 + 22, y: 9, width: 160, height: 66)//CGRect(x: 34, y: 38, width: 244, height: 92)
let RMBTSpeedGraphViewBackgroundFrame = CGRect(x: (320 - 200)/2.0, y: 0, width: 200, height: 94)
let RMBTSpeedGraphViewSeconds: NSTimeInterval = 8.0

///
class RMBTSpeedGraphView : UIView {
    
    ///
    var maxTimeInterval: NSTimeInterval = 0
    
    //
    
    private var backgroundImage: UIImage!
    private var path = UIBezierPath()
    private var firstPoint: CGPoint!
    
    private var widthPerSecond: CGFloat = RMBTSpeedGraphViewContentFrame.size.width / CGFloat(RMBTSpeedGraphViewSeconds)
    
    private var valueCount: UInt = 0
    
    private var backgroundLayer = CALayer()
    
    private var linesLayer = CAShapeLayer()
    private var fillLayer = CAShapeLayer()
    
    //
    
    ///
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    ///
    override func awakeFromNib() {
        setup()
    }
    
    ///
    func setup() {
        backgroundColor = UIColor.clearColor()
        
        backgroundImage = UIImage(named: "speed_graph_bg")
        //NSAssert(_backgroundImage.size.width == self.frame.size.width, @"Invalid bg image size");
        //NSAssert(_backgroundImage.size.height == self.frame.size.height, @"Invalid bg image size");
        
        backgroundLayer.frame = RMBTSpeedGraphViewBackgroundFrame//self.bounds
        backgroundLayer.contents = backgroundImage.CGImage
        
        layer.addSublayer(backgroundLayer)
        
        linesLayer.lineWidth = 1.0
        linesLayer.strokeColor = UIColor(rgb: 0x3da11b).CGColor//[UIColor rmbt_colorWithRGBHex:0x3da11b].CGColor
        linesLayer.lineCap = kCALineCapRound
        linesLayer.fillColor = nil
        linesLayer.frame = RMBTSpeedGraphViewContentFrame
        
        layer.addSublayer(linesLayer)
        
        fillLayer.lineWidth = 0.0
        fillLayer.fillColor = UIColor(rgb: 0x52d301, alpha: 0.4).CGColor
        
        fillLayer.frame = RMBTSpeedGraphViewContentFrame
        layer.insertSublayer(fillLayer, below: linesLayer)
    }
    
    ///
    func addValue(value: Double, atTimeInterval interval: NSTimeInterval) {
        logger.debug("ADDING VALUE: \(value) atTimeInterval: \(interval)")
        
        let maxY: CGFloat = RMBTSpeedGraphViewContentFrame.size.height
        let y = maxY * CGFloat(1.0 - value)
        
        // Ignore values that come in after max seconds
        if (interval > RMBTSpeedGraphViewSeconds) {
            return
        }
        
        let p: CGPoint = CGPointMake(CGFloat(interval) * widthPerSecond, y + RMBTSpeedGraphViewContentFrame.origin.y)
        
        if (valueCount == 0) {
            var previousPoint = p
            previousPoint.x = 0
            firstPoint = previousPoint
            path.moveToPoint(previousPoint)
        }
        path.addLineToPoint(p)
        
        valueCount = valueCount + 1
        
        linesLayer.path = path.CGPath
        
        // Fill path
        
        let fillPath = UIBezierPath()
        fillPath.appendPath(path)
        fillPath.addLineToPoint(CGPointMake(p.x, maxY + RMBTSpeedGraphViewContentFrame.origin.y))
        fillPath.addLineToPoint(CGPointMake(/*RMBTSpeedGraphViewBackgroundFrame.origin.x*/0, maxY + RMBTSpeedGraphViewContentFrame.origin.y))
        fillPath.addLineToPoint(firstPoint)
        fillPath.closePath()
        
        fillLayer.path = fillPath.CGPath
    }
    
    ///
    func clear() {
        maxTimeInterval = 0
        valueCount = 0
        path.removeAllPoints()
        linesLayer.path = path.CGPath
        fillLayer.path = nil
    }
}
