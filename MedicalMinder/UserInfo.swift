//
//  UserInfo.swift
//  MedicalMinder3
//
//  Created by Derrick Price on 2/3/17.
//  Copyright © 2017 DLP. All rights reserved.
//

import UIKit
import CoreData

class UserInfo : NSManagedObject {
    
    struct Keys {
        static let Name = "name"
        static let Birthdate = "birthdate"
        static let Bloodtype = "blood_type"
        static let ICE = "ice_contact"
        static let Doctor = "doctor"
    }
    
    @NSManaged var name: String
    @NSManaged var birthdate: Date
    @NSManaged var blood_type: String?
    @NSManaged var ice_contact: String?
    @NSManaged var doctor: String?
    @NSManaged var userBloodpressures: [BloodPressure]?
    @NSManaged var userPrescriptions: [Prescription]?
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "UserInfo", in: context)!
        super.init(entity: entity, insertInto: context)
        
        // Dictionary
        name = dictionary[Keys.Name] as! String
        birthdate = dictionary[Keys.Birthdate] as! Date
        blood_type = dictionary[Keys.Bloodtype] as? String
        ice_contact = dictionary[Keys.ICE] as? String
        doctor = dictionary[Keys.Doctor] as? String

    }
    
}
