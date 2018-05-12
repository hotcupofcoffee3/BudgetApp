//
//  CategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

var editableCategoryName = String()

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var editCategory = false
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var categoryNavBar: UINavigationBar!
    
    @IBOutlet weak var availableBalanceLabel: UILabel!
    
    @IBOutlet weak var editCategoryBarButton: UIBarButtonItem!
    
    @IBOutlet weak var viewAllTransactionsButton: UIButton!
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func editCategory(_ sender: UIBarButtonItem) {
        
        editCategory = !editCategory
        
        if editCategory == true {
            
            editCategoryBarButton.title = "Done"
            displayedDataTable.reloadData()
            
        } else {
            
            editCategoryBarButton.title = "Edit"
            displayedDataTable.reloadData()
            
        }
        
    }
    
    @IBAction func addSomethingButton(_ sender: UIButton) {
        addSomethingAlertPopup(addCategorySegue: categoriesToAddCategorySegueKey, addTransactionSegue: categoriesToAddTransactionSegueKey, moveFundsSegue: categoriesToMoveFundsSegueKey)
    }
    
    @IBAction func viewAllTransactions(_ sender: UIButton) {
        
        selectedCategory = nil
        selectedStartDate = nil
        selectedEndDate = nil
        
        performSegue(withIdentifier: categoriesToTransactionsSegueKey, sender: self)
        
    }
    
    
    
    // *****
    // MARK: - TableView
    // *****
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return budget.sortedCategoryKeys.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = displayedDataTable.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        
        cell.categoryNameLabel?.textColor = UIColor.white
        cell.categoryBudgetedTitleLabel?.textColor = UIColor.white
        cell.categoryBudgetedLabel?.textColor = UIColor.white
        cell.categoryAvailableTitleLabel?.textColor = UIColor.white
        cell.categoryAvailableLabel?.textColor = UIColor.white
        cell.dueDateLabel?.textColor = UIColor.white
        
        
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
            
            // Sets back to edit after editing is done.
            editCategoryBarButton.title = "Edit"
            
            if budget.sortedCategoryKeys[indexPath.row] != unallocatedKey {
                
                editableCategoryName = budget.sortedCategoryKeys[indexPath.row]
                performSegue(withIdentifier: editCategorySegueKey, sender: self)
                
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
                        
                        self.refreshAvailableBalanceLabel(label: self.availableBalanceLabel)
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
    

    
    // *****
    // MARK: - Functions
    // *****
    
    // ***** Swipe
//    @objc func swipe() {
//
//        performSegue(withIdentifier: categoriesToTransactionsSegueKey, sender: self)
//
//    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayedDataTable.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        
        displayedDataTable.rowHeight = 90
        
        addCircleAroundButton(named: viewAllTransactionsButton)
        
        refreshAvailableBalanceLabel(label: availableBalanceLabel)
        budget.sortCategoriesByKey(withUnallocated: true)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
        editCategory = false
        selectedCategory = nil
        
        // ******** Swipe
//
//        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe))
//        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
//        self.view.addGestureRecognizer(leftSwipe)
//        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshAvailableBalanceLabel(label: availableBalanceLabel)
        budget.sortCategoriesByKey(withUnallocated: true)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
        editCategory = false
        selectedCategory = nil
        selectedStartDate = nil
        selectedEndDate = nil
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    
    
    
    
    
    
    
   
    
   
    
}










