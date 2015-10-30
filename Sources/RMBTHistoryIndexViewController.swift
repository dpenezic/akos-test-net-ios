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
//  RMBTHistoryIndexViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 26.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

//static NSUInteger const kBatchSize = 25;

///
let kBatchSize: Int = 25 // Entries to fetch from server

//static NSUInteger const kSyncSheetRequestCodeButtonIndex = 0;
//static NSUInteger const kSyncSheetEnterCodeButtonIndex = 1;
//static NSUInteger const kSyncSheetCancelButtonIndex = 2;

///
enum SyncSheetButtonIndex: Int {
    case RequestCode = 1
    case EnterCode = 2
    case CancelButton = 0
}

///
enum RMBTHistoryIndexViewControllerState: Int {
    case Loading
    case Empty
    case FilteredEmpty
    case HasEntries
}

///
class RMBTHistoryIndexViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, SWRevealViewControllerDelegate {

    ///
    @IBOutlet private var tableView: UITableView!
    
    ///
    @IBOutlet private var loadingLabel: UILabel!
    
    ///
    @IBOutlet private var emptyLabel: UILabel!
    
    ///
    @IBOutlet private var emptyFilteredLabel: UILabel!
    
    ///
    @IBOutlet private var clearActiveFiltersButton: UIButton!
    
    ///
    @IBOutlet private var sideBarButton: UIBarButtonItem!
    
    ///
    @IBOutlet private var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    ///
    private var filterButtonItem: UIBarButtonItem!

    ///
    private var syncButtonItem: UIBarButtonItem!
    
    //
    private var enterCodeAlertView: UIAlertView!
    
    ///
    private var testResults: [RMBTHistoryResult]!
    
    ///
    private var nextBatchIndex: Int = 0
    
    ///
    private var allFilters: [String:[String]]!
    
    ///
    private var activeFilters: [String:[String]]!
    
    ///
    private var loading: Bool = false
    
    ///
    private var tableViewController: UITableViewController!
    
    ///
    private var firstAppearance: Bool = false
    
    ///
    private var showingLastTestResult: Bool = false

    //
    
    ///
    private var state: RMBTHistoryIndexViewControllerState! {
        //get { return self.state }
        didSet {
            loadingLabel.hidden = true
            loadingActivityIndicatorView.hidden = true
            emptyLabel.hidden = true
            emptyFilteredLabel.hidden = true
            tableView.hidden = true
            filterButtonItem.enabled = false
            clearActiveFiltersButton.hidden = true
            
            if (state == .Empty) {
                emptyLabel.hidden = false
            } else if (state == .FilteredEmpty) {
                emptyFilteredLabel.hidden = false
                clearActiveFiltersButton.hidden = false
                filterButtonItem.enabled = true
            } else if (state == .HasEntries) {
                tableView.hidden = false
                filterButtonItem.enabled = true
            } else if (state == .Loading) {
                loadingLabel.hidden = false
                loadingActivityIndicatorView.hidden = false
            }
        }
    }
    
    //
    
    ///
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    ///
    override func awakeFromNib() {
        //super.awakeFromNib()
        
        navigationController?.tabBarItem.selectedImage = UIImage(named: "tab_history_selected")
    }
    
