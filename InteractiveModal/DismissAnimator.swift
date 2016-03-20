//
//  DismissAnimator.swift
//  InteractiveModal
//
//  Created by Robert Chen on 1/8/16.
//  Copyright © 2016 Thorn Technologies. All rights reserved.
//

import UIKit

class DismissAnimator : NSObject {
}

extension DismissAnimator : UIViewControllerAnimatedTransitioning {
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
        // toVC is the Main View Controller
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        // fromVC is the Modal VC. 
        // Hide it for now, since we're going to use snapshots instead.
        fromVC.view.hidden = true
        
        // Create the snapshot.
        let snapshot = fromVC.view.snapshotViewAfterScreenUpdates(false)
        // Don't forget to add it
        containerView.insertSubview(snapshot, aboveSubview: toVC.view)

        UIView.animateWithDuration(
            transitionDuration(transitionContext),
            animations: {
                // Shift the snapshot down by one screen length
                snapshot.center.y += UIScreen.mainScreen().bounds.height
            },
            completion: { _ in
                // Cleanup. 
                // Undo the hidden state. User won't see this because transition is already over.
                fromVC.view.hidden = false
                // It's already off-screen, but get rid of the snapshot anyway.
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
        )
    }
}