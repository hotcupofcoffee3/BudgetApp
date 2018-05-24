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
    
    var runningBudgetTimeFrameTotal = Double()
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    @IBOutlet weak var mainBalanceLabel: UILabel!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
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
        
        runningBudgetTimeFrameTotal = period.balance
        
        
        
        
        
        
        
        navBar.topItem?.title = "\(period.startMonth)/\(period.startDay)/\(period.startYear)"
        
        displayedDataTable.reloadData()
        
        mainBalanceLabel.text = convertedAmountToDollars(amount: runningBudgetTimeFrameTotal)
        
        
    }
    
    func updateRunningTotalPerCheckage(forItem itemChecked: BudgetItem) {
        
        // Either positive or negative to be added to the running total, depending on how the item.
        var amountToChangeBy = Double()
        
        // If it was checked, but isn't anymore
        if !itemChecked.checked {
            
            // Amount taken away if a paycheck, added back if it was a withdrawal
            amountToChangeBy = (itemChecked.type == paycheckKey) ? -itemChecked.budgeted : itemChecked.budgeted
            
            // If it wasn't checked, but now it is.
        } else {
            
            // Amount added if a paycheck, taken away if it was a withdrawal
            amountToChangeBy = (itemChecked.type == paycheckKey) ? itemChecked.budgeted : -itemChecked.budgeted
            
        }
        
        
        
        
        
        guard let period = loadSpecificBudgetedTimeFrame(startID: selectedBudgetTimeFrameStartID) else { return }
        
        print("Bal: \(convertedAmountToDollars(amount: period.balance))")
        print("Unallocated: \(convertedAmountToDollars(amount: period.unallocated))")
        
        
        
        
        
        runningBudgetTimeFrameTotal += amountToChangeBy
        
        mainBalanceLabel.text = convertedAmountToDollars(amount: runningBudgetTimeFrameTotal)
        
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
        
        if item.type == categoryKey {
            
            cell.amountAvailableLabel?.text = "Bal: \(convertedAmountToDollars(amount: item.available))"
            cell.amountBudgetedLabel?.text = "Bgt: \(convertedAmountToDollars(amount: item.budgeted))"
            
        } else if item.type == paycheckKey || item.type == depositKey {
            
            cell.amountAvailableLabel?.text = "Bal: \(convertedAmountToDollars(amount: item.budgeted))"
            cell.amountBudgetedLabel?.text = ""
            
        } else if item.type == withdrawalKey {
            
            cell.amountAvailableLabel?.text = ""
            cell.amountBudgetedLabel?.text = "Bgt: \(convertedAmountToDollars(amount: item.budgeted))"
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = budgetItems[indexPath.row]
        
        if editBudgetItem == true {
            
            isNewBudgetItem = false
            
            editableBudgetItem = item
            
            performSegue(withIdentifier: budgetItemsToAddOrEditBudgetItemSegueKey, sender: self)
            
        } else {
            
            tableView.cellForRow(at: indexPath)?.accessoryType = item.checked ? .none : .checkmark
            
            item.checked = !item.checked
            
            updateRunningTotalPerCheckage(forItem: item)
            
            tableView.deselectRow(at: indexPath, animated: false)
            
            saveData()
            
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














