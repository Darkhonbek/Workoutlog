//
//  DayTableViewController.swift
//  WorkoutLog 0.2
//
//  Created by Darkhonbek Mamataliev on 914//17.
//  Copyright © 2017 Darkhonbek Mamataliev. All rights reserved.
//

import CoreData
import UIKit

class DayTableViewController: UITableViewController {
    
    @IBOutlet weak var navItem: UINavigationItem!
    public var container: NSPersistentContainer?
    public var dayLog: DayLog? {
        didSet {
            updateUI()
        }
    }
    private var exercises: [ExerciseLog] {
        get {
            return (dayLog?.getExerciseArray()) ?? [ExerciseLog]()
        }
    }
    
    private func updateUI() {
        if let title = dayLog?.number {
            navItem.title = String(title)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableData), name: NSNotification.Name(rawValue: "loadExercises"), object: nil)
    }
    
    @objc private func updateTableData(){
        //MARK: Optimize
        //Very heavy fn call
        loadExerciseLogs()
        tableView.reloadData()
    }
    
    private func loadExerciseLogs() {
        if let unwrappedDayLog = self.dayLog,
            let context = container?.viewContext{
            if let updatedDayLog = try? ExerciseLog.reloadDayLog(unwrappedDayLog, in: context) {
                self.dayLog = updatedDayLog
            }
        }
    }
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Adding new exercise log" {
                if let vc = segue.destination as? AddLogPopUpViewController {
                    vc.dayLog = dayLog
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return exercises.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < exercises.count {
            let sets = exercises[section].getSortedSetArray()
            return sets.count
        }
        return 0
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < exercises.count {
            return exercises[section].name
        }
        print("Error in DayTableViewController")
        return "Error, see log for details"
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setLog", for: indexPath)
        let exerciseLog = exercises[indexPath.section]
        let setLog = exerciseLog.getSortedSetArray()[indexPath.row]

        if let setCell = cell as? SetTableViewCell {
            setCell.setLog = setLog
        }
        
        return cell
    }
    
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

}