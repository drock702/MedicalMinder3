//
//  UserInformationViewController.swift
//  MedicalMinder3
//
//  Created by Derrick Price on 2/3/17.
//  Copyright © 2017 DLP. All rights reserved.
//

import UIKit
import CoreData

class UserInformationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var userDOB: UIDatePicker!
    @IBOutlet weak var bloodType: UITextField!
    @IBOutlet weak var iceContact: UITextField!
    @IBOutlet weak var physician: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedUser : UserInfo?
    var allUsers : [UserInfo]!
    
    // Usual setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Lock thedate from going in the future
        userDOB.maximumDate = NSDate () as Date
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // retrieve the users stored in AppDelegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        allUsers = appDelegate.masterUserInfo
        
        DispatchQueue.main.async {
            
            self.allUsers = self.fetchUserInfo()
            
            // Initialize the form
            if (self.selectedUser != nil) {
                self.username.text = self.selectedUser!.name
                self.userDOB.date = self.selectedUser!.birthdate as Date
                self.bloodType.text = self.selectedUser!.blood_type
                self.iceContact.text = self.selectedUser!.ice_contact
                self.physician.text = self.selectedUser!.doctor
            }
        }
    }
    
    func fetchUserInfo() -> [UserInfo] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserInfo")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.fetch(fetchRequest) as! [UserInfo]
        } catch _ {
            return [UserInfo]()
        }
    }
    
    // Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // Force only numbers in the text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex..<string.endIndex) == nil
    }
    
    @IBAction func saveSettings(_ sender: UIButton) {
        
        // Save userinformation, save to the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        // Only store one object
        // Refresh the Context
        if (self.allUsers.count > 0) {
            for usr in self.allUsers {
                if let index = self.allUsers.index(of: usr) {
                    
                    self.sharedContext.delete(self.allUsers.remove(at: index))
                }
            }
            self.allUsers.removeAll()
        }
        
        // Remove the users from the appdelegate
        if (appDelegate.masterUserInfo.count > 0) {
            for usr in appDelegate.masterUserInfo {
                if let index = appDelegate.masterUserInfo.index(of: usr) {
                    
                    self.sharedContext.delete(appDelegate.masterUserInfo.remove(at: index))
                }
            }
            appDelegate.masterUserInfo.removeAll()
        }
        
        // Now we create a new user, save using the shared Context
        let scriptDictionary: [String : AnyObject] = [
            UserInfo.Keys.Name : self.username.text! as AnyObject,
            UserInfo.Keys.Birthdate : self.userDOB.date as AnyObject,
            UserInfo.Keys.Bloodtype : self.bloodType.text! as AnyObject,
            UserInfo.Keys.ICE : self.iceContact.text! as AnyObject,
            UserInfo.Keys.Doctor : self.physician.text! as AnyObject
        ]
        
        let newUser = UserInfo(dictionary: scriptDictionary, context: self.sharedContext)
        appDelegate.masterUserInfo.append(newUser)
        
        // Save the settings and exit
        self.saveContext()
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func cancelSettings(_ sender: UIButton) {

        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // Make sure user has entered the required fields
    @IBAction func checkValidFieldEntries(_ sender: UITextField) {
        
        guard let name = username.text, !name.isEmpty
            else {
                saveButton.isEnabled = false
                return
        }
        
        // Enable Save/Delete if name textfield is not empty
        saveButton.isEnabled = true
    }
}
