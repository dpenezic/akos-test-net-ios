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
//  RMBTSSLHelper.swift
//  RMBT
//
//  Created by Benjamin Pucher on 27.03.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
@objc class RMBTSSLHelper {

    ///
    class func encryptionStringForSSLContext(sslContext: SSLContextRef) -> String {
        return "\(encryptionProtocolStringForSSLContext(sslContext)) (\(encryptionCipherStringForSSLContext(sslContext)))"
    }
    
    ///
    class func encryptionProtocolStringForSSLContext(sslContext: SSLContextRef) -> String {
        var sslProtocol = SSLProtocol(0)
        SSLGetNegotiatedProtocolVersion(sslContext, &sslProtocol)
        
        switch (sslProtocol.value) {
            case kSSLProtocolUnknown.value: return "No Protocol"
            case kSSLProtocol2.value:       return "SSLv2"
            case kSSLProtocol3.value:       return "SSLv3"
            case kSSLProtocol3Only.value:   return "SSLv3 Only"
            case kTLSProtocol1.value:       return "TLSv1"
            case kTLSProtocol11.value:      return "TLSv1.1"
            case kTLSProtocol12.value:      return "TLSv1.2"
            default:                        return String(format: "%d", sslProtocol.value)
        }
    }
    
    ///
    class func encryptionCipherStringForSSLContext(sslContext: SSLContextRef) -> String {
        var cipher = SSLCipherSuite()
        SSLGetNegotiatedCipher(sslContext, &cipher)
    
        switch (Int(cipher)) {
            case SSL_RSA_WITH_RC4_128_MD5:    return "SSL_RSA_WITH_RC4_128_MD5"
            case SSL_NO_SUCH_CIPHERSUITE:     return "No Cipher"
            default:                          return String(format: "%X", cipher)
        }
    }
}
