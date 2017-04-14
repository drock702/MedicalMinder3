//
//  BloodPressureTableViewController.swift
//  MedicalMinder
//
//  Created by Derrick Price on 9/15/16.
//  Copyright © 2016 DLP. All rights reserved.
//

import UIKit
import CoreData

class BloodPressureTableViewController: UITableViewController {

    var bloodPressures = [BloodPressure]()
    var selectedUser : UserInfo?
    
    var temporaryContext: NSManagedObjectContext!
    
    // Usual setup
    override func viewDidLoad() {
        // Set the temporary context
        temporaryContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator
        
        // Set the name in the title
        if let user = selectedUser {
            self.navigationItem.title! +=  (" - " + user.name)
        }
        else {
            self.navigationItem.title = "Blood Pressures"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // retrieve the memes stored in AppDelegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        bloodPressures = appDelegate.bloodPressures
        
       DispatchQueue.main.async {
            
            self.bloodPressures = self.fetchAllReadings()
        
            // retrieve the prescriptions stored in context and update the appdelegate
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.bloodPressures = self.bloodPressures
            
            // Update the table view
            self.tableView.reloadData()
        }
        
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
    
    func fetchAllReadings() -> [BloodPressure] {
        
//        print ("Call fetchAllReadings!!\n\n")
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BloodPressure")
        //fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Execute the Fetch Request
        do {
            return try sharedContext.fetch(fetchRequest) as! [BloodPressure]
        } catch _ {
            return [BloodPressure]()
        }
    }
    
    
    // Table View Delegate and Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the # of prescriptions
        return bloodPressures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellReuseId = "BloodPressureTableCell"
        let bloodpressure = bloodPressures[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId)! as! BloodPressureTableCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy 'at' h:mm:ss a"
        
        cell.dateTimeLabel!.text = dateFormatter.string(from: bloodpressure.dateTaken as Date)
        cell.systolicLabel!.text = bloodpressure.systolic.description
        cell.diastolicLabel!.text = bloodpressure.diastolic.description
        
        return cell
        
    }
    
    @IBAction func editTable(_ sender: UIBarButtonItem) {
        setEditing(true, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
//        print ("tableView(tableView: UITableView, commitEditingStyle) called")
        
        switch (editingStyle) {
        case .delete:
            // Remove from the storage array
            bloodPressures.remove(at: indexPath.row)
            // Remove from the table view
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            // Update the Core Data
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            sharedContext.delete(appDelegate.bloodPressures.remove(at: indexPath.row))
            CoreDataStackManager.sharedInstance().saveContext()
            
            self.tableView.isEditing = false
            self.tableView.endEditing(true)
        default:
            break
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = nil
        
        if (segue.identifier == "showNewBloodPressureViewID") {
            
            if let controller: NewBloodPressureViewController = segue.destination as? NewBloodPressureViewController
            {
                controller.user = selectedUser
            }
            
        }
    }
    
}
