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
    
    @IBOutlet weak var categoryNavBar: UINavigationBar!
    
    func refreshAvailableBalanceLabel() {
        budget.updateBalance()
        availableBalanceLabel.text = "\(convertedAmountToDollars(amount: budget.balance))"
    }
    
    @IBOutlet weak var availableBalanceLabel: UILabel!
    
    @IBAction func addCategoryButton(_ sender: UIButton) {
        performSegue(withIdentifier: categoriesToAddCategorySegueKey, sender: self)
    }
    
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // "Uncategorized" category excluded.
        return budget.sortedCategoryKeys.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = displayedDataTable.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let cell = displayedDataTable.dequeueReusableCell(withIdentifier: "CategoryCustomCell", for: indexPath) as! CategoryTableViewCell
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        
//        cell.textLabel?.textColor = UIColor.white
//        cell.detailTextLabel?.textColor = UIColor.white
        cell.categoryNameLabel?.textColor = UIColor.white
        cell.categoryBudgetedTitleLabel?.textColor = UIColor.white
        cell.categoryBudgetedLabel?.textColor = UIColor.white
        cell.categoryAvailableTitleLabel?.textColor = UIColor.white
        cell.categoryAvailableLabel?.textColor = UIColor.white
        
        
        if let category = loadSpecificCategory(named: budget.sortedCategoryKeys[indexPath.row]) {
            
            // Unallocated has no disclosure indicator because you cannot edit it.
            if category.name == unallocatedKey {
                
                cell.accessoryType = .none
                
            } else {
                
                cell.accessoryType = .disclosureIndicator
                
            }
            
//            cell.textLabel?.text = "\(category.name!)"
            cell.categoryNameLabel?.text = "\(category.name!)"
            
            if category.name == unallocatedKey {
                
//                cell.detailTextLabel?.text = "Left: \(convertedAmountToDollars(amount: category.available))"
                cell.categoryBudgetedLabel?.text = "N/A"
                cell.categoryAvailableLabel?.text = "\(convertedAmountToDollars(amount: category.available))"
                
            } else {
                
//                cell.detailTextLabel?.text = "Budgeted: \(convertedAmountToDollars(amount: category.budgeted)) - Left: \(convertedAmountToDollars(amount: category.available))"
                cell.categoryBudgetedLabel?.text = "\(convertedAmountToDollars(amount: category.budgeted))"
                cell.categoryAvailableLabel?.text = "\(convertedAmountToDollars(amount: category.available))"
                
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if budget.sortedCategoryKeys[indexPath.row] != unallocatedKey {
            
            editableCategoryName = budget.sortedCategoryKeys[indexPath.row]
            performSegue(withIdentifier: editCategorySegueKey, sender: self)
            
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
                        
                        // Success notification haptic
                        let successHaptic = UINotificationFeedbackGenerator()
                        successHaptic.notificationOccurred(.success)
                        
                        self.refreshAvailableBalanceLabel()
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
    
    @IBAction func addSomething(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Add Category", style: .default) { (action) in
           
            self.performSegue(withIdentifier: categoriesToAddCategorySegueKey, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Add Transaction", style: .default) { (action) in
            
            self.performSegue(withIdentifier: categoriesToAddTransactionSegueKey, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Move Funds", style: .default) { (action) in
            
            self.performSegue(withIdentifier: categoriesToMoveFundsSegueKey, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayedDataTable.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCustomCell")
        
        displayedDataTable.rowHeight = 120
        
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshAvailableBalanceLabel()
        budget.sortCategoriesByKey(withUnallocated: true)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
        
        
        // No image used, to make the navbar background transparent
//        categoryNavBar.setBackgroundImage(UIImage(), for: .default)
//        categoryNavBar.shadowImage = UIImage()
        
        
        // ******** Swipe
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(leftSwipe)
        
        
    }
    
    // ***** Swipe
    @objc func swipe() {
        
        performSegue(withIdentifier: categoriesToTransactionsSegueKey, sender: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshAvailableBalanceLabel()
        budget.sortCategoriesByKey(withUnallocated: true)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
