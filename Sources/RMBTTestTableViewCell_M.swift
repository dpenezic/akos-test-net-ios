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
//  RMBTTestTableViewCell_M.swift
//  RMBT
//
//  Created by Tomáš Baculák on 29/01/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
class RMBTTestTableViewCell_M : UITableViewCell {

    ///
    @IBOutlet var titleLabel: UILabel!

    ///
    @IBOutlet var valueLabel: UILabel!

    ///
    @IBOutlet var statusView: UIView!

    ///
    let label = UILabel()

    ///
    var isCellFinished = false

    //

    ///
    override func awakeFromNib() {
        super.awakeFromNib()

        accessoryView = nil
        accessoryType = .None
    }

    ///
    func assignFinalValue(value: String) {
        statusView.removeFromSuperview()

        let check = RMBTUICheckmarkView(frame: statusView.frame)
        check.lineColor = UIColor.whiteColor()

        addSubview(check)

        //var _label = UILabel()
        label.frame         = CGRectMake(0, 0, boundsWidth / 2 - 20, boundsHeight)
        label.textColor     = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Right
        label.font          = UIFont(name: MAIN_FONT, size: 13.0)
        label.text          = value

        self.accessoryView = label
    }

    ///
    func assignResultValue(value: String, final: Bool) {
        dispatch_async(dispatch_get_main_queue()) {

            if (self.accessoryView == nil) {

                self.label.frame         = CGRectMake(0, 0, self.boundsWidth/2 - 20, self.boundsHeight)
                self.label.textColor     = UIColor.whiteColor()
                self.label.textAlignment = NSTextAlignment.Right
                self.label.font          = UIFont(name: MAIN_FONT, size: 13.0)
                //
                self.accessoryView  = self.label
            }

            self.label.text = value

            if (final && !self.isCellFinished) {

                self.isCellFinished = true

                self.statusView.removeFromSuperview()

                let check = RMBTUICheckmarkView(frame: self.statusView.frame)
                check.lineColor = UIColor.whiteColor()

                self.addSubview(check)

//                self.layer.removeAllAnimations()
//
//                UIView.animateWithDuration(0.3, animations: {
//                    self.label.transform = CGAffineTransformScale(self.label.transform, 1.3, 1.3)
//                    }, completion: { finished in
//                        self.label.transform = CGAffineTransformIdentity
//                })
            }
        }
    }
}
