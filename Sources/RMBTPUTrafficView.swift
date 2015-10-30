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
//  RMBTPUTrafficView.swift
//  RMBT
//
//  Created by Tomáš Baculák on 21/01/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
class RMBTPUTrafficView : RMBTPopupViewButton, RMBTPopupViewButtonProtocol {
    
    ///
    @IBOutlet var uploadView: RMBTUITrafficView!
    
    ///
    @IBOutlet var downloadView: RMBTUITrafficView!
    
    //
    
    ///
    let itemNames = [
        NSLocalizedString("intro.popup.traffic.upload",     value: "Upload traffic",    comment: "Intro popup traffic upload"),
        NSLocalizedString("intro.popup.traffic.download",   value: "Download traffic",  comment: "Intro popup traffic download")
    ]

    ///
    let SPEED_FORMAT_M = "Mbps"
    
    ///
    let SPEED_FORMAT_K = "kbps"
    
    ///
    var itemValues = [String?]()
    
    ///
    var content = RMBTPopupContentView()
    
    ///
    var netStats = RMBTTrafficCounter()
    
    ///
    var lastDict = [String:Int]()

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
        lastDict = netStats.getTrafficCount() as! [String:Int]
        
        // Load xib file
        var nibView = NSBundle.mainBundle().loadNibNamed("RMBTPUTrafficView", owner: self, options: nil)[0] as! UIView
        nibView.frame = bounds

        addSubview(nibView)
        
        downloadView.viewOrientation = true
        delegate = self
    }
    
// MARK: - RMBTPopupViewButtonProtocol

    ///
    func viewWasTapped(superView: UIView!) {
        content = RMBTPopupContentView(frame: CGRectMake(0, 0, superView.boundsWidth - 10, 140))
        content.title.text = NSLocalizedString("intro.popup.traffic.background", value: "Background Traffic", comment: "Intro popup traffic background")
        updateView()
    }
    
    ///
    override func updateView() {
        let newDict = netStats.getTrafficCount() as! [String:Int] // TODO: sometimes EXC_BAD_INSTRUCTION occurs on this line
        
        // calc difference
        let wifi_sent_difference: Int = newDict["wifi_sent"]! - lastDict["wifi_sent"]!
        let wifi_received_difference: Int = newDict["wifi_received"]! - lastDict["wifi_received"]!
        
        let wwan_sent_difference: Int = newDict["wwan_sent"]! - lastDict["wwan_sent"]!
        let wwan_received_difference: Int = newDict["wwan_received"]! - lastDict["wwan_received"]!
        
        let sent_difference = wifi_sent_difference + wwan_sent_difference
        let received_difference = wifi_received_difference + wwan_received_difference
        
        let sent_classification = TrafficClassification.classifyBytesPerSecond(Int64(sent_difference))
        let received_classification = TrafficClassification.classifyBytesPerSecond(Int64(received_difference))
        
        uploadView.signalStrength = sent_classification.rawValue
        downloadView.signalStrength = received_classification.rawValue
        
        let downtraffic = String(format: "%f %@", Float(received_difference * 8) / (1024 * 1024), SPEED_FORMAT_M)
        let uptraffic = String(format: "%f %@", Float(sent_difference * 8) / (1024 * 1024), SPEED_FORMAT_M)
        
        lastDict = newDict
        
        itemValues = [downtraffic, uptraffic]
        //logger.debug("TRAFFIC: \(itemValues)")
        
        content.itemsNames = itemNames
        content.itemsValues = itemValues
        
        content.table.reloadData()
        
        contentView = content
    }
}
