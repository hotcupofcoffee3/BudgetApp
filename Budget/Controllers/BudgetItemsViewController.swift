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
    // Mark: - Declared
    // *****
    
    var editBudgetItem = false
    
    var isNewBudgetItem = true
    
    var editableBudgetItem: BudgetItem?
    
    var selectedBudgetTimeFrameStartID = Int()
    
    var runningBudgetTimeFrameTotal = Double()
    
    
    
    // *****
    // Mark: - IBOutlets
    // *****
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    @IBOutlet weak var mainBalanceLabel: UILabel!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - General Functions
    // *****
    
    func loadNecessaryInfo() {
        
        loadSpecificBudgetItems(startID: selectedBudgetTimeFrameStartID)
//        refreshAvailableBalanceLabel(label: mainBalanceLabel)
        
        displayedDataTable.rowHeight = 60
        displayedDataTable.separatorStyle = .none
        
        guard let period = loadSpecificBudgetedTimeFrame(startID: selectedBudgetTimeFrameStartID) else { return }
        
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
            amountToChangeBy = (itemChecked.type == paycheckKey) ? -itemChecked.amount : itemChecked.amount
            
            // If it wasn't checked, but now it is.
        } else {
            
            // Amount added if a paycheck, taken away if it was a withdrawal
            amountToChangeBy = (itemChecked.type == paycheckKey) ? itemChecked.amount : -itemChecked.amount
            
        }
        
        runningBudgetTimeFrameTotal += amountToChangeBy
        
        mainBalanceLabel.text = convertedAmountToDollars(amount: runningBudgetTimeFrameTotal)
        
    }
    
    
    
    // *****
    // Mark: - IBActions
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
    // Mark: - Submissions
    // *****
    
    
    
    
    
    // *****
    // Mark: - Delegates
    // *****
    
    
    
    
    
    // *****
    // Mark: - Segues
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == budgetItemsToAddOrEditBudgetItemSegueKey {
            
            let destinationVC = segue.destination as! AddOrEditBudgetItemViewController
            
            destinationVC.isNewBudgetItem = isNewBudgetItem
            
            destinationVC.selectedBudgetTimeFrameStartID = selectedBudgetTimeFrameStartID
            
            if !isNewBudgetItem {
                
                guard let editableItem = editableBudgetItem else { return }
                
                destinationVC.editableBudgetItem = editableItem
                
                destinationVC.selectedBudgetTimeFrameStartID = Int(editableItem.timeSpanID)
                
            }
            
        }
        
    }
    
    
    
    // *****
    // Mark: - Tap Functions
    // *****
    
    
    
    
    
    // *****
    // Mark: - Keyboard functions
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
        
        return budget.budgetItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = budget.budgetItems[indexPath.row]
        
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
        
        cell.addedToLedgerImage.image = item.addedToLedger ? UIImage(named: "postit.png") : UIImage(named: "")
        
        cell.nameLabel?.text = "\(item.name!)"
        
        cell.dueDayLabel?.text = (item.day > 0) ? "Due: \(convertDayToOrdinal(day: Int(item.day)))" : ""
        
        cell.amountLabel?.text = (item.type == paycheckKey) ? "+ \(convertedAmountToDollars(amount: item.amount))" : "\(convertedAmountToDollars(amount: item.amount))"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = budget.budgetItems[indexPath.row]
        
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
        
        if budget.budgetItems[indexPath.row].type == oneTimeAddedKey {
            
            if editingStyle == .delete {
                
                let itemToDelete = budget.budgetItems[indexPath.row]
                
                let message = "Delete \"\(itemToDelete.name!)\"?"
                
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                    
                    budget.deleteBudgetItem(itemToDelete: itemToDelete)
                    
                    self.successHaptic()
                    
                    loadSpecificBudgetItems(startID: self.selectedBudgetTimeFrameStartID)
                    self.displayedDataTable.reloadData()
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                
                present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
}














