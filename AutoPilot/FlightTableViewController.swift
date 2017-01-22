//
//  FlightTableViewController.swift
//  AutoPilot
//
//  Created by Olivia Legge on 1/5/17.
//  Copyright © 2017 Olivia Legge. All rights reserved.
//

import UIKit
import os.log

class FlightTableViewController: UITableViewController, UIViewControllerTransitioningDelegate {
    
    //MARK: Properties
    
    var flights = [Flight]()
    
    var favorites = [Flight]()
    var notFavorited = [Flight]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling
        self.tableView.backgroundColor = UIColor(netHex: 0xFAFAFA)
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved meals, otherwise load sample data.
        if let savedFlights = loadFlights() {
            flights += savedFlights
        }
        else {
            // Load the sample data.
            loadSampleFlights()
        }
        
        // Sort All Flights By Favorites
        for flight in flights {
            sortFavorites(flight: flight)
        }

        // Gesture Recognizer for Swipe
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(FlightTableViewController.swipeGesture(sender:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rowCount = 0
        if section == 0 {
            rowCount = favorites.count
        }
        
        if section == 1 {
            rowCount = notFavorited.count
        }

        return rowCount

    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = "Flights"
        
        if section == 0 {
            title = "Favorites"
            
        }
        
        return title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "FlightTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FlightTableViewCell else {
            fatalError("The dequeued cell is not an instance of FlightTableViewCell.")
        }
        
        // Fetches the appropriate flight for the data source layout.
        
        //FOR FIXING
//        if indexPath.section == 0 { //favorites
//                      let flight = flights[indexPath.row]
//                        cell.flightName.text = flight.name
//        }

        if indexPath.section == 0 { //favorites
            let flight = favorites[indexPath.row]
            cell.flightName.text = flight.name
        }
        
        if indexPath.section == 1 { //non-favorites
            let flight = notFavorited[indexPath.row]
            cell.flightName.text = flight.name
        }
        
        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            flights.remove(at: indexPath.row)
            saveFlights()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddFlight":
            os_log("Adding a new flight.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let flightDetailViewController = segue.destination as? CreateViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedFlightCell = sender as? FlightTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedFlightCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedFlight = flights[indexPath.row]
            flightDetailViewController.flight = selectedFlight
            
        case "goHome":
            print("Segue to launch screen")
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    // For Swipe Gesture
    
    func swipeGesture(sender: UISwipeGestureRecognizer) {
          
        
        if sender.direction == .right {
            
            self.performSegue(withIdentifier: "goHome", sender: self)
            
        }
    }

    

    
    //MARK: Actions
    
    @IBAction func unwindToFlightList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? CreateViewController, let flight = sourceViewController.flight {
            
            
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    // Update an existing flight.
                    if sourceViewController.deleteClicked == true {
                        print(selectedIndexPath)
                        print(selectedIndexPath.row)
                        
                        //Specifics.. rewrite for all circumstances
                        if !flight.isFavorite{
                            notFavorited.remove(at: selectedIndexPath.row)
                            rebuildFlightsArray()
                           
                        } else {
                            favorites.remove(at: selectedIndexPath.row)
                            rebuildFlightsArray()
                
                        }
                        
                       tableView.deleteRows(at: [selectedIndexPath], with: .fade)

                        sourceViewController.deleteClicked = false
                        
                    } else {
                        flights[selectedIndexPath.row] = flight
                        tableView.reloadRows(at: [selectedIndexPath], with: .none)
                    }
                } else {
            
                    // Add a new flight.
                    
                    sortFavorites(flight: flight)
                    
                    var newIndexPath = IndexPath(row: notFavorited.count - 1, section: 1)
                    
                    if flight.isFavorite {
                        newIndexPath = IndexPath(row: favorites.count - 1, section: 0)
                    }
                    
                    rebuildFlightsArray ()
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                  
                }
            
                saveFlights()
            
            
            
        }
        
        
    }

    //MARK: Private Methods
    
    // Fake Model Data

    private func loadSampleFlights() {
    
    
        guard let flight1 = Flight(name: "Morning Routine", steps: ["Wake up", "Make Coffee", "Shower"], supplies: ["overhead light", "coffee maker"], isFavorite: true) else {
            fatalError("Unable to instantiate flight")
        }
        
        guard let flight2 = Flight(name: "Work Routine", supplies: ["desk"]) else {
            fatalError("Unable to instantiate flight2")
        }
        
        guard let flight3 = Flight(name: "Bedtime Routine", steps: ["Get in Bed", "Fall Asleep"], supplies: ["overhead light", "coffee maker"], isFavorite: true) else {
            fatalError("Unable to instantiate flight3")
        }
        
        
        flights += [flight1, flight2, flight3]
        
    }
    
    private func saveFlights() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(flights, toFile: Flight.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Flights successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save flights...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadFlights() -> [Flight]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Flight.ArchiveURL.path) as? [Flight]
        
    }
    
    private func sortFavorites(flight: Flight) {
        if flight.isFavorite {
            favorites.append(flight)
        } else {
            notFavorited.append(flight)
        }
    }
    
    private func rebuildFlightsArray() {
        flights = favorites + notFavorited
    }

}
