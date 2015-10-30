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
//  RMBTMapCalloutView.swift
//  RMBT
//
//  Created by Benjamin Pucher on 24.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
let kRoundedCornerRadius: CGFloat = 6.0

///
let kTriangleSize: CGSize = CGSize(width: 30.0, height: 20.0)

///
class RMBTMapCalloutView : UIView, UITableViewDataSource, UITableViewDelegate {

    ///
    @IBOutlet var tableView: UITableView!
    
    ///
    @IBOutlet var titleLabel: UILabel!
    
    ///
    private var _measurementCells, _netCells: [AnyObject]?
    
    ///
    private var measurement: RMBTMapMeasurement { // property? this never gets set? a single setter method would be better!?
        get {
            return self.measurement
        }
        set {
            self.titleLabel?.text = newValue.timeString
            
            self._measurementCells = (newValue.measurementItems as NSArray).bk_map({ (i: AnyObject!) -> AnyObject! in
                let cell = RMBTHistoryResultItemCell(style: .Value1, reuseIdentifier: nil)
                    cell.setItem(i as! RMBTHistoryResultItem)
                    cell.setEmbedded(true)
                return cell
            })
            
            self._netCells = (newValue.netItems as NSArray).bk_map({ (i: AnyObject!) -> AnyObject! in
                let cell = RMBTHistoryResultItemCell(style: .Value1, reuseIdentifier: nil)
                    cell.setItem(i as! RMBTHistoryResultItem)
                    cell.setEmbedded(true)
                return cell
            })
            
            tableView.reloadData()
            
            frameHeight = tableView.contentSize.height // !
        }
    }
    
    //
    
    ///
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    ///
    class func calloutViewWithMeasurement(measurement: RMBTMapMeasurement) -> RMBTMapCalloutView {
        let view = NSBundle.mainBundle().loadNibNamed("RMBTMapCalloutView", owner: self, options: nil)[0] as! RMBTMapCalloutView
        view.measurement = measurement
        
        return view
    }
    
    ///
    @IBAction func getMoreDetails() {
        //NSNotificationCenter.defaultCenter().postNotificationName("RMBTTrafficLightTappedNotification", object: self)
        logger.debug("Got link: \(self.measurement.openTestUUID)") // never while beeing as content of a Gooogle Maps marker
    }
    
    ///
    func setup() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    ///
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    ///
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyMask()
    }
    
    ///
    func applyMask() {
        let bottom: CGFloat = self.frameHeight - kTriangleSize.height
        let path: CGMutablePathRef = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, kRoundedCornerRadius, 0.0)
        CGPathAddLineToPoint(path, nil, self.frameWidth - kRoundedCornerRadius, 0.0)
        CGPathAddArcToPoint(path, nil, self.frameWidth, 0.0, self.frameWidth, kRoundedCornerRadius, kRoundedCornerRadius)
        CGPathAddLineToPoint(path, nil, self.frameWidth, bottom - kRoundedCornerRadius)
        CGPathAddArcToPoint(path, nil, self.frameWidth, bottom, self.frameWidth - kRoundedCornerRadius, bottom, kRoundedCornerRadius)
        CGPathAddLineToPoint(path, nil, CGRectGetMidX(self.frame) + kTriangleSize.width / 2.0, bottom)
        CGPathAddLineToPoint(path, nil, CGRectGetMidX(self.frame), self.frameHeight)
        CGPathAddLineToPoint(path, nil, CGRectGetMidX(self.frame) - kTriangleSize.width / 2.0, bottom)
        CGPathAddLineToPoint(path, nil, kRoundedCornerRadius, bottom)
        CGPathAddArcToPoint(path, nil, 0.0, bottom, 0.0, bottom - kRoundedCornerRadius, kRoundedCornerRadius)
        CGPathAddLineToPoint(path, nil, 0.0, kRoundedCornerRadius)
        CGPathAddArcToPoint(path, nil, 0.0, 0.0, kRoundedCornerRadius, 0.0, kRoundedCornerRadius)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.fillColor = UIColor.redColor().CGColor
        shapeLayer.strokeColor = nil
        shapeLayer.lineWidth = 0.0
        shapeLayer.bounds = self.bounds
        shapeLayer.anchorPoint = CGPointMake(0.0, 0.0)
        shapeLayer.position = CGPointMake(0.0, 0.0)
        
        let borderLayer = NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(shapeLayer)) as! CAShapeLayer
        borderLayer.fillColor = nil
        borderLayer.strokeColor = RMBT_DARK_COLOR.colorWithAlphaComponent(0.75).CGColor
        borderLayer.lineWidth = 3.0
        
        self.layer.addSublayer(borderLayer)
        self.layer.mask = shapeLayer
    }

// MARK: Table delegte

    ///
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            return self._measurementCells![indexPath.row] as! UITableViewCell // !
        }
        
        return self._netCells![indexPath.row] as! UITableViewCell // !
    }
    
    ///
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    ///
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? self._measurementCells!.count : self._netCells!.count
        // !
    }
    
    ///
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ?
            NSLocalizedString("map.callout.measurement", value: "Measurement", comment: "Map callout measurement") :
            NSLocalizedString("map.callout.network", value: "Network", comment: "Map callout network")
    }
    
    ///
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    
    ///
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! RMBTHistoryResultItemCell
        
        if let dtl = cell.detailTextLabel { // TODO: improve. Maybe because there are no meassurements (Got 0 measurements) no text is set
            if let t = dtl.text {
                let textSize: CGSize = t.sizeWithAttributes(["NSFontAttributeName": dtl.font]) // !!!
                return (textSize.width >= 130.0) ? 50.0 : 30.0
            }
        }
        
        return 30.0
    }
}
