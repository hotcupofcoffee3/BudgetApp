//
//  BudgetItemsViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

var timeFrameStartID = Int()

class BudgetItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // *****
    // MARK: - TableView
    // *****
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return budget.budgetItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let item = budget.budgetItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetItemCell", for: indexPath) as! BudgetItemTableViewCell
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        
        if cell.accessoryType == .detailButton {
            
            cell.accessoryView?.tintColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
            
        } else {
            
            cell.accessoryView?.tintColor = lightGreenColor
            
        }
        
        cell.nameLabel?.text = "\(item.name!)"
        cell.dueDayLabel?.text = item.day > 0 ? "Due: \(item.day)" : ""
        cell.amountLabel?.text = "\(convertedAmountToDollars(amount: item.amount))"
        
        cell.accessoryType = item.checked ? .checkmark : .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = budget.budgetItems[indexPath.row]
        
        tableView.cellForRow(at: indexPath)?.accessoryType = item.checked ? .none : .checkmark
        
        item.checked = !item.checked
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        saveData()
        
    }
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSpecificBudgetItems(startID: timeFrameStartID)
        
        displayedDataTable.register(UINib(nibName: "BudgetItemTableViewCell", bundle: nil), forCellReuseIdentifier: "BudgetItemCell")
        
        displayedDataTable.rowHeight = 60
        
    }
    
    
    
    
   
    
    
    
}














