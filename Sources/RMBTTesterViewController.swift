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
//  RMBTTesterViewController.swift
//  RMBT
//
//  Created by Tomáš Baculák on 03/02/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
struct QosTestStatus {
    var testType: QOSTestType
    var status: Bool
}

///
struct MTestStatus {
    var testName: String
    var status: Bool
    var value: String
}

///
protocol RMBTTesterViewControllerProtocol {

    ///
    func testViewController(controller: RMBTTesterViewController, didFinishWithResult: RMBTHistoryResult)
}

///
class RMBTTesterViewController : UIViewController, RMBTTestRunnerDelegate, UIAlertViewDelegate, UIViewControllerTransitioningDelegate, UITableViewDataSource, UITableViewDelegate, QualityOfServiceTestDelegate {

    ///
    private var testRunner = RMBTTestRunner()

    ///
    private var alertView = UIAlertView()

    ///
    var recentResults: RMBTHistoryResult!

    ///
    private var finishedPercentage = 0

    ///
    private var loopCounter = 1

    ///
    private var loopMode = false

    ///
    private var loopMaxTests = RMBT_TEST_LOOPMODE_LIMIT

    ///
    private var loopMinDelay = RMBT_TEST_LOOPMODE_WAIT_BETWEEN_RETRIES_S

    ///
    private var loopSkipQOS = false

    /// is quality test running
    private var qtMode = false

// MARK: CPU/RAM

    /// used for updating cpu and memory usage
    private var hardwareUsageTimer: NSTimer?

    ///
    let cpuMonitor = RMBTCPUMonitor()

    ///
    let ramMonitor = RMBTRAMMonitor()

// MARK: Views

    ///
    var progressGaugeView: RMBTGaugeView!

    ///
    var speedGaugeView: RMBTGaugeView!

    ///
    var qualityGaugeView: RMBTGaugeView!

    //

    ///
    var serverValues = [String]()

    ///
    var processValues = [String]()

    ///
    var h_tableTitles = [String]()

    ///
    var m_tableTitles = [MTestStatus]()

    ///
    var q_tableTitles = [QosTestStatus]()

    ///
    var qosManager: QualityOfServiceTest!

    //

    ///
    var delegate: RMBTTesterViewControllerProtocol?

// MARK: Network name and type

    ///
    //@IBOutlet var networkTypeLabel: UILabel!

    ///
    @IBOutlet var networkNameLabel: UILabel!

// MARK: Progress

    ///
    @IBOutlet var progressLabel: UILabel!

    ///
    @IBOutlet var progressGaugePlaceholderView: UIImageView!

// MARK: Results

    ///
    @IBOutlet var pingResultLabel: UILabel!

    ///
    @IBOutlet var downResultLabel: UILabel!

    ///
    @IBOutlet var upResultLabel: UILabel!

// MARK: Speed chart

    ///
    @IBOutlet var speedGaugePlaceholderView: UIImageView!

    ///
    @IBOutlet var arrowImageView: UIImageView!

    ///
    @IBOutlet var speedLabel: UILabel!

    ///
    @IBOutlet private var qosLabel: UILabel!

    ///
    @IBOutlet var resultsTable: UITableView!

    ///
    private var resultsTableSpeedtestFrame: CGRect!

    ///
    private var resultsTableQOSFrame: CGRect!

// MARK: graph

    /// Show Graph for devices newer than iphone 4s, i.e. devices that have a height of 568 points -> RMBTIsRunningOnWideScreen
    //@IBOutlet var graphView: CustomizableGraphView!

    ///
    //var graph: SimpleGraph?

    @IBOutlet var speedGraphView: RMBTSpeedGraphView!

    //

    ///
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let settings = RMBTSettings.sharedSettings()

