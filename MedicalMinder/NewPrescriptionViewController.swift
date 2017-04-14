//
//  NewPrescriptionViewController.swift
//  MedicalMinder
//
//  Created by Derrick Price on 11/2/16.
//  Copyright © 2016 DLP. All rights reserved.
//

import UIKit
import CoreData

class NewPrescriptionViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dosageNumTextField: UITextField!
    @IBOutlet weak var unitsTextField: UITextField!
    @IBOutlet weak var frequencyTextField: UITextField!
    @IBOutlet weak var frequencyPerDayTextField: UITextField!
    @IBOutlet weak var startingDate: UIDatePicker!
    @IBOutlet weak var prescribingDoctorTextField: UITextField!
    @IBOutlet weak var statusIndicator: UIActivityIndicatorView!
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedUser : UserInfo?
    
    // This view is by the user to enter a new prescription
    
    // Usual setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the text field delegate to only allow numbers
        dosageNumTextField.delegate = self
        frequencyTextField.delegate = self
        
        statusIndicator.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // Force only numbers in the text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // TODO: Can I limit the number of characters to be entered by the user to 3 digits?
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        //        let character_len = textField.text?.characters.count
        
        return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex..<string.endIndex) == nil
        //        return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.characters.indices) == nil
        //        &&
        //        character_len < 3
    }
    
    // Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    lazy var sharedContext: NSManagedObjectContext =  {
        
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    @IBAction func saveSettings(_ sender: UIButton) {
        
        var med_overview = "Nothing right now"
        
        DispatchQueue.main.async {
            self.statusIndicator.isHidden = false
            self.statusIndicator.startAnimating()
        }
        
        // Get the description of the medicine
        WebConnectionClient.sharedInstance().getMedicalDescription(self.nameTextField.text!) { (success, overview, errorString) in
            
            DispatchQueue.main.async {
                // End animation of status indicator
                self.statusIndicator.isHidden = true
                self.statusIndicator.stopAnimating()
            }
            
            if (!success) {
                med_overview = "No additional information found"
            }
            else {
                med_overview = overview!
            }
            
            if errorString != nil {
                
                // Alert the user to the error
                self.showAlertMessage (error_title: "Could not Lookup Medical Info", error_message: errorString!)
                
            } else {
                
                let scriptDictionary: [String : AnyObject] = [
                    Prescription.Keys.Name : self.nameTextField.text! as AnyObject,
                    Prescription.Keys.DosageNumber : self.dosageNumTextField.text! as AnyObject,
                    Prescription.Keys.DosageFrequency : self.frequencyTextField.text! as AnyObject,
                    Prescription.Keys.DosagePerDay : self.frequencyPerDayTextField.text! as AnyObject,
                    Prescription.Keys.StartDate : self.startingDate,
                    Prescription.Keys.DosageUnits : self.unitsTextField.text! as AnyObject,
                    Prescription.Keys.Doctor : self.prescribingDoctorTextField.text! as AnyObject,
                    Prescription.Keys.Overview : med_overview  as AnyObject
                ]
                // Now we create a new prescription and save using the shared Context
                let newMed = Prescription(dictionary: scriptDictionary, context: self.sharedContext)
                
                if self.selectedUser != nil {
                    // Set patient data
                    newMed.patient = self.selectedUser
                }
                
                // Save information, add it to the prescription array in the Application Delegate
                let object = UIApplication.shared.delegate
                let appDelegate = object as! AppDelegate
                appDelegate.prescriptions.append(newMed)
                
                // Save the settings and exit
                CoreDataStackManager.sharedInstance().saveContext()
            }
            
            // Close this view
            DispatchQueue.main.async {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func cancelSettings(_ sender: UIButton) {
        // Close this view
        DispatchQueue.main.async {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    // Make sure user has entered the required fields
    @IBAction func checkValidFieldEntries(_ sender: UITextField) {
        
        guard let medname = nameTextField.text, !medname.isEmpty,
            let dosagenum = dosageNumTextField.text, !dosagenum.isEmpty,
            let dosagefreq = frequencyTextField.text, !dosagefreq.isEmpty,
            let dosageperday = frequencyPerDayTextField.text, !dosageperday.isEmpty
            else {
                saveButton.isEnabled = false
                return
        }
        
        // Enable Save if textfields are not empty
        saveButton.isEnabled = true
    }
    
    func showAlertMessage (error_title: String, error_message: String) {
        
        //simple alert dialog
        DispatchQueue.main.async {
            let alert = UIAlertController(title: error_title, message: error_message, preferredStyle: UIAlertControllerStyle.alert);
            self.saveButton.isEnabled = false
            // Add a cancel action to the Alert
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil));
            //show the Alert
            self.present(alert, animated: true, completion: nil)
        }
    }
}
