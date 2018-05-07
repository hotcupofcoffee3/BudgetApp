//
//  BudgetViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/7/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class BudgetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
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
            
            if let start = period.start, let end = period.end {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                let shortStart = dateFormatter.string(from: start)
                let shortEnd = dateFormatter.string(from: end)
                
                if indexPath.row == 0 {
                    
                    cell.textLabel?.text = "Beginning of time - \(shortEnd)"
                    
                } else {
                    
                    cell.textLabel?.text = "\(shortStart) - \(shortEnd)"
                    
                }
                
                
            }

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedStartDate = budget.budgetedTimeFrames[indexPath.row].start
        selectedEndDate = budget.budgetedTimeFrames[indexPath.row].end
        
        selectedCategory = nil
        
        performSegue(withIdentifier: budgetToTransactionsSegueKey, sender: self)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        displayedDataTable.separatorStyle = .none
        loadSavedBudgetedTimeFrames()
        displayedDataTable.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
