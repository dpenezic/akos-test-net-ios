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
//  RMBTPopupViewButton.swift
//  RMBT
//
//  Created by Tomáš Baculák on 16/01/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
protocol RMBTPopupViewButtonProtocol {
    
    ///
    func viewWasTapped(superView: UIView!)
}

///
class RMBTPopupViewButton : UIView {
    
    ///
    var delegate: RMBTPopupViewButtonProtocol?

    ///
    var contentView: UIView!
    
    ///
    var popup = KLCPopup()
    
    //
    
    ///
    required init (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    ///
    override init (frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    ///
    private func commonInit() {
        let recognizer = UITapGestureRecognizer(target: self, action: "didTap")
        addGestureRecognizer(recognizer)
    }
    
    ///
    func didTap() {
        let superView: UIView! = self.superview
        
        delegate?.viewWasTapped(superView)
        
        if (self.contentView != nil) {
            let layout = KLCPopupLayout (horizontal: KLCPopupHorizontalLayout.Center, vertical: KLCPopupVerticalLayout.AboveCenter)
            
            self.popup = KLCPopup(
                contentView: contentView,
                showType: KLCPopupShowType.FadeIn,
                dismissType: KLCPopupDismissType.FadeOut,
                maskType: KLCPopupMaskType.Clear,
                dismissOnBackgroundTouch: true,
                dismissOnContentTouch: true
            )
            
            //popup.showWithLayout(layout, duration: 1.0)
            popup.showWithLayout(layout)
        } else {
            logger.debug("No content assigned!!")
        }
    }
    
    ///
    func updateView() {
    
    }
}
