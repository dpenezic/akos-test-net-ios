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
//  RMBTQoSViewController.swift
//  RMBT
//
//  Created by Tomáš Baculák on 06/02/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
class RMBTQoSViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    ///
    @IBOutlet var resultsTable: UITableView!
    
    /// nasty input
    var qosTestResults: NSDictionary!
    
    /// general
    var itemsList = [testItems]()
    
    /// specific
    var itemTestResults = [String:AnyObject]()
    
    /// consolidated input
    var normalData = [[String:AnyObject]]()

    ///
    struct testItems {
        var name: String
        var status: Bool
        var result: String
    }

    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.normalData = self.consolidateResultsData(self.qosTestResults)

        for (var i = 0; i < self.normalData.count; i++) {
            
            let adict = self.normalData[i] as Dictionary
            
            let sDict = adict["serverDesc"] as! NSDictionary
            let dDict = adict["desc"] as? NSMutableArray
            let tests = adict["tests"] as! NSMutableArray
            
            var testNameString: String!
            
            var a = 0
            var f = 0
            
            for (a; a < tests.count; a++) {
                
                let item = tests[a] as! NSDictionary
                let failure = item.objectForKey("failure_count") as! NSNumber

                if (failure == 0) {
                    f++
                }
            }
            
            let status = String(format: "%i/%i", f, a)
            
            testNameString = sDict.objectForKey("name") as! String
            
            var aStatus = true
            
            if (dDict != nil) {
                aStatus = (f == a)
            }
            
            var item = testItems(name: testNameString, status: aStatus, result: status)
            
            self.itemsList.append(item)
        }
        
        // Do any additional setup after loading the view.
    }
    
// MARK: - Navigation

    ///
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailVC = segue.destinationViewController as! RMBTQoSDetailVC
        detailVC.qosTestResults = self.itemTestResults
    }
    

