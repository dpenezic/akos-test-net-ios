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
//  RMBTMapOptionsViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 19.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class RMBTMapOptionsViewController : RMBTMapSubViewController {
    
    ///
    @IBOutlet private var mapViewTypeSegmentedControl: UISegmentedControl!
    
    ///
    private var activeSubtypeAtStart: RMBTMapOptionsSubtype!
    
    //
    
    ///
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(mapOptions != nil) // TODO: is this line doubled?
        
        // Save reference to active subtype so we can detect if anything changed when going back
        activeSubtypeAtStart = mapOptions.activeSubtype
        
        mapViewTypeSegmentedControl.selectedSegmentIndex = mapOptions.mapViewType.rawValue
    }
    
    ///
    override func viewWillDisappear(animated: Bool) {
        delegate?.mapSubViewController(self, willDisappearWithChange: activeSubtypeAtStart != mapOptions.activeSubtype)
    }

// MARK: UITableViewDelegate methods

    ///
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = mapOptions.types[section]
        return type.subtypes.count
    }
    
    ///
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let type = mapOptions.types[section]
        return type.title
    }
    
    ///
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "map_subtype_cell"
        
        let type = mapOptions.types[indexPath.section]
        let subtype = type.subtypes[indexPath.row]
        
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if (cell == nil) {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        cell.textLabel?.text = subtype.title
        cell.detailTextLabel?.text = subtype.summary
        
        if (subtype == mapOptions.activeSubtype) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    ///
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let type = mapOptions.types[indexPath.section]
        let subtype = type.subtypes[indexPath.row]
        
        if (subtype == mapOptions.activeSubtype) {
            // No change, do nothing
        } else {
            let previousSection: Int = find(mapOptions.types, mapOptions.activeSubtype.type)!
            let previousRow: Int = find(mapOptions.activeSubtype.type.subtypes, mapOptions.activeSubtype)!

            mapOptions.activeSubtype = subtype
            
            tableView.reloadRowsAtIndexPaths(
                [indexPath, NSIndexPath(forRow: previousRow, inSection: previousSection)],
                withRowAnimation: .Automatic
            )
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    ///
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.mapOptions.types.count
    }
    
// MARK: other methods
    
    ///
    @IBAction func mapViewTypeSegmentedControlIndexDidChange(sender: AnyObject) {
        mapOptions.mapViewType = RMBTMapOptionsMapViewType(rawValue: mapViewTypeSegmentedControl.selectedSegmentIndex)!
    }
}
