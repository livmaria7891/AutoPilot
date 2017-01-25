//
//  Flights.swift
//  AutoPilot
//
//  Created by Olivia Legge on 1/5/17.
//  Copyright © 2017 Olivia Legge. All rights reserved.
//

import UIKit
import os.log

class Flight: NSObject, NSCoding {
    
    //MARK: Properties
    
    var name: String
    var steps: [String]?
    var supplies: [String]?
    var isFavorite: Bool
    var avgTime = Double()

    //MARK: Business Logic
    
    func setAverageTime(start: Date, end: Date){
        let interval = end.timeIntervalSince(start as Date)
        if avgTime > 0 {
            avgTime = (avgTime + interval)/2
        } else {
            avgTime = interval
        }
        print(avgTime)
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("flights")
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let steps = "steps"
        static let supplies = "supplies"
        static let isFavorite = "isFavorite"
        static let avgTime = "avgTime"
    }
    
    //MARK: Initialization
    
    init?(name: String, steps: [String]? = [String](), supplies: [String]? = nil, isFavorite: Bool = false, avgTime: Double = 0.0) {
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        
        // Initialize stored properties.
        self.name = name
        self.steps = steps
        self.supplies = supplies
        self.isFavorite = isFavorite
        self.avgTime = avgTime

    }
    
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(steps, forKey: PropertyKey.steps)
        aCoder.encode(supplies, forKey: PropertyKey.supplies)
        aCoder.encode(isFavorite, forKey: PropertyKey.isFavorite)
        aCoder.encode(avgTime, forKey: PropertyKey.avgTime)
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Flight object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let steps = aDecoder.decodeObject(forKey: PropertyKey.steps) as? [String]
        
        let supplies = aDecoder.decodeObject(forKey: PropertyKey.supplies) as? [String]
        
        let isFavorite = aDecoder.decodeBool(forKey: PropertyKey.isFavorite)
        
        let avgTime = aDecoder.decodeDouble(forKey: PropertyKey.avgTime)
        
        // Must call designated initializer.
        self.init(name: name, steps: steps, supplies: supplies, isFavorite: isFavorite, avgTime: avgTime)
    }
    
    //MARK: Save
//    func save() {
//        
//        let flights = NSKeyedUnarchiver.unarchiveObject(withFile: Flight.ArchiveURL.path) as? [Flight]
//            
//        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(flights ?? <#default value#>, toFile: Flight.ArchiveURL.path)
//        
//        if isSuccessfulSave {
//        os_log("Flights successfully saved.", log: OSLog.default, type: .debug)
//        } else {
//        os_log("Failed to save flights...", log: OSLog.default, type: .error)
//        }
//        
//        NSKeyedUnarchiver.unarchiveObject(withFile: Flight.ArchiveURL.path) as? [Flight]
//    }


}
