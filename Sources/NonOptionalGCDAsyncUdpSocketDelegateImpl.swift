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
//  NonOptionalGCDAsyncUdpSocketDelegateImpl.swift
//  RMBT
//
//  Created by Benjamin Pucher on 11.02.15.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class NonOptionalGCDAsyncUdpSocketDelegateImpl : NSObject {
    
    ///
    let delegate: NonOptionalGCDAsyncUdpSocketDelegate
    
    ///
    init(delegate: NonOptionalGCDAsyncUdpSocketDelegate) {
        self.delegate = delegate
    }
    
}

// MARK: GCDAsyncUdpSocketDelegate methods

///
extension NonOptionalGCDAsyncUdpSocketDelegateImpl : GCDAsyncUdpSocketDelegate {
    
    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        delegate.udpSocket(sock, didConnectToAddress: address)
    }
    
    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        delegate.udpSocket(sock, didNotConnect: error)
    }
    
    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        delegate.udpSocket(sock, didSendDataWithTag: tag)
    }
    
    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        delegate.udpSocket(sock, didNotSendDataWithTag: tag, dueToError: error)
    }
    
    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        delegate.udpSocket(sock, didReceiveData: data, fromAddress: address, withFilterContext: filterContext)
    }
    
    ///
    func udpSocketDidClose(sock: GCDAsyncUdpSocket!, withError error: NSError!) {
        delegate.udpSocketDidClose(sock, withError: error)
    }
}