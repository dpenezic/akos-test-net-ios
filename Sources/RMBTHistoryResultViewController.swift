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
//  RMBTHistoryResultViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 23.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class RMBTHistoryResultViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {

    ///
    @IBOutlet weak var tableView: UITableView!

    ///
    var historyResult: RMBTHistoryResult?
    
    ///
    var isModal: Bool?
    
    ///
    var showMapOption = false
    
    ///
    var qosResults: NSDictionary?
   
    ///
    var statusMessage: String!
    
    //
    
    ///
    @IBAction func share(sender: AnyObject) {
        var activities = [AnyObject]()
        var items = [AnyObject]()
        
        if let shareText = historyResult?.shareText {
            items.append(shareText)
        }
        
        if let shareURL = historyResult?.shareURL {
            items.append(shareURL)
            activities.append(TUSafariActivity())
        }
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: activities)
        activityViewController.setValue(RMBTAppTitle(), forKey: "subject")
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
// MARK: - Object Life Cycle

    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let historyResult = self.historyResult {
            
            let uuid = historyResult.uuid
            
            historyResult.ensureBasicDetails() {
                assert(historyResult.dataState != .Index, "Result not filled with basic data")
                
                if (CLLocationCoordinate2DIsValid(historyResult.coordinate)) {
                    self.showMapOption = true
                }
                
                self.tableView.reloadData()
                
                //////////////////////
                ControlServer.sharedControlServer.getQOSHistoryResultWithUUID(uuid, success: { response in
    
                    logger.debug("RETURN FROM QOS HISTORY RESULT")
                    //logger.debug("\(response)")
    
                    self.qosResults = response as? NSDictionary
    
                    if (self.qosResults?.count > 1) {
                        
                        let details = self.qosResults?.valueForKey("testresultdetail") as! NSArray
                        //logger.debug("\(details)")
    
                        var a = 0
                        var i = 0
    
                        for (i; i < details.count; i++) {
                            let item = details[i] as! NSDictionary
                            let failure = item.objectForKey("failure_count") as! NSNumber
    
                            if (failure == 0) {
                                a++
                            }
                        }
    
                        let percentage = 100 * a/i
    
                        self.statusMessage = String(format: "%i%% (%i/%i)", percentage, a, i)
                    }
                    
                    self.tableView.reloadData()
                    
                }) { error, info in
                    logger.debug("BLOODY ERROR FROM QOS HISTORY RESULT")
                    logger.debug("\(error, info)")
                    
                    self.statusMessage = String(format: "%i", error.hashValue)
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    ///
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "trafficLightTapped", name: "RMBTTrafficLightTappedNotification", object: nil)
    }
    
    ///
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    ///
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "show_result_details") {
            let rdvc = segue.destinationViewController as! RMBTHistoryResultDetailsViewController
            rdvc.historyResult = self.historyResult
            
        } else if (segue.identifier == "show_map") {
            let coordinateIsValid: Bool = CLLocationCoordinate2DIsValid(self.historyResult!.coordinate)
            
            assert(coordinateIsValid, "Invalid coordinate but map button was enabled")
            
            if (coordinateIsValid) {
                // Set map options
                let selection: RMBTMapOptionsSelection = RMBTSettings.sharedSettings().mapOptionsSelection
                selection.activeFilters = nil
                selection.overlayIdentifier = nil
                selection.subtypeIdentifier = RMBTNetworkTypeIdentifier(self.historyResult!.networkType) // !
                
                let mvc: RMBTMapViewController = segue.destinationViewController as! RMBTMapViewController
                mvc.hidesBottomBarWhenPushed = true
                mvc.initialLocation = CLLocation(latitude: self.historyResult!.coordinate.latitude, longitude: historyResult!.coordinate.longitude) // !
            }
        } else if (segue.identifier == "pushQoSTestResultsView") {
            let qtView = segue.destinationViewController as! RMBTQoSViewController
            qtView.qosTestResults = self.qosResults
        }
    }
    
