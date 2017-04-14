//
//  MedicalMinderHomeViewController.swift
//  MedicalMinder
//
//  Created by Derrick Price on 8/15/16.
//  Copyright © 2016 DLP. All rights reserved.
//

import UIKit
import CoreData

class MedicalMinderHomeViewController : UITableViewController, NSFetchedResultsControllerDelegate, PersonalInfoViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addPatient")
   
//        // Step 2: invoke fetchedResultsController.performFetch() here, and add in the do, try, catch
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            print("Unresolved error \(error)")
//            abort()
//        }
//        
//        // Step 9: set the fetchedResultsController.delegate = self
//        // Here we start the fetch. We aren’t checking for an
//        // error, just to keep things simple
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {}
        // Set the view controller as! the delegate
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // Core Data Convenience
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // The lazy fetchedResultsController property.
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Patient")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
        
        }()
    
    
    // Add a new patient
    func addPatient() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PersonalInfoViewController") as! PersonalInfoViewController
        
        controller.delegate = self
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: - Patient Info Delegate
    
    func patientPicker(patientPicker: PersonalInfoViewController, didPickPatient patient: Patient?) {
        
        
        if let newPatient = patient {
            
            // Debugging output
            print("picked patient with name: \(newPatient.name),  id: \(newPatient.id), profilePath: \(newPatient.imagePath)")
            
            let dictionary: [String : AnyObject] = [
                Person.Keys.ID : newPatient.id,
                Person.Keys.Name : newActor.name,
                Person.Keys.ProfilePath : newActor.imagePath ?? ""
            ]
            
            // Now we create a new Person, using the shared Context
            let actorToBeAdded = Person(dictionary: dictionary, context: sharedContext)
            
            // Step 3: Do not add actors to the actors array.
            // This is no longer necessary once we are modifying our table through the
            // fetched results controller delefate methods
            //            self.actors.append(actorToBeAdded)
            
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    // MARK: - Table View
    
    // Step 6: Replace the actors array in the table view methods. See the comments below
    
    // This one is particularly tricky. You will need to get the "section" object for section 0, then
    // get the number of objects in this section. See the reference sheet for an example.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return (sectionInfo as! NSFetchedResultsSectionInfo).numberOfObjects
    }
    
    // This one is easy. Get the actor using the following statement:
    //
    //        fetchedResultsController.objectAtIndexPath(:) as Person
    //
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //        let actor = actors[indexPath.row]
        let actor = fetchedResultsController.objectAtIndexPath(indexPath) as! Person
        let CellIdentifier = "ActorCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! ActorTableViewCell
        
        // This is new.
        configureCell(cell, withActor: actor)
        
        return cell
    }
    
    // This one is also fairly easy. You can get the actor in the same way as cellForRowAtIndexPath above.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("MovieListViewController") as! MovieListViewController
        //        let actor = actors[indexPath.row]
        let actor = fetchedResultsController.objectAtIndexPath(indexPath) as! Person
        
        controller.actor = actor
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    // This one is a little tricky. Instead of removing from the actors array you want to delete the actor from
    // Core Data.
    // You can accomplish this in two steps. First get the actor object in the same way you did in the previous two methods.
    // Then delete the actor using this invocation
    //
    //        sharedContext.deleteObject(actor)
    //
    // After that you do not need to delete the row from the table. That will be handled in the delegate. See reference sheet.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (editingStyle) {
        case .Delete:
            let actor = fetchedResultsController.objectAtIndexPath (indexPath) as! Person
            sharedContext.deleteObject(actor)
            //            actors.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        default:
            break
        }
    }
    
    // MARK: - Configure Cell
    
    // This method is new. It contains the code that used to be in cellForRowAtIndexPath.
    // Refactoring it into its own method allow the logic to be reused in the fetch results
    // delegate methods
    
    func configureCell(cell: ActorTableViewCell, withActor actor: Person) {
        cell.nameLabel!.text = actor.name
        cell.frameImageView.image = UIImage(named: "personFrame")
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        if let localImage = actor.image {
            cell.actorImageView.image = localImage
        } else if actor.imagePath == nil || actor.imagePath == "" {
            cell.actorImageView.image = UIImage(named: "personNoImage")
        }
            
            // If the above cases don't work, then we should download the image
            
        else {
            
            // Set the placeholder
            cell.actorImageView.image = UIImage(named: "personPlaceholder")
            
            
            let size = TheMovieDB.sharedInstance().config.profileSizes[1]
            let task = TheMovieDB.sharedInstance().taskForImageWithSize(size, filePath: actor.imagePath!) { (imageData, error) -> Void in
                
                if let data = imageData {
                    dispatch_async(dispatch_get_main_queue()) {
                        let image = UIImage(data: data)
                        actor.image = image
                        cell.actorImageView.image = image
                    }
                }
            }
            
            cell.taskToCancelifCellIsReused = task
        }
    }
    
    // Step 7: You can implmement the delegate methods here. Or maybe above the table methods. Anywhere is fine.
    func controllerWillChangeContext (controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    
    //
    // This is the most interesting method. Take particular note of way the that newIndexPath
    // parameter gets unwrapped and put into an array literal: [newIndexPath!]
    //
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                
            case .Update:
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as! ActorTableViewCell
                let actor = controller.objectAtIndexPath(indexPath!) as! Person
                self.configureCell(cell, withActor: actor)
                
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    
    // MARK: - Saving the array
    
    var actorArrayURL: NSURL {
        let filename = "favoriteActorsArray"
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        
        return documentsDirectoryURL.URLByAppendingPathComponent(filename)
    }
}
