//
//  ModalViewController.swift
//  InteractiveModal
//
//  Created by Robert Chen on 1/6/16.
//  Copyright © 2016 Thorn Technologies. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {

    @IBAction func close(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
