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
    
    var editTimeFrame = false
    
    var startDateFormatYYYYMMDD = Int()
    
    var endDateFormatYYYYMMDD = Int()
    
    
    
    // *****
    // MARK: - Header for Main Views
    // *****
    
    // *** IBOutlets
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    @IBOutlet weak var mainBalanceLabel: UILabel!
    
    
    
    // *** IBActions
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        editTimeFrame = !editTimeFrame
        
        editBarButton.title = editTimeFrame ? "Done" : "Edit"
        
        displayedDataTable.reloadData()
        
    }
    
    @IBAction func addSomething(_ sender: UIButton) {
        performSegue(withIdentifier: budgetToAddOrEditBudgetSegueKey, sender: self)
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    func loadNecessaryInfo(itemsToLoad: () -> Void) {
        
        itemsToLoad()
        
        displayedDataTable.separatorStyle = .none
        displayedDataTable.reloadData()
        refreshAvailableBalanceLabel(label: mainBalanceLabel)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadNecessaryInfo(itemsToLoad: loadSavedBudgetedTimeFrames)
        
        self.displayedDataTable.rowHeight = 90
        
        self.displayedDataTable.register(UINib(nibName: "BudgetTableViewCell", bundle: nil), forCellReuseIdentifier: "BudgetCell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.loadNecessaryInfo(itemsToLoad: loadSavedBudgetedTimeFrames)
        
    }
    
    
    
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
        
        let cell = displayedDataTable.dequeueReusableCell(withIdentifier: "BudgetCell", for: indexPath) as! BudgetTableViewCell
        
        addBorderAroundBudgetTableCellViews(cellView: cell.budgetedTimeFrameView)
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
            
        cell.accessoryType = editTimeFrame ? .detailButton : .disclosureIndicator
        
        if budget.budgetedTimeFrames.count > 0 {
            
            let period = budget.budgetedTimeFrames[indexPath.row]
            
            if indexPath.row == 0 {
                
                cell.startLabel?.text = "Very early -"
                cell.endLabel?.text = "\(period.endMonth)/\(period.endDay)/\((period.endYear % 100))"
                cell.amountLabel?.text = "\(convertedAmountToDollars(amount: budget.balance))"
                
            } else {
                
                cell.startLabel?.text = "\(period.startMonth)/\(period.startDay)/\((period.startYear % 100)) -"
                cell.endLabel?.text = "\(period.endMonth)/\(period.endDay)/\((period.endYear % 100))"
                cell.amountLabel?.text = "\(convertedAmountToDollars(amount: budget.balance))"
                
            }
            
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if indexPath.row == 0 {
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            performSegue(withIdentifier: budgetToCategoriesSegueKey, sender: self)
            
        } else {
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            timeFrameStartID = Int(budget.budgetedTimeFrames[indexPath.row].startDateID)
            
            performSegue(withIdentifier: budgetToBudgetItemsSegueKey, sender: self)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if indexPath.row != 0 {
            
            if editingStyle == .delete {
                
                let timeFrameToDelete = budget.budgetedTimeFrames[indexPath.row]
                
                let message = "Delete the whole budgeted time frame:\n\(timeFrameToDelete.startMonth)/\(timeFrameToDelete.startDay)/\(timeFrameToDelete.startYear) - \(timeFrameToDelete.endMonth)/\(timeFrameToDelete.endDay)/\(timeFrameToDelete.endYear)?"
                
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                    
                    // *** Additional check before deleting a Category, as this is a big deal.
                    let additionalAlert = UIAlertController(title: nil, message: "Deleting this budgeted time frame will remove all of the work you've done to budget for this time period. Do it anyway?", preferredStyle: .alert)
                    
                    additionalAlert.addAction(UIAlertAction(title: "Yes, do it anyway", style: .destructive, handler: { (action) in
                        
                        budget.deleteTimeFrame(period: timeFrameToDelete)
                        
                        self.successHaptic()
                        
                        loadSavedBudgetedTimeFrames()
                        self.displayedDataTable.reloadData()
                        
                    }))
                    
                    additionalAlert.addAction(UIAlertAction(title: "No, don't do it.", style: .cancel, handler: nil))
                    
                    self.present(additionalAlert, animated: true, completion: nil)
                    
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                
                present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    

    
    // *****
    // MARK: - Functions
    // *****
    
    
    
    
    
    
    
    
    
  
    
    
    
    

    

}















