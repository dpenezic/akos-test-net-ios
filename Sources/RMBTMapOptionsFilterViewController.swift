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
//  RMBTMapOptionsFilterViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 22.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class RMBTMapOptionsFilterViewController : RMBTMapSubViewController {
    
    ///
    private var activeFiltersAtStart: [RMBTMapOptionsFilterValue]!
    
    ///
    private var activeOverlayAtStart: RMBTMapOptionsOverlay!
    
    //
    
    ///
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Store reference to active filters at start so we can determine if anything changed
        activeFiltersAtStart = activeFilters()
        activeOverlayAtStart = mapOptions.activeOverlay
    }
    
    ///
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let changed = (activeOverlayAtStart != mapOptions.activeOverlay) || (activeFilters() != activeFiltersAtStart) // TODO: sometimes EXC_BAD_INSTRUCTION when closing...
        
        delegate?.mapSubViewController(self, willDisappearWithChange: changed)
    }
    
// MARK: Table view data source
    
    ///
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mapOptions.activeSubtype.type.filters.count + 1 /* overlays */
    }
    
    ///
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return mapOptions.overlays.count
        } else {
            return filterForSection(section).possibleValues.count
        }
    }
    
    ///
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "map_filter_cell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if (cell == nil) {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }

        if (indexPath.section == 0) {
            // Overlays
            let overlay: RMBTMapOptionsOverlay = mapOptions.overlays[indexPath.row] as RMBTMapOptionsOverlay // !
            
            cell.textLabel?.text = overlay.localizedDescription
            cell.detailTextLabel?.text = nil
            
            cell.accessoryType = (mapOptions.activeOverlay == overlay) ? .Checkmark : .None
        } else {
            // Filters
            let filter = filterForSection(indexPath.section)
            let value = filter.possibleValues[indexPath.row] as RMBTMapOptionsFilterValue
            
            cell.textLabel?.text = value.title
            
            if (value.summary == value.title) {
                cell.detailTextLabel?.text = nil
            } else {
                cell.detailTextLabel?.text = value.summary
            }
            
            cell.accessoryType = (filter.activeValue == value) ? .Checkmark : .None
        }
        
        return cell
    }
    
    ///
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return NSLocalizedString("map.options.filter.overlay", value: "Overlay", comment: "Table section header title")
        } else {
            return filterForSection(section).title.capitalizedString
        }
    }
    
// MARK: Table view delegate

    ///
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            let overlay = mapOptions.overlays[indexPath.row] as RMBTMapOptionsOverlay
            if (overlay == mapOptions.activeOverlay) {
                // do nothing
            } else {
                let previousRow: Int = (mapOptions.overlays as NSArray).indexOfObject(mapOptions.activeOverlay)
                //find(self.mapOptions.overlays, self.mapOptions.activeOverlay)
                
                mapOptions.activeOverlay = overlay
                
                tableView.reloadRowsAtIndexPaths([indexPath, NSIndexPath(forRow: previousRow, inSection: indexPath.section)], withRowAnimation: .Automatic)
            }
        } else {
            let filter = filterForSection(indexPath.section)
            let value = filterValueForIndexPath(indexPath)
            
            if (value == filter.activeValue) {
                // Do nothing
            } else {
                let previousRow: Int = (filter.possibleValues as NSArray).indexOfObject(filter.activeValue)
                //find(filter.possibleValues, filter.activeValue)
                
                filter.activeValue = value
                
                tableView.reloadRowsAtIndexPaths([indexPath, NSIndexPath(forRow: previousRow, inSection: indexPath.section)], withRowAnimation: .Automatic)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
// MARK: Filter accessor
    
    ///
    func filterForSection(section: Int) -> RMBTMapOptionsFilter {
        return mapOptions.activeSubtype.type.filters[section - 1] as RMBTMapOptionsFilter
    }
    
    ///
    func filterValueForIndexPath(indexPath: NSIndexPath) -> RMBTMapOptionsFilterValue {
        let filter: RMBTMapOptionsFilter = filterForSection(indexPath.section)
        return filter.possibleValues[indexPath.row] as RMBTMapOptionsFilterValue
    }
    
// MARK: Others
    
    ///
    func activeFilters() -> [RMBTMapOptionsFilterValue] {
        return map(mapOptions.activeSubtype.type.filters, { (f) -> RMBTMapOptionsFilterValue in
            return f.activeValue
        })
        
        //return (mapOptions.activeSubtype.type.filters as NSArray).bk_map({ (f: AnyObject!) in // TODO: improve
        //    return f.activeValue
        //}) as [RMBTMapOptionsFilterValue]
    }
}
