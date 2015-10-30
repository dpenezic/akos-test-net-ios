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
//  LogConfig.swift
//  RMBT
//
//  Created by Benjamin Pucher on 03.02.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
let logger = XCGLogger.defaultInstance()

///
class LogConfig {
    
    // TODO:
    // *) set log level in app
    
    ///
    private struct StaticDateFormatter { // because class vars are not yet supported
        static let fileDateFormatter = NSDateFormatter()
        static let startedAt = NSDate()
    }
    
    /// setup logging system
    class func initLoggingFramework() {
        setupFileDateFormatter()
        
        let logFilePath = getCurrentLogFilePath()
        
        #if RELEASE
            // Release config
            // 1 logfile per day
            logger.setup(logLevel: .Info, showLogLevel: true, showFileNames: false, showLineNumbers: true, writeToFile: logFilePath) /*.Error*/
        #elseif DEBUG
            // Debug config
            logger.setup(logLevel: .Verbose, showLogLevel: true, showFileNames: false, showLineNumbers: true, writeToFile: nil) // don't need log to file
        #elseif BETA
            // Beta config
            logger.setup(logLevel: .Debug, showLogLevel: true, showFileNames: false, showLineNumbers: true, writeToFile: logFilePath)
            
            uploadOldLogs()
        #endif
    }
    
    ///
    private class func setupFileDateFormatter() {
        let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier ?? "rmbt"
        let uuid = ControlServer.sharedControlServer.uuid ?? "uuid_missing"
        
        #if RELEASE
            StaticDateFormatter.fileDateFormatter.dateFormat = "'\(bundleIdentifier)_\(uuid)_'yyyy_MM_dd'.log'"
        #else
            StaticDateFormatter.fileDateFormatter.dateFormat = "'\(bundleIdentifier)_\(uuid)_'yyyy_MM_dd_HH_mm_ss'.log'"
        #endif
    }
    
    ///
    class func getCurrentLogFilePath() -> String {
        return getLogFolderPath() + "/" + getCurrentLogFileName()
    }
    
    ///
    class func getCurrentLogFileName() -> String {
        return StaticDateFormatter.fileDateFormatter.stringFromDate(/*NSDate()*/StaticDateFormatter.startedAt)
    }
    
    ///
    class func getLogFolderPath() -> String {
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! String
        let logDirectory = cacheDirectory + "/logs"
        
        // try to create logs directory if it doesn't exist yet
        if (!NSFileManager.defaultManager().fileExistsAtPath(logDirectory)) {
            var error: NSError?
            if (!NSFileManager.defaultManager().createDirectoryAtPath(logDirectory, withIntermediateDirectories: false, attributes: nil, error: &error)) {
                // TODO: handle error
            }
        }
        
        return logDirectory
    }
    
    ///
    private class func uploadOldLogs() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            
            let logFolderPath = self.getLogFolderPath()
            let currentLogFile = self.getCurrentLogFileName()
            
            // get file list
            var error: NSError?
            if let fileList: [String] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(logFolderPath, error: &error) as? [String] {
            
                logger.debugExec {
                    logger.debug("LOG: log files in folder")
                    logger.debug("LOG: \(fileList)")
                }
                
                // TODO: check error...
                /*if (error != nil) {
                    // skip on error
                    return
                }*/
                
                // iterate over all log files
                for file in fileList {
                    if (file == currentLogFile) {
                        logger.debug("LOG: not submitting log file \(file) because it is the current log file")
                        continue // skip current log file
                    }
                    
                    let absoluteFile = logFolderPath.stringByAppendingPathComponent(file)
                    
                    logger.debug("LOG: checking if file should be submitted (\(file))")
                    
                    if let fileAttributes = NSFileManager.defaultManager().attributesOfItemAtPath(absoluteFile, error: nil) { // TODO: error?
                    
                        let createdDate = fileAttributes[NSFileCreationDate] as! NSDate
                        let modifiedDate = fileAttributes[NSFileModificationDate] as! NSDate
                        logger.debug("LOG: compared dates of file: \(modifiedDate) to current: \(StaticDateFormatter.startedAt)")
                        if (modifiedDate < StaticDateFormatter.startedAt) {
                        
                            logger.debug("LOG: found log to submit: \(file), last edited at: \(modifiedDate)")
                            
                            if let content = String(contentsOfFile: absoluteFile, encoding: NSUTF8StringEncoding, error: nil) { // TODO: error?
                            
                                let logFileJson: [String:AnyObject] = [
                                    "logfile": file,
                                    "content": content,
                                    "file_times": [
                                        "last_modified": modifiedDate.timeIntervalSince1970,
                                        "created": createdDate.timeIntervalSince1970,
                                        "last_access": modifiedDate.timeIntervalSince1970 // TODO
                                    ]
                                ]
                                
                                ControlServer.sharedControlServer.submitLogFile(logFileJson, success: {
                                    
                                    logger.debug("LOG: deleting log file \(file)")

                                    // delete old log file
                                    NSFileManager.defaultManager().removeItemAtPath(absoluteFile, error: nil) // TODO: error?
                                    return
                                    
                                }, error: { error, info in
                                    // do nothing
                                })
                            }
                        } else {
                            logger.debug("LOG: not submitting log file \(file) because it is the current log file")
                        }
                    }
                }
            }
        }
    }
}

// TODO: move to other file...
extension NSDate : Equatable {}
extension NSDate : Comparable {}

///
public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970
}

///
public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}