// MARK: - UITableViewDataSource/UITableViewDelegate
    
    ///
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsList.count
    }
    
    ///
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    ///
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.resultsTable.dequeueReusableCellWithIdentifier("QOS_result_cell") as! RMBTQoS_Result_TableViewCell
        
        // status subview
        cell.assignStatus(self.itemsList[indexPath.row].status)
        
        // values
        cell.titleLabel.text = self.itemsList[indexPath.row].name
        cell.resultLabel.text = self.itemsList[indexPath.row].result
        
        // colors
        //cell.backgroundColor = COLOR_BACKGROUND_COLOR
        //cell.titleLabel?.textColor = COLOR_TEXT_LIGHT_COLOR
        //cell.titleLabel?.highlightedTextColor = UIColor.whiteColor()
        //cell.resultLabel?.highlightedTextColor = UIColor.whiteColor()
        
        return cell
    }
    
    ///
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! RMBTQoS_Result_TableViewCell
        let aTestName = cell.titleLabel.text
        
        self.itemTestResults = self.retrieveSpecificItems(self.getTestTypeFromLabelName(aTestName!))
        
        return indexPath
    }
    
    ///
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
// MARK: - Methods
    
    ///
    private func getTestTypeFromLabelName(labelName:String) -> String {
        var testType: String!
        
        for (var i = 0; i < self.normalData.count; i++) {
            let adict = normalData[i] as Dictionary
            let sDict = adict["serverDesc"] as! NSDictionary
            let sName = (sDict.valueForKey("name")) as! String
            
            if sName == labelName {
                testType = adict ["test_type"] as! String
            }
        }
        
        return testType
    }
    
    ///
    private func consolidateResultsData (results:NSDictionary) -> [[String:AnyObject]] {
        var conData = [[String:AnyObject]]()
        
        let resultsDetail = results.objectForKey("testresultdetail") as! NSArray
        let resultsGenDesc = results.objectForKey("testresultdetail_testdesc") as! NSArray
        let resultsOptionalDesc = results.objectForKey("testresultdetail_desc") as? NSArray
        
        for (var i = 0; i < resultsDetail.count; i++) {
            let item = resultsDetail[i] as! NSDictionary
            let test_type = item.objectForKey("test_type") as! String
            let tt = test_type.uppercaseString as String
            
            if (conData.count == 0) {
                var optDesc = NSMutableArray()
                var serverDesc: NSDictionary?
                
                if let resultDesc = resultsOptionalDesc {
                    
                    for (var i = 0; i < resultDesc.count; i++) {
                        let itemDesc = resultDesc[i] as! NSDictionary
                        let test_type_gen = itemDesc.objectForKey("test") as! String
                        
                        if (test_type_gen == tt) {
                            optDesc.addObject(itemDesc)
                        }
                    }
                }
                
                for (var i = 0; i < resultsGenDesc.count; i++) {
                    
                    let itemDesc = resultsGenDesc[i] as! NSDictionary
                    let test_type_gen = itemDesc.objectForKey("test_type") as! String
                    
                    if (test_type_gen == tt) {
                        serverDesc = resultsGenDesc[i] as? NSDictionary
                    }
                }
                
                var dict = [String:AnyObject]()
                
                let itemArray = NSMutableArray(object: item)
                
                if (optDesc.count > 0) {
                    dict = Dictionary(dictionaryLiteral: ("test_type", tt), ("tests", itemArray), ("serverDesc", serverDesc!), ("desc", optDesc))
                } else {
                    dict = Dictionary(dictionaryLiteral: ("test_type", tt), ("tests", itemArray), ("serverDesc", serverDesc!))
                }

                conData.append(dict)
            } else {
                
                var newType = true
                var aDict = [String:AnyObject]()
                var bDict = [String:AnyObject]()
                
                for (var e = 0; e < conData.count; e++) {
                    aDict = conData[e] as [String:AnyObject]
                    let tts = aDict["test_type"] as! String
                    
                    if tts == tt {
                        newType = false
                        bDict = aDict
                    }
                }
                
                if (!newType) {
                    var allTests = bDict["tests"] as! NSMutableArray
                        
                    allTests.addObject(item)
                        
                    //logger.debug("Just add array")
                    //logger.debug("\(allTests)")
                        
                    bDict.updateValue(allTests, forKey: "tests")
                } else {
                    var optDesc = NSMutableArray()
                    var serverDesc: NSDictionary?
                        
                    if let resultDesc = resultsOptionalDesc {
                        
                        for (var i = 0; i < resultDesc.count; i++) {
                            
                            let itemDesc = resultDesc[i] as! NSDictionary
                            let test_type_gen = itemDesc.objectForKey("test") as! String
                            
                            if (test_type_gen == tt) {
                                optDesc.addObject(itemDesc)
                            }
                        }
                    }
                    
                    for (var i = 0; resultsGenDesc.count > i; i++) {
                        
                        let itemDesc = resultsGenDesc[i] as! NSDictionary
                        let test_type_gen = itemDesc.objectForKey("test_type") as! String
                        
                        if (test_type_gen == tt) {
                            serverDesc = resultsGenDesc[i] as? NSDictionary
                        }
                    }
                    
                    var dict = [String:AnyObject]()
                    
                    let itemArray = NSMutableArray(object: item)
                    
                    if (optDesc.count > 0) {
                        dict = Dictionary(dictionaryLiteral: ("test_type", tt), ("tests", itemArray), ("serverDesc", serverDesc!), ("desc", optDesc))
                    } else {
                        dict = Dictionary(dictionaryLiteral: ("test_type", tt), ("tests", itemArray), ("serverDesc", serverDesc!))
                    }
                    
                    //logger.debug("My dictionary")
                    //logger.debug("\(dict)")
                    
                    conData.append(dict)
                }
            }
       }
        
//        logger.debug("Whole result")
//        logger.debug("\(conData)")
        
        return conData
    }
    
    ///
    private func retrieveSpecificItems(testType: String) -> [String:AnyObject] {
        var specItems = [String:AnyObject]()
        
        for (var i = 0; i < self.normalData.count; i++) {
            
            let dict = self.normalData[i] as Dictionary
            
            if (testType == dict["test_type"] as! String) {
                specItems = dict
            }
        }
        
        return specItems
    }
}
