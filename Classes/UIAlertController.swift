//
//  UIAlertController.swift
//  Rally
//
//  Created by Cody Sugarman on 12/24/15.
//  Copyright © 2015 Cody Sugarman. All rights reserved.
//

import Foundation

extension UIAlertController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    public override func shouldAutorotate() -> Bool {
        return false
    }
}