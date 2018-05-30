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
    
    var sortedBudgetedTimeFrames = [Period]()
    
    var startDateFormatYYYYMMDD = Int()
    
    var endDateFormatYYYYMMDD = Int()
    
    var selectedBudgetTimeFrameStartID = Int()
    
    var previousBudgetTimeFrameRunningTotal = Double()
    
    var selectedBudgetTimeFrameRunningTotal = Double()
    
    
    
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
    
    func loadNecessaryInfo() {
        
        sortedBudgetedTimeFrames = loadAndSortBudgetedTimeFrames()
        
        updateAllPeriodsBalances()
        
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
            
            destinationVC.runningBudgetTimeFrameTotal = selectedBudgetTimeFrameRunningTotal
            
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
        
        self.loadNecessaryInfo()
        
        self.displayedDataTable.rowHeight = 78.5
        
        self.displayedDataTable.register(UINib(nibName: "BudgetTableViewCell", bundle: nil), forCellReuseIdentifier: "BudgetCell")
        
        for period in sortedBudgetedTimeFrames {
            
            print(period.startDateID)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.loadNecessaryInfo()
        
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
        return sortedBudgetedTimeFrames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = displayedDataTable.dequeueReusableCell(withIdentifier: "BudgetCell", for: indexPath) as! BudgetTableViewCell
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        
        cell.accessoryType = editBudgetTimeFrame ? .detailButton : .disclosureIndicator
        
        if sortedBudgetedTimeFrames.count > 0 {
            
            let period = sortedBudgetedTimeFrames[indexPath.row]
            
            cell.timeFrameLabel?.text = "\(period.startMonth)/\(period.startDay)/\((period.startYear % 100)) - \(period.endMonth)/\(period.endDay)/\((period.endYear % 100))"
            
            let currentDateAsPeriodID = convertDateToDateAddedForGeneralPurposes(dateAdded: Date())
            
            if period.endDateID < currentDateAsPeriodID {
                
                cell.timeFrameLabel?.textColor = fadedWhiteColor
                cell.amountLabel?.textColor = fadedLightGreenColor
                
            } else if period.startDateID < currentDateAsPeriodID && period.endDateID > currentDateAsPeriodID {
                
                cell.timeFrameLabel?.textColor = UIColor.white
                cell.amountLabel?.textColor = lightGreenColor
                
            } else if period.startDateID > currentDateAsPeriodID {
                
                cell.timeFrameLabel?.textColor = tealColor
                cell.amountLabel?.textColor = fadedLightGreenColor
                
            }
            
            cell.amountLabel?.text = "\(convertedAmountToDollars(amount: period.balance))"

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedTimeFrame = sortedBudgetedTimeFrames[indexPath.row]
        
        editableBudgetTimeFrame = selectedTimeFrame
        
        selectedBudgetTimeFrameStartID = Int(sortedBudgetedTimeFrames[indexPath.row].startDateID)
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! BudgetTableViewCell
        
        guard let selectedAmount = convertedDollarsToAmount(dollars: selectedCell.amountLabel.text!) else { return }
        
        selectedBudgetTimeFrameRunningTotal = selectedAmount
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: budgetToBudgetItemsSegueKey, sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            
            let timeFrameToDelete = sortedBudgetedTimeFrames[indexPath.row]
            
            let message = "Delete the whole budgeted time frame:\n\(timeFrameToDelete.startMonth)/\(timeFrameToDelete.startDay)/\(timeFrameToDelete.startYear) - \(timeFrameToDelete.endMonth)/\(timeFrameToDelete.endDay)/\(timeFrameToDelete.endYear)?"
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                
                // *** Additional check before deleting a Category, as this is a big deal.
                let additionalAlert = UIAlertController(title: nil, message: "Deleting this budgeted time frame will remove all of the work you've done to budget for this time period. Do it anyway?", preferredStyle: .alert)
                
                additionalAlert.addAction(UIAlertAction(title: "Yes, do it anyway", style: .destructive, handler: { (action) in
                    
                    budget.deleteTimeFrame(period: timeFrameToDelete)
                    
                    self.successHaptic()
                    
                    self.sortedBudgetedTimeFrames = loadAndSortBudgetedTimeFrames()
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















