//
//  ModalViewController.swift
//  InteractiveModal
//
//  Created by Robert Chen on 1/6/16.
//  Copyright © 2016 Thorn Technologies. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {

    // Need an outlet to the table view to access its pan gesture recognizer.
    @IBOutlet weak var tableView: UITableView!
    
    var interactor:Interactor? = nil

    // Refactoring the progress calculation.
    // In the case of dragging downward, pulling down 50, and the screen height is 500, results in 0.10
    func progressAlongAxis(pointOnAxis: CGFloat, axisLength: CGFloat) -> CGFloat {
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
        let positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
        return CGFloat(positiveMovementOnAxisPercent)
    }
    
    // Check out @Jugale's awesome comment on StackOverflow:
    // http://stackoverflow.com/questions/26604395/interactive-transition-like-google-maps-ios
    // I spent a few hours correlating scroll view delegate methods to the equivalent interactor methods.
    // (see commented-out code below)
    // Actually got it working to some extent, but it was brittle and hacky.
    // Turns out that all this can be replaced with a single line of code:
    //       tableView.panGestureRecognizer.addTarget(self, action: "handleGesture:")
    /*

    extension ModalViewController: UIScrollViewDelegate {
    
        func scrollViewWillBeginDragging(scrollView: UIScrollView) {
            guard let interactor = interactor where scrollView.contentOffset.y <= 0 else { return }
            interactor.hasStarted = true
            dismissViewControllerAnimated(true, completion: nil)
        }
        
        func scrollViewDidScroll(scrollView: UIScrollView) {
            guard let interactor = interactor else { return }
            // contentOffset is negative, so make it positive.
            // multiply the contentOffset by a factor of 2 to make it go a little faster.
            let positiveContentOffset = -2 * scrollView.contentOffset.y
            let progress = progressAlongAxis(positiveContentOffset, axisLength: view.bounds.height)
            interactor.shouldFinish = progress > 0.4
            interactor.updateInteractiveTransition(progress)
        }
        
        func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            guard let interactor = interactor else { return }
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finishInteractiveTransition()
                : interactor.cancelInteractiveTransition()
        }
    
    }

    */
    override func viewDidLoad() {
        tableView.panGestureRecognizer.addTarget(self, action: "handleGesture:")
    }
    
    @IBAction func close(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func handleGesture(sender: UIPanGestureRecognizer) {

        let percentThreshold:CGFloat = 0.3

        // convert y-position to downward pull progress (percentage)
        let translation = sender.translationInView(view)
        // using the helper method
        let progress = progressAlongAxis(translation.y, axisLength: view.bounds.height)
        
        guard let interactor = interactor,
            let originView = sender.view else { return }
        
        // Only let the table view dismiss the modal only if we're at the top.
        // If the user is in the middle of the table, let him scroll.
        switch originView {
        case view:
            break
        case tableView:
            if tableView.contentOffset.y > 0 {
                return
            }
        default:
            break
        }
        
        switch sender.state {
        case .Began:
            interactor.hasStarted = true
            dismissViewControllerAnimated(true, completion: nil)
        case .Changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.updateInteractiveTransition(progress)
        case .Cancelled:
            interactor.hasStarted = false
            interactor.cancelInteractiveTransition()
        case .Ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finishInteractiveTransition()
                : interactor.cancelInteractiveTransition()
        default:
            break
        }
    }
    
}

extension ModalViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel?.text = "cell \(indexPath.row)"
        return cell
    }
}