//
//  HistoryTableViewController.swift
//  WorkoutLog 0.2
//
//  Created by Darkhonbek Mamataliev on 913//17.
//  Copyright © 2017 Darkhonbek Mamataliev. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {
    
    var days = Array<DayLog>()
    var container = AppDelegate.persistentContainer
    var selectedRow = 0
    private var dayToProceed: DayLog?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableData), name: NSNotification.Name(rawValue: "loadDays"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(proceedToDay), name: NSNotification.Name(rawValue: "Day exists, proceed to day info"), object: nil)
        loadDayLogs()
    }
    
    @objc private func updateTableData(){
        //MARK: Optimize
        //Very heavy fn call
        loadDayLogs()
        tableView.reloadData()
        proceedToDay()
    }
    private func loadDayLogs() {
        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        let descriptor = NSSortDescriptor(key: "number", ascending: false)
        request.sortDescriptors = [descriptor]
        let context = container.viewContext
        
        context.performAndWait { [weak self] in
            if let days = try? context.fetch(request) {
                self?.days = days
            }
        }
    }
    
    @objc private func proceedToDay() {
        if let date = AddDayPopUpViewController.date {
            for day in days {
                if day.date == date {
                    dayToProceed = day
                    performSegue(withIdentifier: "Day information", sender: self)
                    break
                }
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayLog", for: indexPath)
        let dayLog = days[indexPath.row]
        if let dayCell = cell as? DayTableViewCell {
            dayCell.dayLog = dayLog
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "Day information" {
                if let dtvc = segue.destination as? DayTableViewController {
                    if let dayCell = sender as? DayTableViewCell {
                        dtvc.dayLog = dayCell.dayLog ?? DayLog()
                        dtvc.container = container
                    }  else {
                        if let htvc = sender as? HistoryTableViewController {
                            dtvc.dayLog = htvc.dayToProceed ?? DayLog()
                            dtvc.container = container
                        }
                    }
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            tableView.beginUpdates()
            
            let dayLogToDelete = days[indexPath.row]
            days.remove(at: indexPath.row)
            container.viewContext.delete(dayLogToDelete)
            try? container.viewContext.save()
            tableView.deleteRows(at: [indexPath], with: .left)
            //updates the rows enumeration
            try? DayLog.updateDayNumeration(in: container.viewContext)
            tableView.endUpdates()
            
            //MARK: Warning - heavy fn call. Optimize to update only a single row
            updateTableData()
        }
    }
}



















