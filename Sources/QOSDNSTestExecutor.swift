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
//  QOSDNSTestExecutor.swift
//  RMBT
//
//  Created by Benjamin Pucher on 29.01.15.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
typealias DNSTestExecutor = QOSDNSTestExecutor<QOSDNSTest>

///
class QOSDNSTestExecutor<T : QOSDNSTest> : QOSTestExecutorClass<T> {

    let RESULT_DNS_STATUS           = "dns_result_status"
    let RESULT_DNS_ENTRY            = "dns_result_entries"
    let RESULT_DNS_TTL              = "dns_result_ttl"
    let RESULT_DNS_ADDRESS          = "dns_result_address"
    let RESULT_DNS_PRIORITY         = "dns_result_priority"
    let RESULT_DNS_DURATION         = "dns_result_duration"
    let RESULT_DNS_QUERY            = "dns_result_info"
    let RESULT_DNS_RESOLVER         = "dns_objective_resolver"
    let RESULT_DNS_HOST             = "dns_objective_host"
    let RESULT_DNS_RECORD           = "dns_objective_dns_record"
    let RESULT_DNS_ENTRIES_FOUND    = "dns_result_entries_found"
    let RESULT_DNS_TIMEOUT          = "dns_objective_timeout"
    
    //
    
    ///
    override init(controlConnection: QOSControlConnection, delegateQueue: dispatch_queue_t, testObject: T, speedtestStartTime: UInt64) {
        super.init(controlConnection: controlConnection, delegateQueue: delegateQueue, testObject: testObject, speedtestStartTime: speedtestStartTime)
    }
    
    ///
    override func startTest() {
        super.startTest()
        
        testResult.set(RESULT_DNS_RESOLVER, value: testObject.resolver ?? "Standard")
        testResult.set(RESULT_DNS_RECORD,   value: testObject.record!)
        testResult.set(RESULT_DNS_HOST,     value: testObject.host!)
        testResult.set(RESULT_DNS_TIMEOUT,  number: testObject.timeout)
    }
    
    ///
    override func executeTest() {
        
        if let host = testObject.host {
            qosLog.debug("EXECUTING DNS TEST")
            
            let startTimeTicks = getCurrentTimeTicks()
        
            // do dns query
            // TODO: improve
            
            // TODO: check if record is supported (in map)
            
            SwiftTryCatch.try({
                if let resolver = self.testObject.resolver {
                    DNSClient.queryNameserver(resolver, serverPort: 53, forName: host, recordType: self.testObject.record!, success: { responseObj in
                        self.try_afterDNSResolution(startTimeTicks, responseObj: responseObj, error: nil)
                    }, failure: { error in
                        self.try_afterDNSResolution(startTimeTicks, responseObj: nil, error: error)
                    })
                } else {
                    DNSClient.query(host, recordType: self.testObject.record!, success: { responseObj in
                        self.try_afterDNSResolution(startTimeTicks, responseObj: responseObj, error: nil)
                    }, failure: { error in
                        self.try_afterDNSResolution(startTimeTicks, responseObj: nil, error: error)
                    })
                }
            }, catch: { (error) in
                self.testDidFail()
            }, finally: {

            })
        }
    }
    
    ///
    private func try_afterDNSResolution(startTimeTicks: UInt64, responseObj: DNSRecordClass?, error: NSError?) {
        SwiftTryCatch.try({
            self.afterDNSResolution(startTimeTicks, responseObj: responseObj, error: error)
        }, catch: { (error) in
            self.testDidFail()
        }, finally: {
                
        })
    }
    
    ///
    private func afterDNSResolution(startTimeTicks: UInt64, responseObj: DNSRecordClass?, error: NSError?) {
    
        self.testResult.set(self.RESULT_DNS_DURATION, number: getTimeDifferenceInNanoSeconds(startTimeTicks))
    
        //
        
        testResult.set(RESULT_DNS_STATUS, value: 0/*0 = NOERROR*/) // TODO: Rcode
        
        //
        
        var resourceRecordArray = [[String:AnyObject]]()
        
        if let response = responseObj {
        
            //for response.resultRecords {
            
                var resultRecord = [String:AnyObject]()

                // TODO: improve this section
            
                switch (Int(response.qType)) {
                    case kDNSServiceType_A:
                        resultRecord[RESULT_DNS_ADDRESS] = jsonValueOrNull(response.ipAddress)
                    case kDNSServiceType_CNAME:
                        resultRecord[RESULT_DNS_ADDRESS] = jsonValueOrNull(response.ipAddress)
                    case kDNSServiceType_MX:
                        resultRecord[RESULT_DNS_ADDRESS] = jsonValueOrNull(response.ipAddress)
                        resultRecord[RESULT_DNS_PRIORITY] = "\(response.mxPreference!)"
                    case kDNSServiceType_AAAA:
                        resultRecord[RESULT_DNS_ADDRESS] = jsonValueOrNull(response.ipAddress)
                    default:
                        qosLog.debug("unknown result record type \(response.qType), skipping")
                }
            
                resultRecord[RESULT_DNS_TTL] = "\(response.ttl)"
            
                resourceRecordArray.append(resultRecord)
            
            //}
        } else if let err = error {
            // TODO: error?
        }
        
        qosLog.debug("going to submit resource record array: \(resourceRecordArray)")
        
        testResult.set(RESULT_DNS_ENTRY, value: resourceRecordArray.count > 0 ? resourceRecordArray as NSArray : nil) // cast needed to prevent "HStore format unsupported"
        testResult.set(RESULT_DNS_ENTRIES_FOUND, value: resourceRecordArray.count)
        
        //callFinishCallback()
        testDidSucceed()
    }
    
    ///
    override func testDidSucceed() {
        testResult.set(RESULT_DNS_QUERY, value: "OK")
        
        super.testDidSucceed()
    }
    
    ///
    override func testDidTimeout() {
        testResult.set(RESULT_DNS_QUERY, value: "TIMEOUT")

        testResult.set(RESULT_DNS_ENTRY, value: /*[] as NSArray*/nil)
        testResult.set(RESULT_DNS_ENTRIES_FOUND, value: 0)
        
        super.testDidTimeout()
    }
    
    ///
    override func testDidFail() {
        testResult.set(RESULT_DNS_QUERY, value: "ERROR")
        
        testResult.set(RESULT_DNS_ENTRY, value: nil)
        testResult.set(RESULT_DNS_ENTRIES_FOUND, value: 0)
        
        super.testDidFail()
    }

    ///
    override func needsControlConnection() -> Bool {
        return false
    }
}
