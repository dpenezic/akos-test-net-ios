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
//  RMBTVerticalTransitionController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 24.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
@objc class RMBTVerticalTransitionController : NSObject, UIViewControllerAnimatedTransitioning {

    ///
    var reverse = false
    
    ///
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.25
    }
    
    ///
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! // !
        let toViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! // !
     
        let endFrame: CGRect = transitionContext.initialFrameForViewController(fromViewController)
        
        transitionContext.containerView().addSubview(toViewController.view)
        
        toViewController.view.frame = CGRectOffset(endFrame, 0, (self.reverse ? 1 : -1) * toViewController.view.frame.size.height)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            toViewController.view.frame = endFrame
            fromViewController.view.frame = CGRectOffset(fromViewController.view.frame, 0, (self.reverse ? -1 : 1) * toViewController.view.frame.size.height)
        }) { t in
            transitionContext.completeTransition(true)
        }
    }
}
