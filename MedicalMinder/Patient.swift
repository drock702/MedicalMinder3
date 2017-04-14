//
//  Patient.swift
//  MedicalMinder
//
//  Created by Derrick Price on 8/17/16.
//  Copyright © 2016 DLP. All rights reserved.
//

import UIKit
import CoreData

class Patient : NSManagedObject {

    struct Keys {
        static let Name = "name"
        static let Age = "age"
        static let BloodType = "blood_type"
        static let EmergencyName = "emergency_name"
        static let EmergencyNumber = "emergency_number"
        static let Photo = "photo"
        static let Prescriptions = "prescriptions"
    }
    
    @NSManaged var name: String
    @NSManaged var age: Int
    @NSManaged var bloodtype: String?
    @NSManaged var emergencyName: String?
    @NSManaged var emergencyNumber : String?
//    @NSManaged var photo:         TODO?  Remove?
    @NSManaged var bloodpressures: [BloodPressure]?
    @NSManaged var prescriptions: [Prescription]?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Patient", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        name = dictionary[Keys.Name] as! String
        age = dictionary[Keys.Age] as! Int
        bloodtype = dictionary[Keys.BloodType] as? String
        emergencyName = dictionary[Keys.EmergencyName] as? String
        emergencyNumber = dictionary[Keys.EmergencyNumber] as? String
        
        // TODO: Get the patients, blood pressures, and prescriptions????
    }
    
}
