//
//  CreateViewController.swift
//  AutoPilot
//
//  Created by Olivia Legge on 1/5/17.
//  Copyright © 2017 Olivia Legge. All rights reserved.
//

import UIKit
import os.log

class CreateViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    
    /*
     This value is either passed by `FlightTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new flight.
     */
    var flight: Flight?
    
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
        
        //Set up View with existing Flight info
        if let flight = flight {
            nameLabel.text = flight.name
        }
        
        
        // Enable the Save button only if the text field has a valid Flight name.
        updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       updateSaveButtonState()
       navigationItem.title = textField.text 
        
        //Code to set Name in Model
        
    }
    

    
    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        
    }
    

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
         guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
 
        
        let name = nameTextField.text ?? ""
        
        
        // Set the flight to be passed to FlightTableViewController or SingleFlightViewController
        flight = Flight(name: name, steps: [], supplies: [], isFavorite: false )
        
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
 

}