        // check if loop mode is enabled and prepare values
        if (settings.debugUnlocked && settings.debugLoopMode) {

            if (settings.debugLoopModeMaxTests > 0) {
                loopMaxTests = Int(settings.debugLoopModeMaxTests)
            }

            if (settings.debugLoopModeMinDelay > 0) {
                loopMinDelay = Int(settings.debugLoopModeMinDelay)
            }

            loopSkipQOS = settings.debugLoopModeSkipQOS
        }
    }

    ///
	override func viewDidLoad() {
		super.viewDidLoad()

        view.backgroundColor = BACKGROUND_COLOR
        
        resultsTable.backgroundColor = TEST_TABLE_BACKGROUND_COLOR
        speedGraphView.backgroundColor = TEST_TABLE_BACKGROUND_COLOR
        
        h_tableTitles = ["Server", "IP"]

        // Init
        var initStruct = MTestStatus(testName: "", status: false, value: "")

        initStruct.testName = NSLocalizedString("test.phase.init",      value: "Init",      comment: "Test init phase")
        self.m_tableTitles.append(initStruct)

        initStruct.testName = NSLocalizedString("test.phase.ping",      value: "Ping",      comment: "Test ping phase")
        self.m_tableTitles.append(initStruct)

        initStruct.testName = NSLocalizedString("test.phase.download",  value: "Download",  comment: "Test download phase")
        self.m_tableTitles.append(initStruct)

        initStruct.testName = NSLocalizedString("test.phase.upload",    value: "Upload",    comment: "Test upload phase")
        self.m_tableTitles.append(initStruct)
        //////////

        //NSParameterAssert(self.progressGaugePlaceholderView);
        progressGaugeView = RMBTGaugeView(frame: progressGaugePlaceholderView.frame, name: "progress", startAngle: 204, endAngle: 485, ovalRect: CGRectMake(0, 0, 175.0, 175.0))
        progressGaugePlaceholderView.removeFromSuperview()
        progressGaugePlaceholderView = nil // release the placeholder view
        view.addSubview(progressGaugeView)

        //NSParameterAssert(self.speedGaugePlaceholderView);
        speedGaugeView = RMBTGaugeView(frame: speedGaugePlaceholderView.frame, name: "speed", startAngle: 1, endAngle: 299, ovalRect: CGRectMake(0, 0, 175.0, 175.0))
        speedGaugePlaceholderView.removeFromSuperview()
        speedGaugePlaceholderView = nil // release the placeholder view
        view.addSubview(speedGaugeView)

        loopMode = RMBTSettings.sharedSettings().debugUnlocked && RMBTSettings.sharedSettings().debugLoopMode // TODO: show loop mode text in view
        // Only clear connectivity and location labels once at start to avoid blinking during test restart
        networkNameLabel.text = "n/a"

        // disable user interaction on table (table is self scrolling)
        resultsTable.userInteractionEnabled = false

        resultsTableSpeedtestFrame = resultsTable.frame
        resultsTableQOSFrame = resultsTable.frame
        //

        //
        if (RMBTIsRunningOnWideScreen()) {

            // setup graphview
            //var graphViewFrame = graphView.frame

            //graph = SimpleGraph(frame: graphViewFrame)

            //graphView.addGraph(graph!)

            // decrease size of resultsTable
            resultsTableSpeedtestFrame.size.height -= /*graphViewFrame*/speedGraphView.frame.height

            resultsTable.frame = resultsTableSpeedtestFrame
        } else {
            //graphView.hidden = true
            speedGraphView.hidden = true
        }
        
        //

        startTest()
	}

    ///
	override func viewWillAppear(animated: Bool) {
		UIApplication.sharedApplication().bk_performBlock({ sender in
			UIApplication.sharedApplication().idleTimerDisabled = true
        }, afterDelay: 5.0)
	}

    ///
    override func viewDidDisappear(animated: Bool) {
        UIApplication.sharedApplication().idleTimerDisabled = false
    }

