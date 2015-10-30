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
//  RMBTPUProtocolView.swift
//  RMBT
//
//  Created by Tomáš Baculák on 20/01/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
class RMBTPUProtocolView : RMBTPopupViewButton, RMBTPopupViewButtonProtocol {

    ///
    let itemNames = [
        NSLocalizedString("intro.popup.ip.v4-internal", value: "IPv4 Internal", comment: "Intro popup ipv4 internal"),
        NSLocalizedString("intro.popup.ip.v4-external", value: "IPv4 External", comment: "Intro popup ipv4 external"),
        NSLocalizedString("intro.popup.ip.v6-internal", value: "IPv6 Internal", comment: "Intro popup ipv6 internal"),
        NSLocalizedString("intro.popup.ip.v6-external", value: "IPv6 External", comment: "Intro popup ipv6 external")
    ]
    
    ///
    let progressString = NSLocalizedString("intro.popup.ip.connection-progress", value: "Connection in Progress...", comment: "Intro popup ip connection in progress")
    
    ///
    let noIpText = NSLocalizedString("intro.popup.ip.no-ip-text", value: "n/a", comment: "Intro popup ip no ip")
    //let connectionError = "Connection Error"
    
    ///
    var itemValues = [String?]()
    
    ///
    var content = RMBTPopupContentView()
    
    ///
    var requestFinished = false
    
    ///
    let connectivityService = ConnectivityService()
    
    ///
    @IBOutlet private var statusView4: RMBT_ProgressView!
    
    ///
    @IBOutlet private var statusView6: RMBT_ProgressView!
    
    ///
    var check_4: RMBTUICheckmarkView!
    
    ///
    var check_6: RMBTUICheckmarkView!
    
    ///
    var failure_4: RMBTUICrossView!
    
    ///
    var failure_6: RMBTUICrossView!
    
    //
    
    ///
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    ///
    func commonInit() {
        // Load xib file
        let nibView = NSBundle.mainBundle().loadNibNamed("RMBTPUProtocolView", owner: self, options: nil)[0] as! UIView
        nibView.frame = self.bounds
        
        addSubview(nibView)
        
        delegate = self
        itemValues  = [progressString, progressString, progressString, progressString]
        checkConnectivityStatus()
        
        check_4 = RMBTUICheckmarkView(frame: statusView4.frame)
        check_6 = RMBTUICheckmarkView(frame: statusView6.frame)

        failure_4 = RMBTUICrossView(frame: statusView4.frame)
        failure_6 = RMBTUICrossView(frame: statusView6.frame)
    }
    
// MARK: - Methods

    ///
    func setColorForStatusView(color: UIColor) {
        //statusView4.setStrokeColor(color)
        //statusView6.setStrokeColor(color)
        statusView4.strokeColor = color
        statusView6.strokeColor = color
    }
    
    ///
    func connectivityDidChange() {
        showProgressIndicatorViews()
        
        itemValues = [noIpText, noIpText, noIpText, noIpText]
        
        //
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) / 2) // wait half a second
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.checkConnectivityStatus()
        }
    }
    
    ///
    func checkConnectivityStatus() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.connectivityService.checkConnectivity { connectivityInfo in
                logger.debug("CONNECTIVITY INFO: \(connectivityInfo)")

                let ipv4Info = connectivityInfo.ipv4
                let ipv6Info = connectivityInfo.ipv6
                
                dispatch_async(dispatch_get_main_queue()) {
                
                    self.hideProgressIndicatorViews()

                    //
                    
                    self.addSubview(self.failure_4)
                    self.addSubview(self.failure_6)
                    
                    //
                    
                    if (ipv4Info.connectionAvailable) {
                        self.failure_4.removeFromSuperview()
                        self.addSubview(self.check_4)
                        
                        self.check_4.lineColor = (ipv4Info.nat) ? COLOR_CHECK_YELLOW : COLOR_CHECK_GREEN
                    }
                    
                    //
                    
                    if (ipv6Info.connectionAvailable) {
                        self.failure_6.removeFromSuperview()
                        self.addSubview(self.check_6)
                        
                        self.check_6.lineColor = (ipv6Info.nat) ? COLOR_CHECK_YELLOW : COLOR_CHECK_GREEN
                    }
                    
                    //
                    
                    self.itemValues = [
                        ipv4Info.internalIp ?? self.noIpText,
                        ipv4Info.externalIp ?? self.noIpText,
                        ipv6Info.internalIp ?? self.noIpText,
                        ipv6Info.externalIp ?? self.noIpText
                    ]
                    
                    if (self.popup.isShowing) {
                        self.assignValuesToPUView()
                    }
                }
            }
        }
    }
    
    ///
    private func showProgressIndicatorViews() {
        check_4.removeFromSuperview()
        check_6.removeFromSuperview()
        
        failure_4.removeFromSuperview()
        failure_6.removeFromSuperview()
        
        addSubview(statusView4)
        addSubview(statusView6)
    }
    
    ///
    private func hideProgressIndicatorViews() {
        //self.statusView4.hidden = true
        //self.statusView6.hidden = true
        
        statusView4.removeFromSuperview()
        statusView6.removeFromSuperview()
    }
    
    ///
    private func assignValuesToPUView() {
        content.itemsNames = itemNames
        content.itemsValues = itemValues
        
        content.table.reloadData()
        
        contentView = content
    }
    
    ///
    override func updateView() {
        checkConnectivityStatus()
    }
    
// MARK: - RMBTPopupViewButtonProtocol

    ///
    func viewWasTapped(superView: UIView!) {
        content = RMBTPopupContentView(frame: CGRectMake(0, 0, superView.boundsWidth - 10, 230))
        content.title.text = NSLocalizedString("intro.popup.ip.connections", value: "IP Connections", comment: "Intro popup ip connections")
        
        assignValuesToPUView()
    }
}
