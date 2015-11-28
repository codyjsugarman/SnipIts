//
//  TabBarControllerSubclass.swift
//  Rally
//
//  Created by Cody Sugarman on 7/18/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse

class TabBarControllerSubclass: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 1
    }
    
}