// MARK: - UITableViewDataSource/UITableViewDelegate

    ///
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return (self.qtMode) ? 1 : 2
	}

    ///
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (self.qtMode) ? self.q_tableTitles.count : ((section == 0) ? 2 : m_tableTitles.count)
    }

    ///
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }

    ///
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.qtMode) {
            let item = self.q_tableTitles[indexPath.row] as QosTestStatus

            let cell = RMBTTestTableViewCell_Q(style: UITableViewCellStyle.Default, reuseIdentifier: "QOS_Cell_New")
            cell.titleLabel.text = item.testType.description

            //logger.debug("TQoS test: %@ status: %@", item.testType.description, item.status)

            if (item.status) {
                cell.aTestDidFinish()
            }

            return cell
        } else {
            if (indexPath.section == 0) {
                let cell = self.resultsTable.dequeueReusableCellWithIdentifier("H_Cell") as! RMBTTestTableViewCell_H
                    cell.titleLabel.text = self.h_tableTitles[indexPath.row]

                if (!self.serverValues.isEmpty) {
                    cell.valueLabel.text = self.serverValues[indexPath.row]
                }

                return cell
            } else {

                let cell = self.resultsTable.dequeueReusableCellWithIdentifier("M_Cell") as! RMBTTestTableViewCell_M
                    cell.titleLabel.text = self.m_tableTitles[indexPath.row].testName
                    cell.assignResultValue(self.m_tableTitles[indexPath.row].value, final: self.m_tableTitles[indexPath.row].status)

                return cell
            }
        }
    }

    ///
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {

    }

    ///
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

// MARK: - UITable Methods

    ///
    func updateStatusWithValue(text: String, phase:RMBTTestRunnerPhase, final: Bool) {
        var myIP: NSIndexPath!

        switch phase {
            case .Init:
                myIP = NSIndexPath(forItem: 0, inSection: 1)

            case .Latency:
                myIP = NSIndexPath(forItem: 1, inSection: 1)

            case .Down:
                myIP = NSIndexPath(forItem: 2, inSection: 1)

            case .Up:
                myIP = NSIndexPath(forItem: 3, inSection: 1)

            default:
                return
        }

        m_tableTitles[myIP.row].value = text
        m_tableTitles[myIP.row].status = final

        if let cell = resultsTable.cellForRowAtIndexPath(myIP) as? RMBTTestTableViewCell_M {
            cell.assignResultValue(text, final: final)

            resultsTable.scrollToRowAtIndexPath(myIP, atScrollPosition: UITableViewScrollPosition.Top, animated: true)

            //let updateCellArray = [myIP]

            //self.resultsTable.beginUpdates()
            //self.resultsTable.reloadRowsAtIndexPaths(updateCellArray, withRowAnimation:.None)
            //self.resultsTable.endUpdates()

            //self.resultsTable.reloadData()
        }
    }

    ///
    private func swapViews() {
        if (qtMode) { // prepare for qos tests

            qualityGaugeView = RMBTGaugeView(frame: speedGaugeView.frame, name: "test", startAngle: 0, endAngle: 310, ovalRect: CGRectMake(0, 0, 175.0, 175.0))
            qualityGaugeView.clockWiseOrientation = false
            speedGaugeView.hidden = true//removeFromSuperview()
            speedLabel.hidden = true//.removeFromSuperview()

            //
            //graphView.hidden = true
            speedGraphView.hidden = true
            //

            speedLabel.hidden = true
            qosLabel.hidden = false

            //self.speedGaugeView = nil // release the previous view view
            view.addSubview(qualityGaugeView)
        } else { // prepare for normal speed test // TODO: reset more views

            if (qualityGaugeView != nil) {
                qualityGaugeView.hidden = true
            }

            speedGaugeView.hidden = false
            speedLabel.hidden = false

            //
            resultsTable.frame = resultsTableSpeedtestFrame
            //

            //
            if (RMBTIsRunningOnWideScreen()) {
                //graphView.hidden = false
                speedGraphView.hidden = false
            }
            //

            speedLabel.hidden = false
            qosLabel.hidden = true
        }
    }

