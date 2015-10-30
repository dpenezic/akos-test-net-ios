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
//  ConnectivityService.swift
//  RMBT
//
//  Created by Benjamin Pucher on 02.02.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
struct IPInfo : Printable {

    ///
    var connectionAvailable: Bool = false

    ///
    var nat: Bool {
        return internalIp != externalIp
    }

    ///
    var internalIp: String? = nil

    ///
    var externalIp: String? = nil

    ///
    var description: String {
        return "IPInfo: connectionAvailable: \(connectionAvailable), nat: \(nat), internalIp: \(internalIp), externalIp: \(externalIp)"
    }
}

///
struct ConnectivityInfo : Printable {

    ///
    var ipv4: IPInfo = IPInfo()

    ///
    var ipv6: IPInfo = IPInfo()

    ///
    var description: String {
        return "ConnectivityInfo: ipv4: \(ipv4), ipv6: \(ipv6)"
    }
}

///
class ConnectivityService : NSObject, GCDAsyncUdpSocketDelegate {

    typealias ConnectivityInfoCallback = (connectivityInfo: ConnectivityInfo) -> ()

    //

    ///
    let manager: AFHTTPRequestOperationManager

    ///
    var callback: ConnectivityInfoCallback?

    ///
    var connectivityInfo: ConnectivityInfo!

    ///
    var ipv4Finished = false

    ///
    var ipv6Finished = false

    ///
    override init() {
        manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: ControlServer.sharedControlServer.baseURLString()/*RMBT_CONTROL_SERVER_URL*/))

        manager.requestSerializer = AFJSONRequestSerializer() as AFHTTPRequestSerializer // cast as workaround for strange error
        manager.responseSerializer = AFJSONResponseSerializer()

        manager.requestSerializer.timeoutInterval = 5 // 5 sec
        manager.requestSerializer.cachePolicy = .ReloadIgnoringLocalAndRemoteCacheData

        super.init()
    }

    ///
    func checkConnectivity(callback: ConnectivityInfoCallback) {
        if (self.callback != nil) { // don't allow multiple concurrent executions
            return
        }

        self.callback = callback
        self.connectivityInfo = ConnectivityInfo()

        getLocalIpAddressesFromSocket()
        getLocalIpAddresses() // fallback

        //logger.debug("\(connectivityInfo)")

        ipv4Finished = false
        ipv6Finished = false

        checkIPV4()
        checkIPV6()
    }

    ///
    private func checkIPV4() {
        let ipv4Url = ControlServer.sharedControlServer.ipv4RequestUrl

        var infoParams = ControlServer.sharedControlServer.systemInfoParams()
        infoParams["uuid"] = ControlServer.sharedControlServer.uuid

        // TODO: move this request to control server class
        manager.POST(ipv4Url, parameters: infoParams, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in

            logger.debug("\(responseObject)")

            if (operation.response.statusCode == 200) {

                let ip = responseObject["ip"]
                let v = responseObject["v"]

                logger.debug("IP: \(ip), version: \(v)")

                self.connectivityInfo.ipv4.connectionAvailable = true
                self.connectivityInfo.ipv4.externalIp = (ip as? String)
            } else {
                // TODO: ?
            }

            self.ipv4Finished = true
            self.callCallback()

        }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            //logger.debug("ERROR \(error?)")
            logger.debug("ipv4 request ERROR")

            self.connectivityInfo.ipv4.connectionAvailable = false

            self.ipv4Finished = true
            self.callCallback()
        }
    }

    ///
    private func checkIPV6() {
        let ipv6Url = ControlServer.sharedControlServer.ipv6RequestUrl

        //logger.debug("check ipv6 with url: \(ipv6Url)")

        var infoParams = ControlServer.sharedControlServer.systemInfoParams()
        infoParams["uuid"] = ControlServer.sharedControlServer.uuid

        // TODO: move this request to control server class
        manager.POST(ipv6Url, parameters: infoParams, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in

            //logger.debug("!!!!! IPv6 !!!!!!")
            //logger.debug("\(responseObject)")

            if (operation.response.statusCode == 200) {
                let ip = responseObject["ip"]
                let v = responseObject["v"]

                logger.debug("IP: \(ip), version: \(v)")

                self.connectivityInfo.ipv6.connectionAvailable = true
                self.connectivityInfo.ipv6.externalIp = (ip as? String)
            } else {
                // TODO: ?
            }

            self.ipv6Finished = true
            self.callCallback()

        }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            //logger.debug("ERROR \(error?)")
            logger.debug("ipv6 request ERROR")

            self.connectivityInfo.ipv6.connectionAvailable = false

            self.ipv6Finished = true
            self.callCallback()
        }
    }

    ///
    private func callCallback() {
        objc_sync_enter(self)

        if (!(ipv4Finished && ipv6Finished)) {
            objc_sync_exit(self)
            return
        }

        objc_sync_exit(self)

        let _callback = callback
        callback = nil

        _callback?(connectivityInfo: connectivityInfo)

//        self.delegate?.connectivityDidChange(self, connectivityInfo: self.connectivityInfo!)
    }
}

// MARK: IP addresses

///
extension ConnectivityService {

    // TODO: open socket and then check ip of socket to get correct local ip address!

    ///
    private func getLocalIpAddresses() { // see: http://stackoverflow.com/questions/25626117/how-to-get-ip-address-in-swift
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {

            // For each interface ...
            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
                let flags = Int32(ptr.memory.ifa_flags)
                var addr = ptr.memory.ifa_addr.memory

                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if ((flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING)) {
                    if (addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6)) {

                        // Convert interface address to a human readable string:
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String.fromCString(hostname) {

                                if (addr.sa_family == UInt8(AF_INET)) {
                                    if (self.connectivityInfo.ipv4.internalIp == nil) {
                                        self.connectivityInfo.ipv4.internalIp = address
                                        logger.debug("local ipv4 address from getifaddrs: \(address)")
                                    }
                                } else if (addr.sa_family == UInt8(AF_INET6)) {
                                    if (self.connectivityInfo.ipv6.internalIp == nil) {
                                        self.connectivityInfo.ipv6.internalIp = address
                                        logger.debug("local ipv6 address from getifaddrs: \(address)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
    }

    ///
    private func getLocalIpAddressesFromSocket() {
        let udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))

        var error: NSError?

        var host = NSURL(string: RMBT_URL_HOST)?.host ?? "specure.com"

        // connect to any host
        udpSocket.connectToHost(host, onPort: 11111, error: &error) // TODO: which host, which port?

        logger.debug("connect to host error? \(error)")

        logger.debug("local ipv4 address from socket: \(udpSocket.localHost_IPv4())")
        logger.debug("local ipv6 address from socket: \(udpSocket.localHost_IPv6())")

        connectivityInfo.ipv4.internalIp = udpSocket.localHost_IPv4()
        connectivityInfo.ipv6.internalIp = udpSocket.localHost_IPv6()

        udpSocket.close()
    }
}
