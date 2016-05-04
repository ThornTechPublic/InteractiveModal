//
//  PresentAnimator.swift
//  InteractiveModal
//
//  Created by Robert Chen on 5/3/16.
//  Copyright © 2016 Thorn Technologies. All rights reserved.
//

import UIKit

class PresentMenuAnimator : NSObject {
}

extension PresentMenuAnimator : UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.6
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let containerView = transitionContext.containerView()
            else {
                return
        }
        // overlay the modal on top of the ViewController
        containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        // stage the modal VC one screen below
        toVC.view.center.y += UIScreen.mainScreen().bounds.height
        // the fromVC (ViewController) is going away. 
        // give the illusion of it still being on the screen.
        let snapshot = fromVC.view.snapshotViewAfterScreenUpdates(false)
        containerView.insertSubview(snapshot, belowSubview: toVC.view)
        
        UIView.animateWithDuration(
            transitionDuration(transitionContext),
            animations: {
                // center the modal on the screen
                toVC.view.center.y = UIScreen.mainScreen().bounds.height / 2
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
        )
    }
}