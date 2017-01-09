//
//  SingleFlightViewController.swift
//  AutoPilot
//
//  Created by Olivia Legge on 1/7/17.
//  Copyright © 2017 Olivia Legge. All rights reserved.
//

import UIKit

class SingleFlightViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Navigation
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        
        
        
        //OLIVIA::: Here you can enable features for editing or not editing depending on the segue
//        if (segue.identifier == <my identifier here>) {
//            // pass data to next view
//        }
//        
    }
    

}
