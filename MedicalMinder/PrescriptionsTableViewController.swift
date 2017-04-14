//
//  PrescriptionsTableViewController.swift
//  MedicalMinder
//
//  Created by Derrick Price on 9/13/16.
//  Copyright © 2016 DLP. All rights reserved.
//

import UIKit
import CoreData

class PrescriptionsTableViewController: UITableViewController {
    
    var prescriptions: [Prescription]!
    var selectedUser : UserInfo?
    
    @IBOutlet var prescriptionsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the name in the title
        if let user = selectedUser {
            self.navigationItem.title! +=  (" - " + user.name)
        }
        else {
         self.navigationItem.title = "Prescriptions"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // retrieve the prescriptions stored in AppDelegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        prescriptions = appDelegate.prescriptions
        
        DispatchQueue.main.async {
            
            self.prescriptions = self.fetchAllPrescriptions()
//            for med in self.prescriptions {
//                
//                print ("There is a reading \(med.name) \\ \(med.dosageNumber), \(med.dosageUnits), \(med.dosageFrequency)")
//            }
//            
//            print ("There are \(self.prescriptions.count) prescriptions on will appear after fetch")
            
            // retrieve the prescriptions stored in context and update the appdelegate
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.prescriptions = self.prescriptions
            
            // Update the table view
            self.tableView.reloadData()
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // Retrieve the cached prescriptions
    func fetchAllPrescriptions() -> [Prescription] {
        
//        print ("Call fetchAllPrescriptions!!\n\n")
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Prescription")
        //fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Execute the Fetch Request
        do {
            return try sharedContext.fetch(fetchRequest) as! [Prescription]
        } catch _ {
            return [Prescription]()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the # of prescriptions
        return self.prescriptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionsTableCell", for: indexPath) as! PrescriptionTableViewCell
        let prescription = self.prescriptions[indexPath.row]
        
//        print ("Tableview at cell row at index path")
        
  //      cell.medicineImageView.image = UIImage(named: "medicineFrame")
        cell.medicineNameLabel!.text = prescription.name
        cell.medicineDosageLabel!.text = (prescription.dosageNumber.description) + " " + (prescription.dosageUnits?.lowercased())! + " every " + (prescription.dosageFrequency.description) + " hours " + (prescription.dosagePerDay.description) + " times per day"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let prescription = self.prescriptions[indexPath.row]
        let controller = storyboard!.instantiateViewController(withIdentifier: "PrescriptionDetailStoryboardID") as! PrescriptionDetailViewController
        
        controller.medicalName = prescription.name

        if prescription.overview != nil {
            controller.medicalOverview = prescription.overview
        }
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch (editingStyle) {
        case .delete:
            // Remove from the storage array
            prescriptions.remove(at: indexPath.row)
            // Remove from the table view
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            // Update the Core Data
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            sharedContext.delete(appDelegate.prescriptions.remove(at: indexPath.row))
            CoreDataStackManager.sharedInstance().saveContext()
            
            self.tableView.isEditing = false
            self.tableView.endEditing(true)
        default:
            break
        }
    }
    
    @IBAction func editTable(_ sender: UIBarButtonItem)
    {
        setEditing(true, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = nil
        
        if (segue.identifier == "showNewPrescriptionViewID") {
            
            if let controller: NewPrescriptionViewController = segue.destination as? NewPrescriptionViewController
            {
                controller.selectedUser = selectedUser
            }
            
        }
    }
}
