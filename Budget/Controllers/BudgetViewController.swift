//
//  BudgetViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/7/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class BudgetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // *****
    // MARK: - Variables
    // *****
    
    
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    
    
    
    
    // *****
    // MARK: - TableView
    // *****
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return budget.budgetedTimeFrames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = displayedDataTable.dequeueReusableCell(withIdentifier: "BudgetCell", for: indexPath)
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        cell.textLabel?.textColor = UIColor.white
        
        cell.accessoryType = .disclosureIndicator
        
        if budget.budgetedTimeFrames.count > 0 {
            
            let period = budget.budgetedTimeFrames[indexPath.row]
            
            if indexPath.row == 0 {
                
                cell.textLabel?.text = "Beginning of time - \(period.endMonth)/\(period.endDay)/\(period.endYear)"
                
            } else {
                
                cell.textLabel?.text = "\(period.startMonth)/\(period.startDay)/\(period.startYear) - \(period.endMonth)/\(period.endDay)/\(period.endYear)"
                
            }
            
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedStartDate = Int(budget.budgetedTimeFrames[indexPath.row].startDateID)
        selectedEndDate = Int(budget.budgetedTimeFrames[indexPath.row].endDateID)
        
        selectedCategory = nil
        
        performSegue(withIdentifier: budgetToTransactionsSegueKey, sender: self)
    }
    
    
    
    // *****
    // MARK: - PickerView
    // *****
    
    
    
    
    
    // *****
    // MARK: - DatePickerView
    // *****
    
    
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    func loadNecessaryInfo() {
        
        displayedDataTable.separatorStyle = .none
        loadSavedBudgetedTimeFrames(descending: true)
        displayedDataTable.reloadData()
        print(budget.budgetedTimeFrames.count)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadNecessaryInfo()
        
        self.displayedDataTable.rowHeight = 90
        
        self.displayedDataTable.register(UINib(nibName: "BudgetTableViewCell", bundle: nil), forCellReuseIdentifier: "BudgetTableViewCell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.loadNecessaryInfo()
        
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    
    
    

    

}








