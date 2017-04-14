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
    
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var DosageNumTextField: UITextField!
    @IBOutlet weak var UnitsTextField: UITextField!
    @IBOutlet weak var FrequencyTextField: UITextField!
    @IBOutlet weak var StartingDate: UIDatePicker!
    @IBOutlet weak var FrequencyPerDayTextField: UITextField!
    @IBOutlet weak var PrescribingDoctorTextField: UITextField!
    
    var selectedUser : UserInfo?
    
    // This view is by the user to enter a new prescription
    
    // Usual setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the text field delegate to only allow numbers
        DosageNumTextField.delegate = self
        FrequencyTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // Force only numbers in the text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Can I limit the number of characters to be entered by the user to 3 digits?
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        //        let character_len = textField.text?.characters.count
        //        print ("The character_len = \(character_len)")
        
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
            // Get the description of the medicine
            WebConnectionClient.sharedInstance().getMedicalDescription(self.NameTextField.text!) { (success, overview, errorString) in
                if (!success) {
                    med_overview = "No additional information found"
                }
                else
                {
                    med_overview = overview!
                }
                print ("Got overview: \(med_overview)")
                
                let scriptDictionary: [String : AnyObject] = [
                    Prescription.Keys.Name : self.NameTextField.text! as AnyObject,
                    Prescription.Keys.DosageNumber : self.DosageNumTextField.text! as AnyObject,
                    Prescription.Keys.DosageFrequency : self.FrequencyTextField.text! as AnyObject,
                    Prescription.Keys.DosagePerDay : self.FrequencyPerDayTextField.text! as AnyObject,
                    Prescription.Keys.StartDate : self.StartingDate,
                    Prescription.Keys.DosageUnits : self.UnitsTextField.text! as AnyObject,
                    Prescription.Keys.Doctor : self.PrescribingDoctorTextField.text! as AnyObject,
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
                // Close this view
                DispatchQueue.main.async {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func cancelSettings(_ sender: UIButton) {
        // Close this view
        DispatchQueue.main.async {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func getDateTime() -> (time: String, date: String) {
        
        let formatter = DateFormatter()
        //formatter.timeStyle = NSTimeF
        formatter.dateStyle = DateFormatter.Style.medium
        
        let currentDateTime = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.hour,.minute,.second], from: currentDateTime)
        let hour = components.hour
        let min = components.minute
        let sec = components.second
        
        formatter.dateFormat = "MMMM dd, yyyy"
        let convertedDate = formatter.string(from: currentDateTime)
        
        return ("\(hour):\(min):\(sec)", convertedDate)
    }
}