// MARK: -  QualityOfServiceTestDelegate

    ///
    func qualityOfServiceTestDidStart(test: QualityOfServiceTest) {
        arrowImageView.removeFromSuperview()
        swapViews()
        qualityGaugeView.value = 0
    }

    ///
    func qualityOfServiceTestDidStop(test: QualityOfServiceTest) {
        // TODO?
    }

    ///
    func qualityOfServiceTest(test: QualityOfServiceTest, didFinishWithResults results: [QOSTestResult]) {
        if (loopMode) {
            restartTestAfterCountdown(loopMinDelay)
        } else {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) / 2) // wait half a second // Int64(1 * Double(NSEC_PER_SEC))

            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.delegate?.testViewController(self, didFinishWithResult: self.recentResults)
                return
            }
        }
    }

    ///
    func qualityOfServiceTest(test: QualityOfServiceTest, didFailWithError: NSError!) {
        if (loopMode) {
            restartTestAfterCountdown(loopMinDelay)
        } else {
            // show error message and go back to intro

            displayAlertWithTitle(NSLocalizedString("general.alertview.error", value: "Error", comment: "Alert view title"),
                message: NSLocalizedString("test.qos.failed", value: "Quality Of Service Test did fail.", comment: "Alert view message"),
                cancelButtonTitle: NSLocalizedString("general.alertview.dismiss", value: "Dismiss", comment: "Alert view button"),
                otherButtonTitle: "",
                cancelHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                },
                otherHandler: {

                }
            )
        }
    }

    // get all recently avalaible services
    func qualityOfServiceTest(test: QualityOfServiceTest, didFetchTestTypes testTypes: [QOSTestType]) {

        // Init
        for (var i = 0; i < testTypes.count; i++) {
            let initStruct = QosTestStatus(testType: testTypes[i], status: false)
            q_tableTitles.append(initStruct)
        }

        dispatch_async(dispatch_get_main_queue()) {
            self.resultsTable.frame = self.resultsTableQOSFrame // reset frame (this would be too early in swapViews() because no qos titles would be present)

            self.resultsTable.reloadData()

            // scroll back to top
            self.resultsTable.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        }
    }

    ///
    func qualityOfServiceTest(test: QualityOfServiceTest, didFinishTestType testType: QOSTestType) {

        /*if let ips = self.resultsTable.indexPathsForVisibleRows() as? [NSIndexPath] {
            if (ips.count > 0) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.resultsTable.scrollToRowAtIndexPath(ips[ips.count - 1], atScrollPosition: UITableViewScrollPosition.Bottom, animated: true) // scroll
                }
            }
        }*/

        // Find the index
        for (var i = 0; i < self.q_tableTitles.count; i++) {

            let item = self.q_tableTitles[i]

            if (item.testType == testType && !item.status) {

                self.q_tableTitles[i].status = true

                //logger.debug("FINISHED: %@", item.testType.description)

                let cellIndex = NSIndexPath(forItem: i, inSection: 0)

                if let cell = self.resultsTable.cellForRowAtIndexPath(cellIndex) as? RMBTTestTableViewCell_Q {

                    cell.aTestDidFinish()

                    let theLastIndex = NSIndexPath(forItem: self.q_tableTitles.count - 1, inSection: 0)

                    dispatch_async(dispatch_get_main_queue()) {
                        // visual
                        self.resultsTable.moveRowAtIndexPath(cellIndex, toIndexPath: theLastIndex) // reorder
                    }

                    // data
                    q_tableTitles.append(self.q_tableTitles.removeAtIndex(i))
                }
            }
        }
    }

    ///
    func qualityOfServiceTest(test: QualityOfServiceTest, didProgressToValue: Float) {
        qualityGaugeView.value = didProgressToValue

        finishedPercentage = Int(50 + 50 * didProgressToValue)
        displayPercentage(finishedPercentage)
    }

// MARK: UIViewControllerTransitioningDelegate

    ///
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return RMBTVerticalTransitionController()
    }

    ///
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let v = RMBTVerticalTransitionController()
        v.reverse = true

        return v
    }

