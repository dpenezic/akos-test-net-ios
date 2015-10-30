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
//  RMBTPopupContentView.swift
//  RMBT
//
//  Created by Tomáš Baculák on 21/01/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
class RMBTPopupContentView : UIView, UITableViewDataSource, UITableViewDelegate {

    ///
    var title = UILabel()
    
    ///
    var table = UITableView()
    
    ///
    var itemsNames = [String]()
    
    ///
    var itemsValues = [String?]()
    
    ///
    let contentViewAlpha: CGFloat = 0.85
    
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
    func commonInit() {
        backgroundColor = UIColor.blackColor()
        alpha = contentViewAlpha
        
        let theTitleLabelHeight: CGFloat = 30.0
        
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = UIColor.blackColor()
        table.frame = CGRectMake(0, theTitleLabelHeight, boundsWidth, boundsHeight - theTitleLabelHeight)
        
        addSubview(table)

        title.frame = CGRectMake(0, 0, boundsWidth, theTitleLabelHeight)
        title.textColor = UIColor.whiteColor()
        title.textAlignment = NSTextAlignment.Center
        
        addSubview(title)
    }
    
// MARK: - Navigation UITableViewDataSource / UITableViewDelegate
    
    ///
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    ///
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsNames.count
    }
    
    ///
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = RMBTPUTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "aCell")
        
        cell.nameLabel.text = itemsNames[indexPath.row]
        cell.valueLabel.text = itemsValues[indexPath.row]

        return cell
    }
    
    ///
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    }
}
