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
//  RMBTPUHardwareView.swift
//  RMBT
//
//  Created by Tomáš Baculák on 20/01/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
class RMBTPUHardwareView : RMBTPopupViewButton, RMBTPopupViewButtonProtocol {

    ///
    @IBOutlet var cpuValueLabel: UILabel!

    ///
    @IBOutlet var ramValueLabel: UILabel!

    //

    ///
    let cpuMonitor = RMBTCPUMonitor()

    ///
    let ramMonitor = RMBTRAMMonitor()

    ///
    var content = RMBTPopupContentView()

    ///
    let itemNames = [
        NSLocalizedString("intro.popup.hardware.cpu",           value: "CPU",           comment: "Intro popup hardware CPU"),
        NSLocalizedString("intro.popup.hardware.system-ram",    value: "System RAM",    comment: "Intro popup hardware system RAM"),
        NSLocalizedString("intro.popup.hardware.app-ram",       value: "App RAM",       comment: "Intro popup hardware app RAM")
    ]

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
        let nibView = NSBundle.mainBundle().loadNibNamed("RMBTPUHardwareView", owner: self, options: nil)[0] as! UIView
        nibView.frame = self.bounds

        addSubview(nibView)

        delegate = self
    }

// MARK: - RMBTPopupViewButtonProtocol

    ///
    func viewWasTapped(superView: UIView!) {
        content = RMBTPopupContentView(frame: CGRectMake(0, 0, superView.boundsWidth - 10, 190))
        content.title.text = NSLocalizedString("intro.popup.hardware.usage", value: "Hardware Usage", comment: "Intro popup hardware usage")
        updateView()
    }

    ///
    override func updateView() {
        var cpuUsage: Float = -1

        if let array = cpuMonitor.getCPUUsage() as? [NSNumber] {
            cpuUsage = array[0].floatValue
        }

        let physicalMemory = NSNumber(unsignedLongLong: NSProcessInfo.processInfo().physicalMemory)
        let physicalMemoryMB = b2mb(physicalMemory.floatValue)

        let memArray = ramMonitor.getRAMUsage() as! [NSNumber] // Int64?
        let memPercentUsedF = getMemoryUsePercent(memArray[0], memArray[1], /*memArray[2]*/physicalMemory)

        let memPercentUsed = String(format: "%.0f", memPercentUsedF)
        let memPercentUsedPerApp = String(format: "%.0f", getMemoryUsePercent(memArray[3], memArray[1], /*memArray[2]*/physicalMemory))

        cpuValueLabel.textColor = colorForPercentUsage(cpuUsage)
        ramValueLabel.textColor = colorForPercentUsage(memPercentUsedF)

        cpuValueLabel.text = ("\(cpuUsage)%")
        ramValueLabel.text = ("\(memPercentUsed)%")

        content.itemsNames = itemNames
        content.itemsValues = [
            "\(cpuUsage)%",
            "\(memPercentUsed)% (\(b2mb(memArray[0].floatValue))/\(physicalMemoryMB) MB)",
            "\(memPercentUsedPerApp)% (\(b2mb(memArray[3].floatValue))/\(physicalMemoryMB) MB)"
        ]

        content.table.reloadData()

        contentView = content
    }

    ///
    private func getMemoryUsePercent(used: NSNumber, _ free: NSNumber, _ total: NSNumber) -> Float {
        return (used.floatValue / total.floatValue) * 100.0 // TODO: is calculation correct? maybe use total physical ram?
    }

    ///
    private func b2mb(bytes: Float) -> Int {
        return Int(bytes / 1024 / 1024)
    }

    ///
    private func colorForPercentUsage(percentUsage: Float) -> UIColor {
        if (percentUsage <= 50) {
            return COLOR_CHECK_GREEN
        } else if (percentUsage > 90) {
            return COLOR_CHECK_RED
        }

        return COLOR_CHECK_YELLOW
    }
}