    ///
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (firstAppearance) {
            firstAppearance = false
            
            refresh()
            refreshFilters()
        } else {
            if let selectedIndexPath = tableView?.indexPathForSelectedRow() {
                tableView?.deselectRowAtIndexPath(selectedIndexPath, animated: true)
            } else if (showingLastTestResult) {
                // Note: This shouldn't be necessary once we have info required for index view in the
                // test result object. See -displayTestResult.
                
                showingLastTestResult = false
                
                refresh()
                refreshFilters()
            }
        }
    }
    
    ///
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        // Set the gesture
        view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        
        revealViewController().delegate = self
    }
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideBarButton.target = revealViewController()
        sideBarButton.action = "revealToggle:"
        
        syncButtonItem = UIBarButtonItem(title: NSLocalizedString("history.uibar.sync", value: "Sync", comment: "History index sync button"), style: .Bordered, target: self, action: "sync:")
        filterButtonItem = UIBarButtonItem(title: NSLocalizedString("history.uibar.filter", value: "Filter", comment: "History index filter button"), style: .Bordered, target: self, action: "getFilter:")
        
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.rightBarButtonItems = [filterButtonItem, syncButtonItem]
        
        //
        
        firstAppearance = true
        
        tableViewController = UITableViewController(style: .Plain)
        tableViewController.tableView = self.tableView
        tableViewController.refreshControl = UIRefreshControl()
        
        tableViewController.didMoveToParentViewController(self)
        tableViewController.refreshControl?.addTarget(self, action: "refreshFromTableView", forControlEvents: .ValueChanged)
        
        // for integration testing
        tableView.accessibilityLabel = "HistoryTable"
    }
    
    ///
    func refreshFilters() {
        // Wait for UUID to be retrieved
        let controlServer = ControlServer.sharedControlServer
        
        controlServer.performWithUUID({
            controlServer.getSettings({
                self.allFilters = controlServer.historyFilters
            }, error: { error, info in
                // TODO: handle error
            })
        }, error: { error, info in
            // TODO: handle error
        })
    }
    
    ///
    func refresh() {
        state = .Loading
        testResults = [RMBTHistoryResult]()
        nextBatchIndex = 0
        
        getNextBatch()
    }
    
    /// Invoked by pull to refresh
    func refreshFromTableView() {
        tableViewController.refreshControl?.beginRefreshing()
        
        testResults = [RMBTHistoryResult]()
        nextBatchIndex = 0
        
        getNextBatch()
    }
    
    ///
    func getNextBatch() {
        assert(nextBatchIndex != NSNotFound, "Invalid batch")
        assert(!loading, "getNextBatch Called twice")
        
        loading = true
        
        let firstBatch: Bool = (nextBatchIndex == 0)
        let offset: Int = nextBatchIndex * kBatchSize
        
        ControlServer.sharedControlServer.getHistoryWithFilters(activeFilters, length: UInt(kBatchSize), offset: UInt(offset), success: { response in
            let responseArray = response as! [[String:AnyObject]]
            
            let oldCount = self.testResults.count
            
            var indexPaths = [NSIndexPath]() //NSMutableArray(capacity: responseArray.count)
            var results = [RMBTHistoryResult]() // NSMutableArray(capacity: responseArray.count)
            
            for r in responseArray {
                results.append(RMBTHistoryResult(response: r))
                indexPaths.append(NSIndexPath(forRow: oldCount - 1 + results.count, inSection: 0))
            }
            
            // We got less results than batch size, this means this was the last batch
            if (results.count < kBatchSize) {
                self.nextBatchIndex = NSNotFound
            } else {
                self.nextBatchIndex += 1
            }
            
            self.testResults.extend(results)
            //self.testResults.addObjectsFromArray(results)
            
            if (firstBatch) {
                self.state = (self.testResults.count == 0) ? ((self.activeFilters != nil) ? .FilteredEmpty : .Empty) : .HasEntries
                self.tableView?.reloadData()
            } else {
                self.tableView?.beginUpdates()
                
                if (self.nextBatchIndex == NSNotFound) {
                    self.tableView?.deleteRowsAtIndexPaths([NSIndexPath(forRow: oldCount, inSection: 0)], withRowAnimation: .Fade)
                }
                
                if (indexPaths.count > 0) {
                    self.tableView?.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                }
                
                self.tableView?.endUpdates()
            }
            
            self.loading = false
            self.tableViewController.refreshControl?.endRefreshing()
            
        }) { error, info in
            // TODO: handle loading error
        }
    }
    
    ///
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row >= (testResults.count - 5)) {
            if (!loading && nextBatchIndex != NSNotFound) {
                getNextBatch()
            }
        }
    }
    
    ///
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result = testResults.count
        
        if (nextBatchIndex != NSNotFound) {
            result += 1
        }
        
        return result
    }

    ///
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row >= testResults.count) {
            // Loading cell
            var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("RMBTHistoryLoadingCell") as? UITableViewCell
            
            // We have to start animating manually, because after cell has been reused the activity indicator seems to stop
            (cell?.viewWithTag(100) as! UIActivityIndicatorView).startAnimating()
    
            return cell
        } else {
            
            var cell: RMBTHistoryIndexCell! = tableView.dequeueReusableCellWithIdentifier("RMBTHistoryTestResultCell") as? RMBTHistoryIndexCell
            if (cell == nil) {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "RMBTHistoryTestResultCell") as? RMBTHistoryIndexCell
            }
    
            let testResult = testResults[indexPath.row]
    
            cell.networkTypeLabel?.text    = testResult.networkTypeServerDescription
            cell.dateLabel?.text           = testResult.formattedTimestamp()
            cell.deviceModelLabel?.text    = testResult.deviceModel
            cell.downloadSpeedLabel?.text  = testResult.downloadSpeedMbpsString // suppose to be 1 float digit
            cell.uploadSpeedLabel?.text    = testResult.uploadSpeedMbpsString
            cell.pingLabel?.text           = testResult.shortestPingMillisString
    
            let networkTypeServerDescription = testResult.networkTypeServerDescription
            
            if (networkTypeServerDescription == "WLAN") {
                cell.typeImageView?.image = UIImage(named: "history-wifi")
            } else if (networkTypeServerDescription == "LAN" || networkTypeServerDescription == "CLI") {
                cell.typeImageView?.image = UIImage(named: "history-lan")
            } else {
                cell.typeImageView?.image = UIImage(named: "history-mobile")
            }
            
            return cell
        }
    }
    
    ///
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let result = testResults[indexPath.row] as RMBTHistoryResult
        performSegueWithIdentifier("show_result", sender: result)
    }
    
