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
//  RMBTPULocationView.swift
//  RMBT
//
//  Created by Tomáš Baculák on 21/01/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
class RMBTPULocationView : RMBTPopupViewButton, RMBTPopupViewButtonProtocol, CLLocationManagerDelegate {
    
    ///
    let locationManager = CLLocationManager()
    
    ///
    var location = CLLocation()
    
    ///
    var content = RMBTPopupContentView()
    
    ///
    let itemNames = [
        NSLocalizedString("intro.popup.location.position",  value: "Position",  comment: "Intro popup location position"),
        NSLocalizedString("intro.popup.location.accuracy",  value: "Accuracy",  comment: "Intro popup location accuracy"),
        NSLocalizedString("intro.popup.location.age",       value: "Age",       comment: "Intro popup location age"),
        //NSLocalizedString("intro.popup.location.source", value: "Source", comment: "Intro popup location"),
        NSLocalizedString("intro.popup.location.altitude",  value: "Altitude",  comment: "Intro popup location altitude")
    ]
    
    ///
    let locError = "error"
    
    ///
    var age = 0
    
    //
    
    ///
    required init (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    ///
    override init (frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    ///
    private func commonInit() {
        // Load xib file
        let nibView = NSBundle.mainBundle().loadNibNamed("RMBTPULocationView", owner: self, options: nil)[0] as! UIView
        nibView.frame = self.bounds

        addSubview(nibView)
        
        delegate = self
        
        //
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 3.0
    }
    
// MARK: - CLLocationManagerDelegate
    
    ///
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        location = newLocation
        age = 0
        assignNewLocationToPUView()
    }
    
    ///
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        content.itemsValues = [locError, locError, locError, locError, locError]
    }
    
// MARK: - RMBTPopupViewButtonProtocol

    ///
    func viewWasTapped(superView: UIView!) {
        RMBTLocationTracker.sharedTracker.startAfterDeterminingAuthorizationStatus {
            
            if (RMBTLocationTracker.sharedTracker.startIfAuthorized()) {
            
                self.content = RMBTPopupContentView(frame: CGRectMake(0, 0, superView.boundsWidth - 10, /*250*/230))
                self.content.title.text = NSLocalizedString("intro.popup.location", value: "Location", comment: "Intro popup location")
                self.assignNewLocationToPUView()
            } else {
            
                let alertView = UIAlertView(
                    title: NSLocalizedString("intro.location.question.title", value: "Using Location", comment: "Intro location question title"),
                    message: NSLocalizedString("intro.location.question.message", value: "To get the location service, please enable it in settings!", comment: "Intro location question message"),
                    delegate: nil,
                    cancelButtonTitle: NSLocalizedString("general.alertview.ok", value: "OK", comment: "alertview ok button")
                )
                
                alertView.show() // TODO: go to settings
            }
        }
    }
    
// MARK: - Methods
    
    ///
    override func updateView() {
        age++
        
        if (popup.isShowing) {
            assignNewLocationToPUView()
        }
    }
    
    ///
    func assignNewLocationToPUView() {
        content.itemsNames = itemNames
        
        let formattedArray = location.rmbtFormattedArray()
        content.itemsValues = [formattedArray[0], formattedArray[1], "\(age) s"/*, "Network"*/, formattedArray[3]]
        
        content.table.reloadData()
        
        contentView = content
    }
    
    ///
    func updateContentTableTimeCell() {
        let ageCellIndexPath = NSIndexPath(forItem: 2, inSection: 0)

        let anAgeCell = content.table.cellForRowAtIndexPath(ageCellIndexPath) as! RMBTPUTableViewCell
        
        let updateCellArray = [ageCellIndexPath]
        
        content.table.beginUpdates()
        
        anAgeCell.valueLabel.text = "\(age) s"
        
        content.table.reloadRowsAtIndexPaths(updateCellArray, withRowAnimation: UITableViewRowAnimation.Fade)
        content.table.endUpdates()
    }
}
