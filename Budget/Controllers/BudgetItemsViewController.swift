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
    
    var selectedBudgetItem: BudgetItem?
    
    var selectedBudgetTimeFrameStartID = Int()
    
    var selectedBudgetTimeFrameEndID = Int()
    
    var runningTotalFromThisPeriodAlone = Double()
    
    var currentDateAsPeriodID = Int()
    
    
    
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
            
        } else if segue.identifier == budgetItemsToTransactionsSegueKey {
            
            let destinationVC = segue.destination as! TransactionViewController
            
            var transactionsToDisplay: [Transaction]
            
            // If Budget Item selected.
            if let selectedItem = selectedBudgetItem {
                
                transactionsToDisplay = loadTransactionsByBudgetItem(start: selectedBudgetTimeFrameStartID, end: selectedBudgetTimeFrameEndID, itemName: selectedItem.name!)
                
                destinationVC.budgetItemNameForTransaction = selectedItem.name!
                
                destinationVC.budgetItemTypeForTransaction = selectedItem.type!
                
                destinationVC.transactionsToDisplay = transactionsToDisplay
                
            // If the main Period amount is selected, then all transactions show.
            } else {
            
                transactionsToDisplay = loadTransactionsByPeriod(selectedStartDate: selectedBudgetTimeFrameStartID, selectedEndDate: selectedBudgetTimeFrameEndID)
                
                destinationVC.transactionsToDisplay = transactionsToDisplay
                
            }
            
//            print(transactionsToDisplay)
//            print(selectedBudgetTimeFrameStartID)
//            print(selectedBudgetTimeFrameEndID)

            destinationVC.selectedBudgetTimeFrameStartID = selectedBudgetTimeFrameStartID
            
            destinationVC.selectedBudgetTimeFrameEndID = selectedBudgetTimeFrameEndID
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Tap Functions
    // *****
    
    @objc func balanceTapped() {
        
        selectedBudgetItem = nil
        
        performSegue(withIdentifier: budgetItemsToTransactionsSegueKey, sender: self)
        
    }
    
    
    
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
        
        let balanceTap = UITapGestureRecognizer(target: self, action: #selector(balanceTapped))
        
        self.mainBalanceLabel.isUserInteractionEnabled = true
        self.mainBalanceLabel.addGestureRecognizer(balanceTap)
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        
        self.loadNecessaryInfo()
        
        self.currentDateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: Date(), isEnd: false)
        
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
            
            if item.name != unallocatedKey {
                
                cell.accessoryType = .detailButton
                
            }

        } else {
            
            if selectedBudgetTimeFrameStartID < currentDateAsPeriodID {
                
                cell.accessoryType = .disclosureIndicator
                
            } else {
                
                cell.accessoryType = .none
                
            }
            
        }
        
        cell.nameLabel?.text = "\(item.name!)"
        
        cell.dueDayLabel?.text = (item.day > 0) ? "Due: \(convertDayToOrdinal(day: Int(item.day)))" : ""
        
        cell.fromCategoryLabel?.text = (item.type == withdrawalKey) ? "From: \(item.category!)" : ""
        
        // If the Budget Items are in Past or Present Periods, then Available and Budgeted Shown.
        if selectedBudgetTimeFrameStartID < currentDateAsPeriodID {
            
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
            
        // If the Budget Items are in Future Periods, then only Budgeted Shown.
        // Available is still updated when something changes, but it will be in the background.
        } else {
            
            if item.type == categoryKey || item.type == withdrawalKey {
                
                if item.name == unallocatedKey {
                    
                    cell.amountAvailableLabel?.text = "Bal: ---"
                    cell.amountBudgetedLabel?.text = "\(convertedAmountToDollars(amount: item.budgeted))"
                    
                } else {
                    
                    cell.amountAvailableLabel?.text = "Bal: ---"
                    cell.amountBudgetedLabel?.text = "Bgt: \(convertedAmountToDollars(amount: item.budgeted))"
                    
                }
                
            } else if item.type == paycheckKey || item.type == depositKey {
                
                cell.amountAvailableLabel?.text = "Bal: ---"
                cell.amountBudgetedLabel?.text = "+ \(convertedAmountToDollars(amount: item.budgeted))"
                
            }
            
        }

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = budgetItems[indexPath.row]
        
        if editBudgetItem == true {
            
            if item.name != unallocatedKey {
                
                isNewBudgetItem = false
                
                editableBudgetItem = item
                
                performSegue(withIdentifier: budgetItemsToAddOrEditBudgetItemSegueKey, sender: self)
                
            }
            
        } else {
            
            if selectedBudgetTimeFrameStartID < currentDateAsPeriodID {
                
                selectedBudgetItem = budgetItems[indexPath.row]
                
                performSegue(withIdentifier: budgetItemsToTransactionsSegueKey, sender: self)
                
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
                    
                    deleteBudgetItem(item: itemToDelete)
                    
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