// MARK: filter
    
    ///
    func getFilter(sender: AnyObject) {
        performSegueWithIdentifier("show_filter", sender: nil)
    }
    
// MARK: Sync
    
    ///
    func sync(sender: AnyObject) {
        let title: String = NSLocalizedString("history.sync.merge", value: "To merge history from two different devices, request the sync code on one device and enter it on another device", comment: "Sync intro text")
        
        let actionSheet = UIActionSheet(title: title,
                                        delegate: self,
                                        cancelButtonTitle: NSLocalizedString("general.alertview.cancel", value: "Cancel", comment: "Sync dialog button"),
                                        destructiveButtonTitle: nil,
                                        otherButtonTitles:  NSLocalizedString("history.sync.code.request", value: "Request code", comment: "Sync dialog button"),
                                                            NSLocalizedString("history.sync.code.enter", value: "Enter code", comment: "Sync dialog button"))
        
        actionSheet.showInView(view)
    }
    
    ///
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        logger.debug("BUTTON INDEX: \(buttonIndex)")
        
        if (buttonIndex == SyncSheetButtonIndex.RequestCode.rawValue) {
            
            ControlServer.sharedControlServer.getSyncCode({ response in
                self.displaySyncCode(response as! String)
            }, error: { error, info in
                // TODO: handle error
            })
            
        } else if (buttonIndex == SyncSheetButtonIndex.EnterCode.rawValue) {
            
            enterCodeAlertView = UIAlertView(title: NSLocalizedString("history.sync.code.enter-text", value: "Enter sync code:", comment: "Sync alert title"),
                                                    message: "",
                                                    delegate: self,
                                                    cancelButtonTitle: NSLocalizedString("general.alertview.cancel", value: "Cancel", comment: "Sync alert button"),
                                                    otherButtonTitles: NSLocalizedString("history.sync.sync", value: "Sync", comment: "Sync alert button"))
            
            enterCodeAlertView.alertViewStyle = .PlainTextInput
            enterCodeAlertView.show()
            
        } else {
            assert(buttonIndex == SyncSheetButtonIndex.CancelButton.rawValue, "Action sheet dismissed with unknown button index")
        }
    }
    
    ///
    private func displaySyncCode(code: String) {
        UIAlertView.bk_showAlertViewWithTitle(NSLocalizedString("history.sync.code-text", value: "Sync Code", comment: "Display code alert title"),
            message: code,
            cancelButtonTitle: NSLocalizedString("general.alertview.ok", value: "OK", comment: "Display code alert button"),
            otherButtonTitles: [NSLocalizedString("history.sync.code.copy", value: "Copy code", comment: "Display code alert button")],
            handler: { (alertView: UIAlertView!, buttonIndex: Int) -> Void in
                if (buttonIndex == 1) {
                    // Copy
                    UIPasteboard.generalPasteboard().string = code
                } // else just dismiss
            }
        )
    }
    
    ///
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if (alertView == enterCodeAlertView && buttonIndex == 1) {
            
            let code = alertView.textFieldAtIndex(0)!.text.uppercaseString
            
            ControlServer.sharedControlServer.syncWithCode(code, success: {
                self.displaySyncSuccess()
            }, error: { error, info in
                let title = (error.userInfo!["msg_title"]) as! String
                let text = (error.userInfo!["msg_text"]) as! String
                
                UIAlertView.bk_showAlertViewWithTitle(title, message: text, cancelButtonTitle: NSLocalizedString("general.alertview.dismiss", value: "Dismiss", comment: "Alert view button"), otherButtonTitles: nil, handler: nil)
            })
        }
    }

    ///
    private func displaySyncSuccess() {
        UIAlertView.bk_showAlertViewWithTitle(NSLocalizedString("general.alertview.success", value: "Success", comment: "Sync success alert title"),
            message: NSLocalizedString("history.sync.success-message", value: "History synchronisation was successful.", comment: "Sync success alert msg"),
            cancelButtonTitle: NSLocalizedString("general.alertview.reload", value: "Reload", comment: "Sync success button"),
            otherButtonTitles: nil,
            handler: { (alertView: UIAlertView!, buttonIndex: Int) in
                self.refresh()
                self.refreshFilters()
            }
        )
    }
    
