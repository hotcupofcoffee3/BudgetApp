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
    
    func refreshAvailableBalanceLabel() {
<<<<<<< HEAD
        if let availableBalance = budget.categories[uncategorizedKey] {
            availableBalanceLabel.text = "$\(String(format: "%0.2f", availableBalance.available))"
        }
=======
        budget.updateBalance()
        availableBalanceLabel.text = "\(convertedAmountToDollars(amount: budget.balance))"
>>>>>>> switchToCoreData
    }

    // "Uncategorized" category is excluded from the table presentation of the categories.
    // The amount left over is the same as the "Uncategorized" category.
    // It is, therefore, placed on the top as "Left".
    
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
        
        let cell = displayedDataTable.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 1)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        
<<<<<<< HEAD
        if let category = budget.categories[budget.sortedCategoryKeys[indexPath.row]] {
            cell.textLabel?.text = "\(category.name): $\(String(format: doubleFormatKey, category.available))"
            cell.detailTextLabel?.text = "Budgeted: $\(String(format: doubleFormatKey, category.budgeted))"
=======
        if let category = loadSpecificCategory(named: budget.sortedCategoryKeys[indexPath.row]) {
            
            // Unallocated has no disclosure indicator because you cannot edit it.
            if category.name == unallocatedKey {
                
                cell.accessoryType = .none
                
            } else {
                
                cell.accessoryType = .disclosureIndicator
                
            }
            
            cell.textLabel?.text = "\(category.name!)"
            
            if category.name == unallocatedKey {
                
                cell.detailTextLabel?.text = "Left: \(convertedAmountToDollars(amount: category.available))"
                
            } else {
                
                cell.detailTextLabel?.text = "Budgeted: \(convertedAmountToDollars(amount: category.budgeted)) - Left: \(convertedAmountToDollars(amount: category.available))"
                
            }
            
>>>>>>> switchToCoreData
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
                
<<<<<<< HEAD
                self.refreshAvailableBalanceLabel()
                budget.sortCategoriesByKey(withUncategorized: false)
                self.displayedDataTable.reloadData()
=======
                let message = "Delete \(categoryToDelete)?"
>>>>>>> switchToCoreData
                
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                    
                    budget.deleteCategory(named: categoryToDelete)
                    
                    self.refreshAvailableBalanceLabel()
                    budget.sortCategoriesByKey(withUnallocated: true)
                    self.displayedDataTable.reloadData()
                    
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
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshAvailableBalanceLabel()
<<<<<<< HEAD
        budget.sortCategoriesByKey(withUncategorized: false)
        displayedDataTable.reloadData()
=======
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
        
>>>>>>> switchToCoreData
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshAvailableBalanceLabel()
<<<<<<< HEAD
        budget.sortCategoriesByKey(withUncategorized: false)
=======
        budget.sortCategoriesByKey(withUnallocated: true)
>>>>>>> switchToCoreData
        displayedDataTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
