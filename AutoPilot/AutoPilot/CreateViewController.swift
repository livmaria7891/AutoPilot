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
    @IBOutlet weak var titleTextView: UITextField!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var addStepButton: UIButton!
    @IBOutlet weak var addSuppliesButton: UIButton!
    @IBOutlet weak var addStepTextField: UITextField!
    @IBOutlet weak var addSuppliesTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    
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
    var index = Int()
    
    var deleteClicked = false
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()

        // Text Field Delegates
        titleTextField.delegate = self
        nameTextField.delegate = self
        addStepTextField.delegate = self
        addSuppliesTextField.delegate = self

        
        // Basic View Element Configurations
        
        // Display Flight info if flight exists
        if flight != nil {
            titleTextField.text = flightName
            nameTextField.isHidden = true
            
        }
        
        if flight == nil {
            startButton.isHidden = true
        }
        
        addStepButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        addStepButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        addStepButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        addSuppliesButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        addSuppliesButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        addSuppliesButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)

        // Table View Configurations
        self.tableView.isScrollEnabled = true
//        self.tableView.isEditing = true
        
        // Enable the Save button only if the text field has a valid Flight name.
//        updateSaveButtonState()
        
        
    }
    
  func loadData(){

        if let flight = flight {
            navigationItem.title = flight.name
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

        
        let startAlertController = UIAlertController(title: "\(flightName)", message: "Time to lock your phone and get started!", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Got it.", style: .default, handler: nil)
        startAlertController.addAction(defaultAction)
        
        present(startAlertController, animated: true, completion: nil)
        
        if (supplies.count > 0){
            appDelegate.suppliesString = suppliesString
        }
    }
    
    
    @IBAction func addStep(_ sender: Any) {
        if addStepTextField.isFirstResponder{
            addStepTextField.resignFirstResponder()
            
            let newStep = addStepTextField.text ?? ""
            if(!newStep.isEmpty){
                steps.append(newStep)
            }
            self.tableView.reloadData()
            saveFlight()
            addStepTextField.text = ""
            
        } else {
            addStepTextField.becomeFirstResponder()
            
        }
    }

    @IBAction func addSupplies(_ sender: Any) {
        if addSuppliesTextField.isFirstResponder{
            addSuppliesTextField.resignFirstResponder()
            
            let newItem = addSuppliesTextField.text ?? ""
            if(!newItem.isEmpty){
                steps.append(newItem)
            }
            self.tableView.reloadData()
            saveFlight()
            addSuppliesTextField.text = ""
            
        } else {
            addSuppliesTextField.becomeFirstResponder()
            
        }
    }
    
    @IBAction func edit(_ sender: Any) {
        if tableView.isEditing == false {
            tableView.setEditing(true, animated: true)
            editButton.setTitle("Done Editing", for: .normal)
        } else {
            tableView.setEditing(false, animated: true)
            editButton.setTitle("Edit", for: .normal)
        }
    }
    
    @IBAction func deleteFlight(_ sender: Any) {
        let deleteAlertController = UIAlertController(title: "\(flightName)", message: "Are you sure you want to delete \(flightName)?", preferredStyle: .alert)
        deleteAlertController.addAction(UIAlertAction(title: "Yes, Delete", style: .default, handler: {action in self.deleteFlight() }))
        deleteAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(deleteAlertController, animated: true, completion: nil)
        
    }
    
    


    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        
        if(textField == titleTextField){
            titleTextField.resignFirstResponder()
        }
        if(textField == nameTextField){
            nameTextField.resignFirstResponder()
         }
        
        if(textField == addStepTextField) {
            addStepTextField.resignFirstResponder()
        }
        
        if(textField == addSuppliesTextField) {
            addSuppliesTextField.resignFirstResponder()
        }
        
        return true
   
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
//        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if(textField == nameTextField || textField == titleTextField){
//           updateSaveButtonState()
           titleTextField.text = textField.text
           nameTextField.placeholder = textField.text
           flightName = textField.text!
           saveFlight()
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
            self.tableView.reloadData()
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
 
        
        let name = flightName
        let steps = self.steps
        let supplies = self.supplies
        let isFavorite = self.isFavorite
        
        
        // Set the flight to be passed to FlightTableViewController or SingleFlightViewController
        flight = Flight(name: name, steps: steps, supplies: supplies, isFavorite: isFavorite )
        
    }
    
    //MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if section == 0 {
            rowCount = steps.count
        }
        
        if section == 1 {
            rowCount = supplies.count
        }
        
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = flightName
        
        if section == 0 {
            title = "Steps"
        }
        
        if section == 1 {
            title = "Supplies"
        }
        
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stepCell", for: indexPath)

        if indexPath.section == 0{
            let step = steps[indexPath.row]
            cell.textLabel?.text = step
        }
        
        if indexPath.section == 1{
            let item = supplies[indexPath.row]
            cell.textLabel?.text = item
        }
        
        return cell
    }
    
    //for deleting steps
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        
        print(indexPath.row)
        if editingStyle == .delete {
       
            steps.remove(at: indexPath.row)
         
            saveFlight()
           
            tableView.deleteRows(at: [indexPath], with: .fade)

        }
        
        if editingStyle == .delete {
            steps.remove(at: indexPath.row)
            saveFlight()
            tableView.deleteRows(at: [indexPath], with: .fade)
        
        }
    }
    
    //For Changing Order of Cells
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .none
//    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.steps[sourceIndexPath.row]
        steps.remove(at: sourceIndexPath.row)
        steps.insert(movedObject, at: destinationIndexPath.row)
        NSLog("%@", "\(sourceIndexPath.row) => \(destinationIndexPath.row) \(steps)")
        // To check for correctness enable: self.tableView.reloadData()
        
        print(steps)
        saveFlight()
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
    
    private func deleteFlight() {
    
//        print(Flight.ArchiveURL.path)
//        
//        var allFlights = (NSKeyedUnarchiver.unarchiveObject(withFile: Flight.ArchiveURL.path) as? [Flight])
//        
//        print(allFlights ?? "nothing here")
// 
//        allFlights?.remove(at: index)
//
//        saveAllFlights(list: allFlights!)
        
        deleteClicked = true
        
        self.performSegue(withIdentifier: "unwindAfterDelete", sender: self)
    }
    
//    private func saveAllFlights(list: [Flight]) {
//        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(list, toFile: Flight.ArchiveURL.path)
//        
//        if isSuccessfulSave {
//            os_log("Flights successfully saved.", log: OSLog.default, type: .debug)
//        } else {
//            os_log("Failed to save flights...", log: OSLog.default, type: .error)
//        }
//        
//    }
    

}



