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
//  RMBTSideMenuController.swift
//  RMBT
//
//  Created by Tomáš Baculák on 14/01/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
class RMBTSideMenuController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    ///
    @IBOutlet var menuTable: UITableView!

    ///
    @IBOutlet var bottomView: UIView!

    ///
    let menuItems = ["home", "history", "map", "statistics", "help"]

    ///
    private var prevSelectedRow: Int!

    //

    ///
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = BACKGROUND_COLOR
        menuTable.backgroundColor = BACKGROUND_COLOR
        bottomView.backgroundColor = BACKGROUND_COLOR

        // select home
        menuTable.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Top)
    }

// MARK: - Navigation UITableViewDataSource / UITableViewDelegate

    ///
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    ///
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    ///
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(menuItems[indexPath.row]) as! UITableViewCell
        
        cell.backgroundColor = BACKGROUND_COLOR

        let bgColorView = UIView()
        bgColorView.backgroundColor = COLOR_LIGHT_BLUE

        cell.selectedBackgroundView = bgColorView
        cell.imageView?.frame = CGRectMake(15, 25, 40, 40)

        return cell
    }

    ///
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if prevSelectedRow == nil {
            prevSelectedRow = 0 // first screen is home
        } else {
            prevSelectedRow = menuTable.indexPathForSelectedRow()?.row ?? -1 // is only -1 if info or settings are active
        }

        return indexPath
    }

// MARK: - Methods

    ///
    @IBAction func deselectCellInTable() {
        if let index = menuTable.indexPathForSelectedRow() {
            menuTable.deselectRowAtIndexPath(index, animated: true)
        }

        prevSelectedRow = -1 // is only -1 if info or settings are active
    }

// MARK: segue methods

    ///
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if (identifier == "pushHomeViewController"          && prevSelectedRow == 0 ||
            identifier == "pushHistoryViewController"       && prevSelectedRow == 1 ||
            identifier == "pushMapViewController"           && prevSelectedRow == 2 ||
            identifier == "pushStatisticsViewController"    && prevSelectedRow == 3 ||
            identifier == "pushHelpViewController"          && prevSelectedRow == 4) {

            revealViewController().revealToggleAnimated(true)
            return false
        }

        return true
    }
}
