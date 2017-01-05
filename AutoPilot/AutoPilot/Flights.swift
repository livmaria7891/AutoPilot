//
//  Flights.swift
//  AutoPilot
//
//  Created by Olivia Legge on 1/5/17.
//  Copyright © 2017 Olivia Legge. All rights reserved.
//

import UIKit

class Flight {
    
    //MARK: Properties
    
    var name: String
    var steps: [String]?

    
    //MARK: Initialization
    
    init?(name: String, steps: [String]?) {
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        
        // Initialize stored properties.
        self.name = name
        self.steps = steps
    }
    
}
