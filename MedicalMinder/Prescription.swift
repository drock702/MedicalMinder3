//
//  Prescription.swift
//  MedicalMinder
//
//  Created by Derrick Price on 8/17/16.
//  Copyright © 2016 DLP. All rights reserved.
//

import UIKit
import CoreData

class Prescription : NSManagedObject {

    struct Keys {
        static let Name = "name"
        static let DosageNumber = "dosageNumber"
        static let DosageFrequency = "dosageFrequency"
        static let DosagePerDay = "dosagePerDay"
        static let DosageUnits = "dosageUnits"
        static let Overview = "overview"
        static let StartDate = "start_date"
        static let Patient = "patient"
        static let Doctor = "doctor"
    }
    
    @NSManaged var name: String
    @NSManaged var dosageNumber: NSNumber
    @NSManaged var dosageFrequency: NSNumber
    @NSManaged var dosagePerDay: NSNumber
    @NSManaged var dosageUnits: String?
    @NSManaged var overview: String?
    @NSManaged var startDate: Date?
    @NSManaged var doctor: String?
    @NSManaged var patient: UserInfo?
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "Prescription", in: context)!
        super.init(entity: entity, insertInto: context)
        
        // Dictionary
        dosageFrequency = Int (dictionary[Keys.DosageFrequency] as! String)!  as NSNumber
        dosageNumber = Int (dictionary[Keys.DosageNumber] as! String)!  as NSNumber
        dosageUnits = dictionary[Keys.DosageUnits] as? String
        dosagePerDay = Int (dictionary[Keys.DosagePerDay] as! String)! as NSNumber
        name = dictionary[Keys.Name] as! String
        overview = dictionary[Keys.Overview] as? String
        
        // Get the date
        startDate = dictionary[Keys.StartDate] as? Date
        doctor = dictionary[Keys.Doctor] as? String
    }
}




