//
//  FlightTableViewController.swift
//  AutoPilot
//
//  Created by Olivia Legge on 1/5/17.
//  Copyright © 2017 Olivia Legge. All rights reserved.
//

import UIKit
import os.log

class FlightTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var flights = [Flight]()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadSampleFlights()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return flights.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "FlightTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FlightTableViewCell else {
            fatalError("The dequeued cell is not an instance of FlightTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let flight = flights[indexPath.row]
        
        cell.flightName.text = flight.name
        cell.categoryImage.image = nil
        cell.favoriteImage.image = flight.favImage
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    //MARK: Actions
    
    @IBAction func unwindToFlightList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? CreateViewController, let flight = sourceViewController.flight {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing flight.
                flights[selectedIndexPath.row] = flight
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
            
                // Add a new flight.
                let newIndexPath = IndexPath(row: flights.count, section: 0)
                flights.append(flight)
                
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
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

}