// MARK: - RMBTTestRunnerDelegate

    ///
    func testRunnerDidDetectConnectivity(connectivity: RMBTConnectivity!) {
        let networkName = connectivity.networkName ?? NSLocalizedString("intro.network.connection.name-unknown", value: "Unknown", comment: "unknown wifi or operator name")

        if let cd = connectivity.testResultDictionary()["telephony_network_sim_operator"] as? String {
            networkNameLabel.text = "\(networkName), \(connectivity.networkTypeDescription), \(cd)"
        } else {
            networkNameLabel.text = "\(networkName), \(connectivity.networkTypeDescription)"
        }
    }

    ///
    func testRunnerDidDetectLocation(location: CLLocation!) {

    }

    ///
    func testRunnerDidStartPhase(phase: RMBTTestRunnerPhase) {
        dispatch_async(dispatch_get_main_queue()) {

            switch (phase) {
                case .Init, .Wait:
                    self.serverValues = [self.testRunner.testParams.serverName as String, self.testRunner.testParams.clientRemoteIp as String]
                    self.resultsTable.reloadData()

                    // scroll resultsTable down to ping (not needed anymore because table is big enough to show ping)
                    //self.resultsTable.scrollToRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                case .Down:
                    self.arrowImageView.image = UIImage(named: "test_arrow_down")
                case .Up:
                    self.arrowImageView.image = UIImage(named: "test_arrow_up")

                    //
                    //self.graph?.clear()
                    self.speedGraphView.clear()
                    //

                default:
                    break
            }
        }
    }

    ///
    func testRunnerDidFinishPhase(phase: RMBTTestRunnerPhase) {
        if (phase == .Latency) {
            updateStatusWithValue(RMBTMillisecondsStringWithNanos(testRunner.testResult.medianPingNanos), phase: phase, final: true)
        } else if (phase == .Down) {
            speedGaugeView.value = 0
            updateStatusWithValue(RMBTSpeedMbpsString(testRunner.testResult.totalDownloadHistory.totalThroughput.kilobitsPerSecond()), phase: phase, final: true)
        } else if (phase == .Up) {
            updateStatusWithValue(RMBTSpeedMbpsString(testRunner.testResult.totalUploadHistory.totalThroughput.kilobitsPerSecond()), phase: phase, final: true)
        }

        finishedPercentage = percentageAfterPhase(phase)
        displayPercentage(finishedPercentage)

        assert(finishedPercentage <= 100, "Invalid percentage")
    }

    ///
    func testRunnerDidFinishInit(time: UInt64) {
        updateStatusWithValue("", phase: .Init, final: true)
    }

    ///
    func testRunnerDidUpdateProgress(progress: Float, inPhase phase: RMBTTestRunnerPhase) {
        let phasePercentage = Float(percentageForPhase(phase)) * progress
        let totalPercentage = Float(finishedPercentage) + phasePercentage
        assert(totalPercentage <= 100, "Invalid percentage")

        displayPercentage(Int(totalPercentage))
    }

    ///
    func testRunnerDidMeasureThroughputs(throughputs: [AnyObject]!, inPhase phase: RMBTTestRunnerPhase) {

        var kbps: UInt32 = 0
        var l: Double    = 0


        if let throughputs = throughputs as? [RMBTThroughput] {

            //logger.debug("THROUGHPUTS COUNT: \(throughputs.count)")

            for (var i = 0; i < throughputs.count; i++) {
                let t = throughputs[i]
                kbps = t.kilobitsPerSecond()

                //
                l = RMBTSpeedLogValue(min(kbps, /*RMBT_Test_MAX_CHART_KBPS*/200_000))

                //graph?.addValue(l, atPosition: Double(t.endNanos) / Double(NSEC_PER_SEC))
                speedGraphView.addValue(l, atTimeInterval: Double(t.endNanos) / Double(NSEC_PER_SEC))
                //
            }
        }

        if (throughputs.count > 0) {
            // Use last values for momentary display (gauge and label)
            speedGaugeView.value = Float(l)

            //if (phase == .Down) {
            //    updateStatusWithValue(RMBTSpeedMbpsString(/*testRunner.testResult.totalDownloadHistory.totalThroughput.kilobitsPerSecond())*/kbps), phase: phase, final: false)
            //} else {
                updateStatusWithValue(RMBTSpeedMbpsString(/*testRunner.testResult.totalUploadHistory.totalThroughput.kilobitsPerSecond())*/kbps), phase: phase, final: false)
            //}
        }
    }

    ///
    func testRunnerDidCompleteWithResult(result: RMBTHistoryResult!) {
        hideAlert()

        stopHardwareUsageTimer()

        recentResults = result

        // go directly to next loop if should skip qos
        if (loopMode && loopSkipQOS) {
            logger.debug("skipping qos test in loop mode")
            restartTestAfterCountdown(loopMinDelay)
            return
        }

        qosManager = QualityOfServiceTest(testToken: testRunner.testParams.testToken, speedtestStartTime: testRunner.testResult.testStartNanos)
        qosManager.delegate = self
        qosManager.start()

        qtMode = true
    }

    ///
    func testRunnerDidCancelTestWithReason(cancelReason: RMBTTestRunnerCancelReason) {
        stopHardwareUsageTimer()

        switch(cancelReason) {

        case .UserRequested:
            self.dismissViewControllerAnimated(true, completion: nil)

        case .MixedConnectivity:
            logger.debug("Test cancelled because of mixed connectivity")
            startTest()

        case .NoConnection, .ErrorFetchingTestingParams:
            if (loopMode) {
                restartTestAfterCountdown(loopMinDelay)
            } else {

                var message: String

                if (cancelReason == .NoConnection) {
                    logger.debug("Test cancelled because of connection error")
                    message = NSLocalizedString("test.connection.lost", value: "The connection to the test server was lost. Test aborted.", comment: "Alert view message")
                } else {
                    logger.debug("Test cancelled failing to fetch test params")
                    message = NSLocalizedString("test.connection.could-not-connect", value: "Couldn't connect to test server.", comment: "Alert view message")
                }

                displayAlertWithTitle(NSLocalizedString("test.connection.error", value: "Connection Error", comment: "Alert view title"),
                    message: message,
                    cancelButtonTitle: NSLocalizedString("general.alertview.cancel", value: "Cancel", comment: "Alert view button"),
                    otherButtonTitle: NSLocalizedString("test.try-again", value: "Try Again", comment: "Alert view button"),
                    cancelHandler: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    },
                    otherHandler: {
                        self.startTest()
                    }
                )
            }

        case .ErrorSubmittingTestResult:

            if (loopMode) {
                restartTestAfterCountdown(loopMinDelay)
            } else {

                logger.debug("Test cancelled failing to submit test results")

                displayAlertWithTitle(NSLocalizedString("general.alertview.error", value: "Error", comment: "Alert view title"),
                    message: NSLocalizedString("test.result.not-submitted", value: "Test was completed, but the results couldn't be submitted to the test server.", comment: "Alert view message"),
                    cancelButtonTitle: NSLocalizedString("general.alertview.dismiss", value: "Dismiss", comment: "Alert view button"),
                    otherButtonTitle: "",
                    cancelHandler: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    },
                    otherHandler:{
                    }
                )
            }

        case .AppBackgrounded:

            logger.debug("Test cancelled because app backgrounded")

            displayAlertWithTitle(NSLocalizedString("test.aborted-title", value: "Test aborted", comment: "Alert view title"),
                message: NSLocalizedString("test.aborted-message", value: "Test was aborted because the app went into background. Tests can only be performed while the app is running in foreground.", comment: "Alert view message"),
                cancelButtonTitle: NSLocalizedString("general.alertview.close", value: "Close", comment: "Alert view button"),
                otherButtonTitle: NSLocalizedString("test.repeat", value: "Repeat Test", comment: "Alert view button"),
                cancelHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                },
                otherHandler: {
                    self.startTest()
                }
            )

        default:
            break
        }
    }

