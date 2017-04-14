//
//  BloodPressure.swift
//  MedicalMinder
//
//  Created by Derrick Price on 8/17/16.
//  Copyright © 2016 DLP. All rights reserved.
//

import UIKit
import CoreData

class BloodPressure : NSManagedObject {

    struct Keys {
        static let Date = "dateTaken"
        static let Diastolic = "diastolic"
        static let Systolic = "systolic"
        static let Patient = "patient"
    }
    
    @NSManaged var dateTaken: Date
    @NSManaged var diastolic: NSNumber
    @NSManaged var systolic: NSNumber
    @NSManaged var patient: UserInfo?
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "BloodPressure", in: context)!
        super.init(entity: entity, insertInto: context)
        
        // Dictionary
        diastolic = Int (dictionary[Keys.Diastolic] as! String)! as NSNumber
        systolic = Int (dictionary[Keys.Systolic] as! String)! as NSNumber
        
        dateTaken = dictionary[Keys.Date] as! Date
    }
    
}
