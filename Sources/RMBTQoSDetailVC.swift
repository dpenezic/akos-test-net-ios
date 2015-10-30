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
//  RMBTQoSDetailViewController.swift
//  RMBT
//
//  Created by Tomas Baculak on 11/02/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
class RMBTQoSDetailVC : UIViewController, UITableViewDelegate, UITableViewDataSource {

    ///
    @IBOutlet var detailTable: UITableView!

    ///
    var qosTestResults = [String:AnyObject]()

    /// test description [0], test status [1]
    var testItems = [[AnyObject]]()

    ///
    var testDescription = ""

    ///
    var testDetails = [AnyObject]()

    //

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.view.backgroundColor = COLOR_BACKGROUND_COLOR
        //self.detailTable.backgroundColor = COLOR_BACKGROUND_COLOR

        let dict = self.qosTestResults["serverDesc"] as! NSDictionary
        let tArray = self.qosTestResults["tests"] as! NSArray

        self.testDescription = dict.valueForKey("desc") as! String

        for (var i = 0; i < tArray.count; i++) {
            let aDict = tArray[i] as! NSDictionary
            var status = true
            var sArray = [AnyObject]()

            if (aDict.valueForKey("failure_count") as! NSNumber != 0) {
                status = false
            }

            let testDesc = aDict.valueForKey("test_summary") as! String

            sArray.append(testDesc)
            sArray.append(status)

            self.testItems.append(sArray)
        }

        self.detailTable.reloadData()
    }

// MARK: - Navigation

    ///
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailTestVC = segue.destinationViewController as! RMBTQoSTestDetailVC

        detailTestVC.qosTestResult = self.testDetails
        detailTestVC.navigationItem.title = String(format: "%@ %@", detailTestVC.navigationItem.title!, sender as! String)
    }

// MARK: - UITableViewDataSource/UITableViewDelegate

    ///
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    ///
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 1 : testItems.count
    }

    ///
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
            case 0:
                return NSLocalizedString("history.qos.headline.details", value: "DETAILS", comment: "Details")
            case 1:
                return NSLocalizedString("history.qos.headline.tests", value: "TESTS", comment: "Tests")
            default:
                return ""
        }
    }

    ///
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    ///
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    ///
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let itemTests = self.qosTestResults["tests"] as! NSMutableArray

        if (self.qosTestResults["desc"] != nil) {
            self.testDetails = [itemTests[indexPath.row] as! NSDictionary, self.qosTestResults["desc"] as! NSMutableArray]
        } else {
            self.testDetails = [itemTests[indexPath.row] as! NSDictionary]
        }

        //
        let aCell = self.detailTable.cellForRowAtIndexPath(indexPath) as UITableViewCell!

        self.performSegueWithIdentifier("pushTestDetailVC", sender: aCell.textLabel?.text)

        return indexPath
    }

    ///
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell

        if (indexPath.section == 0) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "qos_test_cell_details")
            cell.textLabel?.text = self.testDescription
            cell.textLabel?.numberOfLines = 5
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            //cell.textLabel?.font = UIFont (name: MAIN_FONT, size: 12)
            cell.userInteractionEnabled = false

        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "qos_test_cell_tests")

            let testStr = NSLocalizedString("history.qos.detail.test", value: "Test", comment: "Name of a test")

            cell.textLabel?.text = String(format: "\(testStr) #%i", indexPath.row + 1)
            cell.detailTextLabel?.text = self.testItems[indexPath.row][0] as? String
            //cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
            cell.detailTextLabel?.numberOfLines = 0
            // color definition
            //cell.detailTextLabel?.textColor = COLOR_TEXT_LIGHT_COLOR
            //cell.textLabel?.highlightedTextColor = UIColor.whiteColor()
            //cell.detailTextLabel?.highlightedTextColor = UIColor.whiteColor()

            var statusView = UIView(frame: CGRectMake(0, 0, 26, 26))

            if (self.testItems[indexPath.row][1] as! Bool) {
                statusView = RMBTUICheckmarkView(frame: statusView.frame)
            } else {
                statusView = RMBTUICrossView(frame: statusView.frame)
            }

            cell.accessoryView = statusView
        }

        //cell.backgroundColor = COLOR_BACKGROUND_COLOR
        //cell.textLabel?.textColor = COLOR_TEXT_LIGHT_COLOR

        return cell
    }
}