// MARK: - UITableViewDataSource/UITableViewDelegate

    ///
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (historyResult?.dataState == RMBTHistoryResultDataState.Index) ? 0 : 5 // compiler segfault if RMBTHistoryResultDataState.Index is removed
    }
    
    ///
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45
    }
    
    ///
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 2) {
            
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "detail_test_cell")
            
            if (indexPath.row == 0) {
                cell.textLabel?.text = NSLocalizedString("history.result.time", value: "Time", comment: "History result time")
                cell.userInteractionEnabled = false
                
                let formatter = NSDateFormatter()
                formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
                
                let timeLabel = UILabel(frame: CGRectMake(0, 0, cell.boundsWidth / 1.5, cell.boundsHeight))
                timeLabel.textAlignment = .Right
                
                if let time = self.historyResult?.timeString {
                    timeLabel.text = time
                    cell.accessoryView = timeLabel
                }
            } else {
                cell.textLabel?.text = NSLocalizedString("history.result.more-details", value: "More details", comment: "History result more details")
                cell.userInteractionEnabled = true
                cell.accessoryType = .DisclosureIndicator
            }

            return cell
        } else if (indexPath.section == 3) {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "qos_test_cell")
            let error = self.qosResults?.valueForKey("error") as? NSArray
            
            if (indexPath.row == 0) {
            
                cell.textLabel?.text = NSLocalizedString("history.result.qos.results", value: "Results", comment: "History result qos results")
                cell.userInteractionEnabled = false
                
                if (error?.count > 0) {
                    self.statusMessage = error?.objectAtIndex(0) as? String
                }
                
                let resultLabel = UILabel(frame: CGRectMake(0, 0, cell.boundsWidth / 2, cell.boundsHeight))
                resultLabel.textAlignment = .Right
                resultLabel.text = self.statusMessage
                resultLabel.adjustsFontSizeToFitWidth = true
                
                cell.accessoryView = resultLabel
            } else {
                
                if (self.qosResults == nil || error?.count > 0) {
                    cell.userInteractionEnabled = false
                    
                    logger.debug("QOS RESULTS MISSING")
                } else {
                    cell.userInteractionEnabled = true
                }
            
                cell.textLabel?.text = NSLocalizedString("history.result.qos.results-detail", value: "Results detail", comment: "History result qos results detail")
                cell.accessoryType = .DisclosureIndicator
            }
            
            return cell
        } else if (indexPath.section == 4) {
        
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "map_test_cell")
            
            if (indexPath.row == 0) {
                
                cell.textLabel?.text = (self.showMapOption) ?
                    NSLocalizedString("history.result.map.latitude", value: "Latitude", comment: "History result map latitude") :
                    NSLocalizedString("history.result.map.result", value: "Map Result", comment: "History result map result")
                
                cell.textLabel?.minimumScaleFactor = 0.7
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                
                let latLabel = UILabel(frame: CGRectMake(0, 0, cell.boundsWidth / 2, cell.boundsHeight))
                latLabel.textAlignment = .Right
                
                // leave this code as fallback if locationString is not available
                if let latitude = self.historyResult?.coordinate.latitude {
                    latLabel.text = String(format: "%f", latitude)
                }
                
                if let locationString = historyResult?.locationString { // TODO: use single if let statement (swift 1.2)
                    let splittedLocationString = split(locationString) { $0 == " " }
                    
                    if (splittedLocationString.count > 0) {
                        latLabel.text = splittedLocationString[0]
                    }
                }
                
                cell.accessoryView = latLabel
                
            } else if (indexPath.row == 1) {
                
                cell.textLabel?.text = NSLocalizedString("history.result.map.longitude", value: "Longitude", comment: "History result map result")
                
                let longLabel = UILabel(frame: CGRectMake(0, 0, cell.boundsWidth / 2, cell.boundsHeight))
                longLabel.textAlignment = .Right
                
                // leave this code as fallback if locationString is not available
                if let longitute = self.historyResult?.coordinate.longitude {
                    longLabel.text = String(format: "%f", longitute)
                }
                
                if let locationString = historyResult?.locationString { // TODO: use single if let statement (swift 1.2)
                    let splittedLocationString = split(locationString) { $0 == " " }
                    
                    if (splittedLocationString.count > 1) {
                        longLabel.text = splittedLocationString[1]
                    }
                }
                
                cell.accessoryView = longLabel
                
            } else if (indexPath.row == 2) {
                
                cell.textLabel?.text = NSLocalizedString("history.result.map.accuracy", value: "Accuracy", comment: "History result map accuracy")
            
                let accLabel = UILabel(frame: CGRectMake(0, 0, cell.boundsWidth / 2, cell.boundsHeight))
                accLabel.textAlignment = .Right
                accLabel.text = "-"
                
                if let locationString = historyResult?.locationString { // TODO: use single if let statement (swift 1.2)
                    if let startIndex = find(locationString, "(")?.successor() {
                        if let endIndex = find(locationString, ")") {
                            accLabel.text = locationString.substringWithRange(Range<String.Index>(start: startIndex, end: endIndex))
                        }
                    }
                }
                
                cell.accessoryView = accLabel
                
            } else if (indexPath.row == 3) {
                cell.textLabel?.text = NSLocalizedString("history.result.map.show", value: "Show map", comment: "History result map show")
                cell.accessoryType = .DisclosureIndicator
            }
            
            if let location = self.historyResult?.coordinate {
            
                if (self.showMapOption) {
                    cell.userInteractionEnabled = (indexPath.row == 3)
                } else {
                    
                    cell.userInteractionEnabled = false
                    
                    let errLabel = UILabel(frame: CGRectMake(0, 0, cell.boundsWidth / 2, cell.boundsHeight))
                    errLabel.textAlignment = .Right
                    errLabel.text = NSLocalizedString("history.result.map.invalid-coordinates", value: "Invalid coordinates", comment: "History result map invalid coordinates")
                    
                    errLabel.minimumScaleFactor = 0.7
                    errLabel.adjustsFontSizeToFitWidth = true
                    
                    cell.accessoryView = errLabel
                }
            }

            return cell
        } else {
            let item = self.itemsForSection(indexPath.section)[indexPath.row] as! RMBTHistoryResultItem
            
            let cell = RMBTHistoryItemCell(style: .Default, reuseIdentifier: "history_result")
            cell.setItem(item)
            
            return cell
        }
    }
    
    ///
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
            case 0: return self.itemsForSection(section).count
            case 1: return self.itemsForSection(section).count
            case 2: return 2
            case 3: return 2
            case 4: return (self.showMapOption) ? 4 : 1
            default: return 0
        }
    }
    
    ///
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
            case 0:
                return NSLocalizedString("history.result.headline.measurement", value: "Measurement", comment: "History result section title")
                
            case 1:
                return NSLocalizedString("history.result.headline.network", value: "Network", comment: "History result section detail")
                
            case 2:
                return NSLocalizedString("history.result.headline.details", value: "Details", comment: "Details options")
                
            case 3:
                return NSLocalizedString("history.result.headline.qos", value: "Quality Of Service", comment: "QoS options")
                
            case 4:
                return NSLocalizedString("history.result.headline.map", value: "Map", comment: "Map options")
                
            default:
                return "-unknown section-"
        }
    }
    
    ///
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    ///
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        switch (indexPath.section) {
            //case 0:
            //    break
            //case 1:
            //    break
            case 2:
                performSegueWithIdentifier("show_result_details", sender: nil)
            case 3:
                performSegueWithIdentifier("pushQoSTestResultsView", sender: nil)
            case 4:
                performSegueWithIdentifier("show_map", sender: nil)
            default:
                break
        }
    }
    
// MARK: - Class Methods

    ///
    private func trafficLightTapped(n: NSNotification) {
        self.presentModalBrowserWithURLString(RMBT_HELP_RESULT_URL)
    }

    ///
    private func itemsForSection(sectionIndex: Int) -> [AnyObject] {
        assert(sectionIndex <= 5, "Invalid section")
        return (sectionIndex == 0) ? historyResult!.measurementItems : historyResult!.netItems // !
    }
}
