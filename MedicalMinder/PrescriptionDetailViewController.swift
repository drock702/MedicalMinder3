//
//  PrescriptionDetailViewController.swift
//  MedicalMinder3
//
//  Created by Derrick Price on 2/12/17.
//  Copyright © 2017 DLP. All rights reserved.
//

import UIKit
import CoreData

class PrescriptionDetailViewController: UIViewController {
    
    
    @IBOutlet weak var prescriptionOverviewLabel: UILabel!
    @IBOutlet weak var medicalNameLabel: UILabel!
    
    var medicalName: String?
    var medicalOverview: String?
    
    // Usual setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Initialize the form
        if (self.medicalName != nil) {
            self.medicalNameLabel.text = self.medicalName
        }
        if self.medicalOverview != nil {
            self.prescriptionOverviewLabel.text = self.medicalOverview
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    
}