// MARK: - Alert views Methods

    ///
    @IBAction func tapped() {
        displayAlertWithTitle(RMBTAppTitle(),
            message: NSLocalizedString("test.abort-test-question", value: "Do you really want to abort the running test?", comment: "Alert view message"),
            cancelButtonTitle: NSLocalizedString("test.abort-test-button", value: "Abort Test", comment: "Alert view button"),
            otherButtonTitle: NSLocalizedString("test.continue-button", value: "Continue", comment: "Abort test alert button"),
            cancelHandler: {
                ControlServer.sharedControlServer.cancelAllRequests()
                self.testRunner.cancel()
                self.qosManager?.stop()
            },
            otherHandler: {

            }
        )
    }

    ///
    private func displayAlertWithTitle(title: String, message: String, cancelButtonTitle: String, otherButtonTitle: String, cancelHandler: RMBTBlock, otherHandler: RMBTBlock) {
        hideAlert()

        alertView = UIAlertView.bk_alertViewWithTitle(title, message: message) as! UIAlertView

        if (!cancelButtonTitle.isEmpty) {
            alertView.bk_setCancelButtonWithTitle(cancelButtonTitle, handler: cancelHandler)
        }

        if (!otherButtonTitle.isEmpty) {
            alertView.bk_addButtonWithTitle(otherButtonTitle, handler: otherHandler)
        }

        alertView.show()
    }

    ///
    private func hideAlert() {
        if (alertView.visible) {
            alertView.dismissWithClickedButtonIndex(-1, animated: true)
        }
    }

