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
//  RMBTHistoryResultItemCell.swift
//  RMBT
//
//  Created by Benjamin Pucher on 24.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class RMBTHistoryResultItemCell : UITableViewCell {
    
    ///
    func setItem(item: RMBTHistoryResultItem) {
        let sideStatus = UIView(frame: CGRectMake(0, 0, 10, 29))
        addSubview(sideStatus)
        
        textLabel?.text = item.title
        detailTextLabel?.text = item.value
        
        switch (item.classification) {
            case 1: sideStatus.backgroundColor = COLOR_CHECK_RED
            case 2: sideStatus.backgroundColor = COLOR_CHECK_YELLOW
            case 3: sideStatus.backgroundColor = COLOR_CHECK_GREEN
            default: self.accessoryView = nil
        }
    }
    
    /// Set to YES when displayed in map annotation
    func setEmbedded(embedded: Bool) {
        if (embedded) {
            let font: UIFont = UIFont.systemFontOfSize(15)
            
            self.textLabel!.font = font
            self.detailTextLabel?.font = font
            self.detailTextLabel?.numberOfLines = 2
        }
    }
}