// MARK: SWRevealViewControllerDelegate
    
    ///
    func revealControllerPanGestureBegan(revealController: SWRevealViewController!) {
        tableView?.scrollEnabled = false
    }

    ///
    func revealControllerPanGestureEnded(revealController: SWRevealViewController!) {
        tableView?.scrollEnabled = true
    }
    
    ///
    func revealController(revealController: SWRevealViewController!, didMoveToPosition position: FrontViewPosition) {
        let isPosLeft = position == .Left
        
        tableView?.scrollEnabled = isPosLeft
        tableView?.allowsSelection = isPosLeft
        
        if (isPosLeft) {
            view.removeGestureRecognizer(revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
        } else {
            view.removeGestureRecognizer(revealViewController().edgeGestureRecognizer())
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
    }
    
// MARK: Segues
    
    ///
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "show_result") {
        
            let rvc = segue.destinationViewController as! RMBTHistoryResultViewController
            rvc.historyResult = sender as? RMBTHistoryResult
            
        } else if (segue.identifier == "show_filter") {
            
            let filterVC = segue.destinationViewController as! RMBTHistoryFilterViewController
            filterVC.allFilters = allFilters
            filterVC.activeFilters = activeFilters
        }
    }
    
    ///
    @IBAction func updateFilters(segue: UIStoryboardSegue) {
        let filterVC = segue.sourceViewController as! RMBTHistoryFilterViewController

        //logger.debug("UPDATE FILTERS")
        //logger.debug("OLD FILTERS: \(activeFilters)")
        
        activeFilters = filterVC.activeFilters

        //logger.debug("NEW FILTERS: \(activeFilters)")
        
        refresh()
    }
    
    ///
    @IBAction func clearActiveFilters(sender: AnyObject) {
        activeFilters = nil
        refresh()
    }
}