// MARK: - Methods

    ///
    private func restartTestAfterCountdown(interval: Int) {
        loopCounter++
        if (loopCounter <= loopMaxTests) {
            // Restart test
            logger.debug("Loop mode active, starting new test (\(loopCounter)/\(loopMaxTests)) after \(interval) seconds")

            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * Int64(interval))

            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.startNextLoop()
            }
        } else {
            logger.debug("Loop mode limit reached (\(loopMaxTests)), stopping")
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    ///
    private func startNextLoop() {
        // TODO: reset view
        qtMode = false

        swapViews()

        startTest()
    }

    /// Can be called multiple times if run in loop mode
    private func startTest() {
        assert(loopMode || loopCounter == 1, "Called test twice w/o being in loop mode")

        finishedPercentage = 0
        displayPercentage(0)

        arrowImageView.image = nil

        speedGaugeView.value = 0

        ///
        //graph?.clear()
        speedGraphView.clear()
        ///

        testRunner = RMBTTestRunner(delegate: self)
        testRunner.start()

        // start cpu and memory usage timer
        startHardwareUsageTimer()
    }

    ///
    private func percentageForPhase(phase: RMBTTestRunnerPhase) -> Int {
        switch (phase) {
            case .Init:    return 7
            case .Latency: return 5
            case .Down:    return 17
            case .Up:      return 19
            default:       return 0
        }
    }

    ///
    private func displayPercentage(percentage: Int) {
        progressLabel.text = String(format: "%lu%%", percentage)
        progressGaugeView.value = Float(percentage) / 50
    }

    ///
    private func percentageAfterPhase(phase: RMBTTestRunnerPhase) -> Int {
        switch (phase) {
            case .None:
                return 0
            //case .FetchingTestParams:
            case .Wait:
                return 3
            case .Init:
                return 7
            case .Latency:
                return 13
            case .Down:
                return 31
            case .InitUp:
                return 31 // no visualization for init up
            case .Up:
                return 50
            case .SubmittingTestResult:
                return 50 // also no visualization for submission
            default:
                return 0
        }
    }

// MARK: hardware usage timer

    ///
    private func startHardwareUsageTimer() {
        hardwareUsageTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "hardwareUsageTimerFired", userInfo: nil, repeats: true)
    }

    ///
    private func stopHardwareUsageTimer() {
        hardwareUsageTimer?.invalidate()
        hardwareUsageTimer = nil
    }

    ///
    func hardwareUsageTimerFired() {
        if (testRunner.testResult == nil) {
            return // fix for unwrapped optional crash below
        }

        let relativeNanos = nanoTime() - testRunner.testResult.testStartNanos

        // CPU

        if let cpuUsage = cpuMonitor.getCPUUsage() as? [NSNumber] {
            if (cpuUsage.count > 0) {
                testRunner.testResult.addCpuUsage(cpuUsage[0].floatValue, atNanos: relativeNanos)
                logger.debug("ADDING CPU USAGE: \(cpuUsage[0].floatValue) atNanos: \(relativeNanos)")
            }
        } else {
            // TODO: else write implausible error, or use previous value
        }

        // RAM

        let ramUsagePercentFree = ramMonitor.getRAMUsagePercentFree()

        testRunner.testResult.addMemoryUsage(ramUsagePercentFree, atNanos: relativeNanos)
        logger.debug("ADDING RAM USAGE: \(ramUsagePercentFree) atNanos: \(relativeNanos)")
    }
}
