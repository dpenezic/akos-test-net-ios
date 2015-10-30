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
//  RMBTHistoryResultDetailsViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 18.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class RMBTHistoryResultDetailsViewController: UITableViewController {

    ///
    private class _TableViewCell : UITableViewCell {

        ///
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        }

        ///
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }

    ///
    private class __TableViewCell : UITableViewCell {

        ///
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        }

        ///
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }

    //

    ///
    var historyResult: RMBTHistoryResult?

    //

    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(/*UITableViewCell*/_TableViewCell.self, forCellReuseIdentifier: "history_result_detail") // style value1
        tableView.registerClass(/*UITableViewCell*/__TableViewCell.self, forCellReuseIdentifier: "history_result_detail_subtitle") // style subtitle

        //NSParameterAssert(self.historyResult)
        if let historyResult = self.historyResult {
            historyResult.ensureFullDetails() {
                self.tableView.reloadData()
            }
        }

        tableView.accessibilityLabel = "Test Result Detail Table View"
    }

    ///
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.historyResult!.dataState != .Full ? 0 : 1 // TODO: historyResult!
    }

    ///
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.historyResult!.fullDetailsItems.count // TODO: historyResult!
    }

    ///
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        if let historyResult = self.historyResult {
            let item = historyResult.fullDetailsItems[indexPath.row] as RMBTHistoryResultItem

            if (count(item.title) > 25 || count(item.value) > 25) {
                cell = tableView.dequeueReusableCellWithIdentifier("history_result_detail_subtitle", forIndexPath: indexPath) as! UITableViewCell

                cell.detailTextLabel?.textColor = UIColor.grayColor()
                cell.detailTextLabel?.font = UIFont.systemFontOfSize(16)//cell.detailTextLabel?.font.fontWithSize(15)
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("history_result_detail", forIndexPath: indexPath) as! UITableViewCell
            }

            cell.textLabel?.text = item.title
            cell.textLabel?.numberOfLines = 3
            cell.textLabel?.minimumScaleFactor = 0.7
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            //cell.textLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle

            cell.detailTextLabel?.text = item.value
            cell.detailTextLabel?.numberOfLines = 3
            cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
            cell.detailTextLabel?.minimumScaleFactor = 0.7
            //cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("history_result_detail", forIndexPath: indexPath) as! UITableViewCell // needed?
        }

        return cell
    }

    ///
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let historyResult = self.historyResult {
            let item: RMBTHistoryResultItem = historyResult.fullDetailsItems[indexPath.row] as RMBTHistoryResultItem

            return UITableViewCell.rmbtApproximateOptimalHeightForText(item.title, detailText: item.value)
        }

        return 0
    }
}
