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
//  RMBTQoSTestDetailVC.swift
//  RMBT
//
//  Created by Tomas Baculak on 11/02/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
class RMBTQoSTestDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    ///
    @IBOutlet var testDetailTable: UITableView!
    
    ///
    var qosTestResult = [AnyObject]()
    
    ///
    var descArray = [AnyObject]()
    
    ///
    var detailTestText = ""
    
    ///
    let statusSucceededString = NSLocalizedString("history.result.qos.details.succeeded", value: "SUCCEEDED", comment: "Test succeeded")
    
    ///
    let statusFailedString = NSLocalizedString("history.result.qos.details.failed", value: "FAILED", comment: "Test failed")

    //
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = COLOR_BACKGROUND_COLOR
        //self.testDetailTable.backgroundColor = COLOR_BACKGROUND_COLOR

        var testDict = self.qosTestResult[0] as! NSDictionary
        self.detailTestText = testDict.valueForKey("test_desc") as! String
        // 0
        self.descArray.append(testDict.valueForKey("test_summary") as! String)
        var status:String!
        
        let testStatus = testDict.valueForKey("failure_count") as! NSNumber
        
        if (testStatus == 0) {
            status = self.statusSucceededString
        } else {
            status = self.statusFailedString
        }
        // 1
        self.descArray.append(status)
        
        if (self.qosTestResult.count == 2) {
            
            let testDesc = self.qosTestResult[1] as! NSArray
            
            var resultDescArray = [String]()
            
            for (var i = 0; i < testDesc.count; i++) {
                
                let resultDesc = testDesc[i] as! NSDictionary
                let resultTestIds = resultDesc.valueForKey("uid") as! NSArray
                let test_uid = testDict.valueForKey("uid") as! NSNumber
                
                for (var a = 0; a < resultTestIds.count; a++) {
                    
                    let testUID = resultTestIds[a] as! NSNumber
                
                    if (testUID == test_uid) {
                        
                        let testDescItem = testDesc[i] as! NSDictionary
                        
                        resultDescArray.append(testDescItem.valueForKey("desc") as! String)
                        
                        if (self.descArray.count == 3) {
                            self.descArray.removeLast()
                        }
                        
                        // 2
                        self.descArray.append(resultDescArray)
                    }
                }
            }
        }
    }
    
// MARK: - UITableViewDataSource/UITableViewDelegate

    ///
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.descArray.count == 3 ? 3 : 2
    }
    
    ///
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
            case 0:
                return 1
            case 1:
                return (descArray.count == 3) ? descArray[2].count : 1
            case 2:
                return 1
            default:
                return 0
        }
    }
    
    ///
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let detailsString = NSLocalizedString("history.result.qos.details", value: "DETAILS", comment: "Details")
        
        switch (section) {
            case 0:
                return NSLocalizedString("history.result.qos.details.description", value: "DESCRIPTION", comment: "Description")
            case 1:
                // TODO: rewrite this header message. there can be multiple success and/or errors in this test...
                return (descArray.count == 3) ? descArray[1] as! String : detailsString
            case 2:
                return detailsString
            default:
                return "-unknown section-"
        }
    }
    
    ///
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    ///
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (descArray.count == 3) {
            return (indexPath.section == 2) ? 350 : 50
        } else {
            return (indexPath.section == 1) ? 350 : 50
        }
    }
    
    ///
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "qos_test_detail_cell_desc")
            cell.textLabel?.text = self.descArray[0] as? String
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            
            // colors definition
            //cell.backgroundColor = COLOR_BACKGROUND_COLOR
            //cell.textLabel?.textColor = COLOR_TEXT_LIGHT_COLOR
            
            return cell
        }

        if (indexPath.section == 1) {
            
            if (self.descArray.count == 3) {
            
                let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "qos_test_detail_cell_status")
                let iTestDesc = self.descArray[2] as? [String]
                var statusColor = UIColor()
                
                if let item = iTestDesc?[indexPath.row] as String! {
                    cell.textLabel?.text = iTestDesc?[indexPath.row]
                    cell.textLabel?.adjustsFontSizeToFitWidth = true
                    cell.textLabel?.numberOfLines = 3
                }
                
                statusColor = self.getColorForRelevantState()
                //cell.textLabel?.textColor = COLOR_TEXT_LIGHT_COLOR
                cell.backgroundColor = statusColor
                
                return cell
                
            } else {
                let cell = self.testDetailTable.dequeueReusableCellWithIdentifier("qos_test_detail_cell_params") as! RMBTQoSDetailsTestParamsTVCell
                cell.testParamsTextView.text = self.detailTestText
                
                // colors
                //cell.testParamsTextView.textColor = COLOR_TEXT_LIGHT_COLOR
                //cell.backgroundColor = COLOR_BACKGROUND_COLOR
                
                return cell
            }
        } else {
 
            let cell = self.testDetailTable.dequeueReusableCellWithIdentifier("qos_test_detail_cell_params") as! RMBTQoSDetailsTestParamsTVCell
            cell.testParamsTextView.text = self.detailTestText
            
            // colors
            //cell.testParamsTextView.textColor = COLOR_TEXT_LIGHT_COLOR
            //cell.backgroundColor = COLOR_BACKGROUND_COLOR
            
            return cell
        }
    }
    
    ///
    private func getColorForRelevantState() -> UIColor {
        return self.descArray[1] as! String == self.statusSucceededString ? COLOR_CHECK_GREEN : COLOR_CHECK_RED
    }
}
