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
    
    var theUserInfo = [UserInfo]()
    var selectedUser : UserInfo?
    
    // Usual setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Initialize the form
        if (selectedUser != nil) {
            self.username.text = selectedUser!.name
            self.userDOB.date = selectedUser!.birthdate as Date
            self.bloodType.text = selectedUser!.blood_type
            self.iceContact.text = selectedUser!.ice_contact
            self.physician.text = selectedUser!.doctor
        }
    }
    
    func fetchUserInfo() -> [UserInfo] {
        
        print ("Look for user information\n")
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
//        return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.characters.indices) == nil
    }
    
    @IBAction func saveSettings(_ sender: UIButton) {
        
        let scriptDictionary: [String : AnyObject] = [
            UserInfo.Keys.Name : username.text! as AnyObject,
            UserInfo.Keys.Birthdate : userDOB.date as AnyObject,
            UserInfo.Keys.Bloodtype : bloodType.text! as AnyObject,
            UserInfo.Keys.ICE : iceContact.text! as AnyObject,
            UserInfo.Keys.Doctor : physician.text! as AnyObject
        ]
        
        // Now we create a new user, save using the shared Context
        let newUser = UserInfo(dictionary: scriptDictionary, context: sharedContext)
        
        // Save userinformation, save to the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        // Only store one object
        if (appDelegate.masterUserInfo.count > 1) {
            appDelegate.masterUserInfo.removeAll()
        }
        appDelegate.masterUserInfo.append(newUser)
        
        // Save the settings and exit
        self.saveContext()
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelSettings(_ sender: UIButton) {

        _ = self.navigationController?.popViewController(animated: true)
    }
}
