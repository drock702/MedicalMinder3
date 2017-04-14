//
//  MedicalMinderNavigationController.swift
//  MedicalMinder3
//
//  Created by Derrick Price on 2/28/17.
//  Copyright © 2017 DLP. All rights reserved.
//

import UIKit

// Create the Navigation Controller class to prevent the orientation rotation
class NavigationController: UINavigationController {
    
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
}
