//
//  NewBloodPressureViewController.swift
//  MedicalMinder
//
//  Created by Derrick Price on 10/15/16.
//  Copyright © 2016 DLP. All rights reserved.
//

import UIKit
import CoreData

class NewBloodPressureViewController: UIViewController, UITextFieldDelegate {
    
    // This class is used for the view that allows the user to enter a new blood pressure reading
    
    @IBOutlet weak var systolicText: UITextField!
    @IBOutlet weak var diastolicText: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    var user: UserInfo?
    
    // Usual setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Don't allow readings in the future
        datePicker.maximumDate = NSDate () as Date
        
        // Set up the text field delegate to only allow numbers
        systolicText.delegate = self
        diastolicText.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // Force only numbers in the text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // TODO: Limit the number of characters to be entered by the user to 3 digits?
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        //        let character_len = textField.text?.characters.count
        
        return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex..<string.endIndex) == nil
        //        return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.characters.indices) == nil
        //        &&
        //        character_len < 3
    }
    
    @IBAction func saveSettings(_ sender: UIButton) {
        
        let scriptDictionary: [String : AnyObject] = [
            
            BloodPressure.Keys.Date : datePicker.date as AnyObject,
            BloodPressure.Keys.Diastolic : diastolicText.text! as AnyObject,
            BloodPressure.Keys.Systolic : systolicText.text! as AnyObject
        ]
        
        // Now we create a new blood pressure reading, and save using the shared Context
        let newBP = BloodPressure(dictionary: scriptDictionary, context: sharedContext)
        if self.user != nil {
            // Set patient data
            newBP.patient = self.user
        }
        
        // Save reading
        // Add it to the blood pressure array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.bloodPressures.append(newBP)
        
        // Save the settings and exit
        self.saveContext()
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkFieldsAreValid(_ sender: UITextField) {
        
        guard let systolic = systolicText.text, !systolic.isEmpty,
            let diastolic = diastolicText.text, !diastolic.isEmpty
            else {
                saveButton.isEnabled = false
                return
            }
        // Enable Save if textfields are not empty
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelSettings(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
