//
//  CategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - Declared
    // *****
    
    var editCategory = false
    
    var isNewCategory = true
    
    var editableCategoryName = String()
    
    
    
    // *****
    // Mark: - IBOutlets
    // *****
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var mainBalanceLabel: UILabel!
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    @IBOutlet weak var viewAllTransactionsButton: UIButton!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - General Functions
    // *****
    
    
    
    
    
    // *****
    // Mark: - IBActions
    // *****
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        editCategory = !editCategory
        
        editBarButton.title = editCategory ? "Done" : "Edit"
        
        displayedDataTable.reloadData()
        
    }
    
    @IBAction func addSomething(_ sender: UIButton) {
        addSomethingAlertPopup(addCategorySegue: categoriesToAddOrEditCategorySegueKey, addTransactionSegue: categoriesToAddOrEditTransactionSegueKey, moveFundsSegue: categoriesToMoveFundsSegueKey)
    }
    
    @IBAction func viewAllTransactions(_ sender: UIButton) {
        
        selectedCategory = nil
        
        performSegue(withIdentifier: categoriesToTransactionsSegueKey, sender: self)
        
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
        
        if segue.identifier == categoriesToAddOrEditTransactionSegueKey {
            
            let destinationVC = segue.destination as! AddOrEditTransactionViewController
            
            destinationVC.isNewTransaction = true
            
        } else if segue.identifier == categoriesToAddOrEditCategorySegueKey {
            
            let destinationVC = segue.destination as! AddOrEditCategoryViewController
            
            destinationVC.isNewCategory = isNewCategory
            
            if !isNewCategory {
                
                guard let editableCategory = loadSpecificCategory(named: editableCategoryName) else { return }
                
                destinationVC.editableCategory = editableCategory
                
                
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
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayedDataTable.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        
        displayedDataTable.rowHeight = 90
        
        addCircleAroundButton(named: viewAllTransactionsButton)
        
        refreshAvailableBalanceLabel(label: mainBalanceLabel)
        budget.sortCategoriesByKey(withUnallocated: true)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
        editCategory = false
        isNewCategory = true
        selectedCategory = nil
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshAvailableBalanceLabel(label: mainBalanceLabel)
        budget.sortCategoriesByKey(withUnallocated: true)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
        editCategory = false
        isNewCategory = true
        selectedCategory = nil
        
    }

    
    
}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension CategoryViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return budget.sortedCategoryKeys.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = displayedDataTable.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        
        if let category = loadSpecificCategory(named: budget.sortedCategoryKeys[indexPath.row]) {
            
            // Unallocated has no disclosure indicator because you cannot edit it.
            if category.name == unallocatedKey {
                
                cell.accessoryType = .none
                
            } else {
                
                if editCategory == true {
                    
                    cell.accessoryType = .detailButton
                    
                } else {
                    
                    cell.accessoryType = .disclosureIndicator
                    
                }
                
                
            }
            
            cell.categoryNameLabel?.text = "\(category.name!)"
            
            if Int(category.dueDay) >= 1 && Int(category.dueDay) <= 31 {
                
                cell.dueDateLabel.text = "Due: \(convertDayToOrdinal(day: Int(category.dueDay)))"
                
            } else {
                
                cell.dueDateLabel.text = ""
                
            }
            
            if category.name == unallocatedKey {
                
                cell.categoryBudgetedLabel?.text = "N/A"
                cell.categoryAvailableLabel?.text = "\(convertedAmountToDollars(amount: category.available))"
                
            } else {
                
                cell.categoryBudgetedLabel?.text = "\(convertedAmountToDollars(amount: category.budgeted))"
                cell.categoryAvailableLabel?.text = "\(convertedAmountToDollars(amount: category.available))"
                
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if editCategory == true {
            
            isNewCategory = false
            
            // Sets back to edit after editing is done.
            editBarButton.title = "Edit"
            
            if budget.sortedCategoryKeys[indexPath.row] != unallocatedKey {
                
                editableCategoryName = budget.sortedCategoryKeys[indexPath.row]
                performSegue(withIdentifier: categoriesToAddOrEditCategorySegueKey, sender: self)
                
            }
            
        } else {
            
            selectedCategory = budget.sortedCategoryKeys[indexPath.row]
            performSegue(withIdentifier: categoriesToTransactionsSegueKey, sender: self)
            
        }
        
        displayedDataTable.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if budget.sortedCategoryKeys[indexPath.row] != unallocatedKey {
                
                let categoryToDelete = budget.sortedCategoryKeys[indexPath.row]
                
                let message = "Delete \(categoryToDelete)?"
                
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                    
                    // *** Additional check before deleting a Category, as this is a big deal.
                    let additionalAlert = UIAlertController(title: nil, message: "Deleting \(categoryToDelete) will put all transactions into 'Unallocated', and you cannot undo this. Do it anyway?", preferredStyle: .alert)
                    
                    additionalAlert.addAction(UIAlertAction(title: "Yes, do it anyway", style: .destructive, handler: { (action) in
                        
                        budget.deleteCategory(named: categoryToDelete)
                        
                        self.successHaptic()
                        
                        self.refreshAvailableBalanceLabel(label: self.mainBalanceLabel)
                        budget.sortCategoriesByKey(withUnallocated: true)
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










