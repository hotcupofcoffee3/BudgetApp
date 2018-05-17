//
//  BudgetViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/7/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class BudgetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - Declared
    // *****
    
    var editBudgetTimeFrame = false
    
    var isNewBudgetTimeFrame = true
    
    var editableBudgetTimeFrame: Period?
    
    var startDateFormatYYYYMMDD = Int()
    
    var endDateFormatYYYYMMDD = Int()
    
    var selectedBudgetTimeFrameStartID = Int()
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    @IBOutlet weak var mainBalanceLabel: UILabel!
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - General Functions
    // *****
    
    func loadNecessaryInfo(itemsToLoad: () -> Void) {
        
        itemsToLoad()
        
        displayedDataTable.separatorStyle = .none
        displayedDataTable.reloadData()
        refreshAvailableBalanceLabel(label: mainBalanceLabel)
        
    }
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        editBudgetTimeFrame = !editBudgetTimeFrame
        
        editBarButton.title = editBudgetTimeFrame ? "Done" : "Edit"
        
        displayedDataTable.reloadData()
        
    }
    
    @IBAction func addSomething(_ sender: UIButton) {
        isNewBudgetTimeFrame = true
        performSegue(withIdentifier: budgetToAddOrEditBudgetSegueKey, sender: self)
    }
    
    
    
    // *****
    // MARK: - Submissions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Delegates
    // *****
    
    
    
    
    
    // *****
    // MARK: - Segues
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == budgetToBudgetItemsSegueKey {
            
            let destinationVC = segue.destination as! BudgetItemsViewController
            
            destinationVC.selectedBudgetTimeFrameStartID = selectedBudgetTimeFrameStartID
            
        } else if segue.identifier == budgetToAddOrEditBudgetSegueKey {
            
            let destinationVC = segue.destination as! AddOrEditBudgetedTimeFrameViewController
            
            destinationVC.isNewBudgetTimeFrame = isNewBudgetTimeFrame
            
            if !isNewBudgetTimeFrame {
                
                guard let editableTimeFrame = editableBudgetTimeFrame else { return }
                
                destinationVC.editableBudgetTimeFrame = editableTimeFrame
                
            }
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Tap Functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadNecessaryInfo(itemsToLoad: loadSavedBudgetedTimeFrames)
        
        self.displayedDataTable.rowHeight = 90
        
        self.displayedDataTable.register(UINib(nibName: "BudgetTableViewCell", bundle: nil), forCellReuseIdentifier: "BudgetCell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.loadNecessaryInfo(itemsToLoad: loadSavedBudgetedTimeFrames)
        
    }
    
    

    
    
    

    

}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension BudgetViewController {
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return budget.budgetedTimeFrames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = displayedDataTable.dequeueReusableCell(withIdentifier: "BudgetCell", for: indexPath) as! BudgetTableViewCell
        
        addBorderAroundBudgetTableCellViews(cellView: cell.budgetedTimeFrameView)
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        
        cell.accessoryType = editBudgetTimeFrame ? .detailButton : .disclosureIndicator
        
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
            
            let selectedTimeFrame = budget.budgetedTimeFrames[indexPath.row]
            
            editableBudgetTimeFrame = selectedTimeFrame
            
            selectedBudgetTimeFrameStartID = Int(budget.budgetedTimeFrames[indexPath.row].startDateID)
            
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
    
    
    
    
    
}















