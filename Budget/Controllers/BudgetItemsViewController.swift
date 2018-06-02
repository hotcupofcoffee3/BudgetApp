//
//  BudgetItemsViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class BudgetItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - Declared
    // *****
    
    var budgetItems = [BudgetItem]()
    
    var editBudgetItem = false
    
    var isNewBudgetItem = true
    
    var editableBudgetItem: BudgetItem?
    
    var selectedBudgetTimeFrameStartID = Int()
    
    var runningTotalFromThisPeriodAlone = Double()
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    @IBOutlet weak var mainBalanceLabel: UILabel!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var leftThisPeriodLabel: UILabel!
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - General Functions
    // *****
    
    func loadNecessaryInfo() {
        
        self.budgetItems = loadSpecificBudgetItems(startID: selectedBudgetTimeFrameStartID)
//        refreshAvailableBalanceLabel(label: mainBalanceLabel)
        
        displayedDataTable.rowHeight = 90
        displayedDataTable.separatorStyle = .none
        
        
        
        
        
        guard let period = loadSpecificBudgetedTimeFrame(startID: selectedBudgetTimeFrameStartID) else { return }
        let currentDateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: Date(), isEnd: false)
        
        runningTotalFromThisPeriodAlone = calculatePaycheckMinusCategoryAmounts(startID: Int(period.startDateID))
        
        if period.startDateID > currentDateAsPeriodID {
            
            leftThisPeriodLabel.text = "{ This Period: \(convertedAmountToDollars(amount: runningTotalFromThisPeriodAlone))}"
            
        } else {
            
            leftThisPeriodLabel.text = ""
            
        }
        
        navBar.topItem?.title = "\(period.startMonth)/\(period.startDay)/\(period.startYear)"
        
        displayedDataTable.reloadData()
        
        mainBalanceLabel.text = convertedAmountToDollars(amount: period.balance)
        
    }
    
    func updateBalancePerCheckage(forItem itemChecked: BudgetItem) {
        
        let startID = Int(itemChecked.periodStartID)

        let name = itemChecked.name!

        let type = itemChecked.type!

        updateItemAndBalancePerCheckage(startID: startID, named: name, type: type)

//        guard let currentPeriod = loadSpecificBudgetedTimeFrame(startID: startID) else { return }
//
//        mainBalanceLabel.text = convertedAmountToDollars(amount: currentPeriod.balance)
//
//        leftThisPeriodLabel.text = convertedAmountToDollars(amount: calculatePeriodBalanceInIsolation(startID: startID))
        
    }
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        editBudgetItem = !editBudgetItem
        
        editBarButton.title = editBudgetItem ? "Done" : "Edit"
        
        displayedDataTable.reloadData()
        
    }
    
    @IBAction func addSomething(_ sender: UIButton) {
        isNewBudgetItem = true
        performSegue(withIdentifier: budgetItemsToAddOrEditBudgetItemSegueKey, sender: self)
        
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
        
        if segue.identifier == budgetItemsToAddOrEditBudgetItemSegueKey {
            
            let destinationVC = segue.destination as! AddOrEditBudgetItemViewController
            
            destinationVC.isNewBudgetItem = isNewBudgetItem
            
            destinationVC.selectedBudgetTimeFrameStartID = selectedBudgetTimeFrameStartID
            
            if !isNewBudgetItem {
                
                guard let editableItem = editableBudgetItem else { return }
                
                destinationVC.editableBudgetItem = editableItem
                
                destinationVC.selectedBudgetTimeFrameStartID = Int(editableItem.periodStartID)
                
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
    // ****
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.displayedDataTable.register(UINib(nibName: "BudgetItemTableViewCell", bundle: nil), forCellReuseIdentifier: "BudgetItemCell")
        
        self.loadNecessaryInfo()
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        
        self.loadNecessaryInfo()
        
    }
    
   
   
    
    
   
    
    
    
}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension BudgetItemsViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return budgetItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = budgetItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetItemCell", for: indexPath) as! BudgetItemTableViewCell
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        
        if editBudgetItem == true {
            
            cell.accessoryType = .detailButton
            
        } else {
            
            if item.addedToLedger {
                
                cell.accessoryType = .checkmark
                
            } else {
                
                cell.accessoryType = item.checked ? .checkmark : .none
                
            }
            
        }
        
        cell.addedToLedgerImage.image = item.addedToLedger ? UIImage(named: "postit.png") : nil
        
        cell.nameLabel?.text = "\(item.name!)"
        
        cell.dueDayLabel?.text = (item.day > 0) ? "Due: \(convertDayToOrdinal(day: Int(item.day)))" : ""
        
        cell.fromCategoryLabel?.text = (item.type == withdrawalKey) ? "From: \(item.category!)" : ""
        
        
        
      
        
        
//        let currentDateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: Date(), isEnd: true)
//
//
//
//        // Future
//
//        if selectedBudgetTimeFrameStartID > currentDateAsPeriodID {
//
//            cell.amountAvailableLabel?.text = ""
//
//            if item.type == categoryKey || item.type == withdrawalKey {
//
//                cell.amountBudgetedLabel?.text = "\(convertedAmountToDollars(amount: item.budgeted))"
//
//            } else if item.type == paycheckKey || item.type == depositKey {
//
//                cell.amountBudgetedLabel?.text = "+ \(convertedAmountToDollars(amount: item.budgeted))"
//
//            }
//
//
//
//        // Past and Present
//
//        } else {

            if item.type == categoryKey || item.type == withdrawalKey {
                
                if item.name == unallocatedKey {
                    
                    cell.amountAvailableLabel?.text = "\(convertedAmountToDollars(amount: item.available))"
                    cell.amountBudgetedLabel?.text = "\(convertedAmountToDollars(amount: item.budgeted))"
                    
                } else {
                    
                    cell.amountAvailableLabel?.text = "Bal: \(convertedAmountToDollars(amount: item.available))"
                    cell.amountBudgetedLabel?.text = "Bgt: \(convertedAmountToDollars(amount: item.budgeted))"
                    
                }
                
            } else if item.type == paycheckKey || item.type == depositKey {
                
                cell.amountAvailableLabel?.text = "+ \(convertedAmountToDollars(amount: item.available))"
                cell.amountBudgetedLabel?.text = "+ \(convertedAmountToDollars(amount: item.budgeted))"
                
            }
        
//        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = budgetItems[indexPath.row]
        
        if editBudgetItem == true {
            
            isNewBudgetItem = false
            
            editableBudgetItem = item
            
            performSegue(withIdentifier: budgetItemsToAddOrEditBudgetItemSegueKey, sender: self)
            
        } else {
            
            if item.name != unallocatedKey {
                
                tableView.cellForRow(at: indexPath)?.accessoryType = item.checked ? .none : .checkmark
                
                item.checked = !item.checked
                
                updateBalancePerCheckage(forItem: item)
                
                tableView.deselectRow(at: indexPath, animated: false)
                
                saveData()
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if budgetItems[indexPath.row].type != categoryKey && budgetItems[indexPath.row].type != paycheckKey {
            
            if editingStyle == .delete {
                
                let itemToDelete = budgetItems[indexPath.row]
                
                let message = "Delete \"\(itemToDelete.name!)\"?"
                
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                    
                    budget.deleteBudgetItem(itemToDelete: itemToDelete)
                    
                    self.successHaptic()
                    
                    self.budgetItems = loadSpecificBudgetItems(startID: self.selectedBudgetTimeFrameStartID)
                    self.displayedDataTable.reloadData()
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                
                present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
}














