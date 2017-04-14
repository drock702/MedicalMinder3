//
//  HomeView.swift
//  MedicalMinder
//
//  Created by Derrick Price on 9/4/16.
//  Copyright © 2016 DLP. All rights reserved.
//


import UIKit
import CoreData

class MedicalMinderView: UIViewController {
    
    var selectedUser: UserInfo!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let theUsersInfo = fetchUserInfo()
        // Get the first user
        selectedUser = theUsersInfo.first
    }
    
    // Get the UserInfo from the context
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        navigationItem.title = nil
        // Get latest user data
        let theUsersInfo = self.fetchUserInfo()
        
        // Get the first user
        selectedUser = theUsersInfo.first
        
        if (segue.identifier == "showPrescriptionsSegue") {
            
            if let controller: PrescriptionsTableViewController = segue.destination as? PrescriptionsTableViewController{
                
                controller.selectedUser = selectedUser
            }
            
        }
        else if (segue.identifier == "showBloodPressureSegueID") {
            
            if let controller: BloodPressureTableViewController = segue.destination as? BloodPressureTableViewController {
                
                controller.selectedUser = selectedUser
            }
        }
        else if (segue.identifier == "showUserInformationSegueID") {
            
            if let controller: UserInformationViewController = segue.destination as? UserInformationViewController {
                
                controller.selectedUser = selectedUser
            }
        }
    }
}
