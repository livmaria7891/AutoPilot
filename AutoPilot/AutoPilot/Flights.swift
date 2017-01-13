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

    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("flights")
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let steps = "steps"
        static let supplies = "supplies"
        static let isFavorite = "isFavorite"

    }
    
    //MARK: Initialization
    
    init?(name: String, steps: [String]? = [String](), supplies: [String]? = nil, isFavorite: Bool = false) {
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        
        // Initialize stored properties.
        self.name = name
        self.steps = steps
        self.supplies = supplies
        self.isFavorite = isFavorite

    }
    
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(steps, forKey: PropertyKey.steps)
        aCoder.encode(supplies, forKey: PropertyKey.supplies)
        aCoder.encode(isFavorite, forKey: PropertyKey.isFavorite)
        
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
        
        
        // Must call designated initializer.
        self.init(name: name, steps: steps, supplies: supplies, isFavorite: isFavorite)
    }

    
}
