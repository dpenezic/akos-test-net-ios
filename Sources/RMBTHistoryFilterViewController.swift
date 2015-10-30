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
//  RMBTHistoryFilterViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 25.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class RMBTHistoryFilterViewController : UITableViewController {

    ///
    var allFilters: [String:[String]]!
    
    ///
    var activeFilters: [String:[String]]!

    ///
    private var keys: [String]!
    
    ///
    private var activeIndexPaths: Set<NSIndexPath>! // TODO: use set class of swift 1.2
    
    ///
    private var allIndexPaths: Set<NSIndexPath>! // TODO: use set class of swift 1.2
    
    //
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add long tap gesture recognizer to table view. On long tap, select tapped filter, while deselecting
        // all other filters from that group.
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "tableViewDidReceiveLongPress:")
        longPressGestureRecognizer.minimumPressDuration = 0.8 // seconds
        
        tableView?.addGestureRecognizer(longPressGestureRecognizer)
        
        assert(allFilters != nil)
        
        keys = allFilters.keys.array
        
        activeIndexPaths = Set<NSIndexPath>()
        allIndexPaths = Set<NSIndexPath>()
        
        for (i, key) in enumerate(keys) {
            if let values = allFilters[key] {
            
                for (j, value) in enumerate(values) {
                    let ip = NSIndexPath(forRow: j, inSection: i)
                    
                    //allIndexPaths.addObject(ip)
                    allIndexPaths.insert(ip)
                    
                    if (activeFilters != nil) {
                        if let activeKeyValues = activeFilters[key] {
                            if let f = find(activeKeyValues, values[j]) {
                                //activeIndexPaths.addObject(ip)
                                activeIndexPaths.insert(ip)
                            }
                        }
                        
                    } else {
                        //activeIndexPaths.addObject(ip)
                        activeIndexPaths.insert(ip)
                    }
                }
            }
        }
    }
    
    ///
    override func viewWillDisappear(animated: Bool) {
        if (find(navigationController!.viewControllers as! [UIViewController], self) == nil) {
            if (activeIndexPaths == allIndexPaths || activeIndexPaths.count == 0) {
                // Everything/nothing was selected, set nil
                activeFilters = nil
            } else {
                // Re-calculate active filters
                var result = [String:[String]]()
                
                for ip in activeIndexPaths {
                    let key = keys[ip.section]
                    let value = allFilters[key]![ip.row] // !
                    
                    var entries = result[key] ?? [String]()
                    
                    entries.append(value)
                    
                    result[key] = entries
                }
                
                activeFilters = result
            }
            
            performSegueWithIdentifier("pop", sender: self)
        }
        
        super.viewWillDisappear(animated)
    }
    
// MARK: Table view data source
    
    ///
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return keys.count
    }
    
    ///
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = keys[section]
        return allFilters[key]!.count // !
    }
    
    ///
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("filter_cell", forIndexPath: indexPath) as? UITableViewCell
        
        let key = keys[indexPath.section]
        let filters = allFilters[key]! // !
        let filter = filters[indexPath.row]
        
        cell.textLabel?.text = filter
        
        let active: Bool = activeIndexPaths.contains(indexPath)
        cell.accessoryType = active ? .Checkmark : .None
        
        //cell.accessoryView?.tintColor = UIColor.blueColor()
        
        return cell
    }
    
    ///
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let key = keys[section]
        
        if (key == "networks") {
            return NSLocalizedString("history.filter.networktype", value: "Network Type", comment: "Filter section title")
        } else if (key == "devices") {
            return NSLocalizedString("history.filter.device", value: "Device", comment: "Filter section title")
        } else {
            return key
        }
    }
    
// MARK: Table view delegate
    
    ///
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (activeIndexPaths.contains(indexPath)) {
            // Turn off
            
            // ..but check if this is the only active index in this section. If yes, then do nothing.
            var lastActiveInSection = true
            for i in activeIndexPaths {
                if (i.section == indexPath.section && i.row != indexPath.row) {
                    lastActiveInSection = false
                    break
                }
            }
            
            if (lastActiveInSection) {
                self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
                return
            }
            
            activeIndexPaths.remove(indexPath)
        } else {
            // Turn on
            activeIndexPaths.insert(indexPath)
        }
        
        self.tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
// MARK: Long press handler
    
    ///
    func tableViewDidReceiveLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state == .Began) {
            let p: CGPoint = gestureRecognizer.locationInView(tableView)
            
            if let tappedIndexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(p) {
                
                // Deactivate all entries in this section, exception long-tapped row
                for i in allIndexPaths {
                    if (i.section == tappedIndexPath.section) {
                        activeIndexPaths.remove(i)
                    }
                }
                
                activeIndexPaths.insert(tappedIndexPath)
                
                tableView?.reloadData()
            }
        }
    }
    
// MARK: IBActions
    
    ///
    @IBAction func clear(sender: AnyObject) {
        activeIndexPaths.union(allIndexPaths)
        //activeIndexPaths.setSet(allIndexPaths)
        
        tableView?.reloadData()
    }
}
