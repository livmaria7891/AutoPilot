//
//  CreateViewController.swift
//  AutoPilot
//
//  Created by Olivia Legge on 1/5/17.
//  Copyright © 2017 Olivia Legge. All rights reserved.
//

import UIKit
import os.log

class CreateViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate {
    
    
    //MARK: Properties
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addStepTextField: UITextField!
    @IBOutlet weak var addSuppliesTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    /*
     This value is either passed by `FlightTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new flight.
     */
    var flight: Flight?
    
    var flightName = String()
    var steps = [String]()
    var supplies = [String](){
        didSet{
            suppliesString = "Here's what you'll need: \n"
            for item in supplies {

                suppliesString += "\(item) \n"
            }
        }
    }
    var suppliesString = ""
    var isFavorite = Bool()
    
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()

        nameTextField.delegate = self
        addStepTextField.delegate = self
        addSuppliesTextField.delegate = self
        
        
        //Set up View with existing Flight info
        if flight != nil {
            nameLabel.text = flightName
            nameTextField.text = flightName
        }
        
        
        // Enable the Save button only if the text field has a valid Flight name.
        
        updateSaveButtonState()
        
        // TEST
        print(supplies)
        print(suppliesString)
        
    }
    
  func loadData(){

        if let flight = flight {
            flightName = flight.name
            
            for item in flight.supplies!{
                supplies.append(item)
                
            }
            
            for step in flight.steps!{
                steps.append(step)
            }
            
            isFavorite = flight.isFavorite
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func Start(_ sender: Any) {
        appDelegate.currentFlightSteps = steps
        appDelegate.flightName = flightName
        appDelegate.flightIsRunning = true
        if (supplies.count > 0){
            appDelegate.suppliesString = suppliesString
        }
    }
    
    @IBAction func editMode(_ sender: Any) {
        tableView.setEditing(true, animated: true)
    }
    
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        if(textField == nameTextField){
            nameTextField.resignFirstResponder()
         }
        
        if(textField == addStepTextField) {
            addStepTextField.resignFirstResponder()
        }
        
        if(textField == addSuppliesTextField) {
            print(">>>>BREADCRUMBS 2")
            addSuppliesTextField.resignFirstResponder()
        }
        
        return true
   
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
//        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if(textField == nameTextField){
           updateSaveButtonState()
           navigationItem.title = textField.text 
        }
        
        if(textField == addStepTextField) {
            let newStep = addStepTextField.text ?? ""
            if(!newStep.isEmpty){
                steps.append(newStep)
            }
            self.tableView.reloadData()
            saveFlight()
            addStepTextField.text = ""
        }
        
        if(textField == addSuppliesTextField) {
            
            let newItem = addSuppliesTextField.text ?? ""
            print(newItem)
            if(!newItem.isEmpty){
                supplies.append(newItem)
            }
            print(supplies)
            saveFlight()
            addSuppliesTextField.text = ""
            
        }
        
    }
    

    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddFlightMode = presentingViewController is UINavigationController
        
        if isPresentingInAddFlightMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The FlightViewController is not inside a navigation controller.")
        }
    }
    

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
         guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
 
        
        let name = nameTextField.text ?? ""
        let steps = self.steps
        let supplies = self.supplies
        let isFavorite = self.isFavorite
        
        
        // Set the flight to be passed to FlightTableViewController or SingleFlightViewController
        flight = Flight(name: name, steps: steps, supplies: supplies, isFavorite: isFavorite )
        
    }
    
    //MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stepCell", for: indexPath)

        
        let step = steps[indexPath.row]
        cell.textLabel?.text = step
      
        return cell
    }
    //for deleting
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
  
        print(indexPath.row)
        if editingStyle == .delete {
            steps.remove(at: indexPath.row)
            saveFlight()
            tableView.deleteRows(at: [indexPath], with: .fade)
        
        }
    }
    //MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
//        let text = nameTextField.text ?? ""
//        saveButton.isEnabled = !text.isEmpty
    }
    
    private func saveFlight() {
        if flight != nil{
            
            let thisFlight = Flight(name: flightName, steps: steps, supplies: supplies, isFavorite: isFavorite)
            
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(thisFlight as Any, toFile: Flight.ArchiveURL.path)
            if isSuccessfulSave {
                os_log("Flight successfully saved.", log: OSLog.default, type: .debug)
            } else {
                os_log("Failed to save flight...", log: OSLog.default, type: .error)
            
            }
            
        }
    }
    
 

}


