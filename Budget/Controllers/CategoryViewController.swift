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
 
    @IBOutlet weak var availableBalanceLabel: UILabel!
    
    @IBAction func addCategoryButton(_ sender: UIButton) {
        performSegue(withIdentifier: categoriesToAddCategorySegueKey, sender: self)
    }
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return budget.sortedCategoryKeys.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = displayedDataTable.dequeueReusableCell(withIdentifier: "CategoryCustomCell", for: indexPath) as! CategoryTableViewCell
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        
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
            
            cell.categoryNameLabel?.text = "\(category.name!)"
            
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
    
    @IBAction func addSomething(_ sender: UIBarButtonItem) {
        
        addSomethingAlertPopup()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayedDataTable.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCustomCell")
        
        displayedDataTable.rowHeight = 90
        
        refreshAvailableBalanceLabel(label: availableBalanceLabel)
        budget.sortCategoriesByKey(withUnallocated: true)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
        
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
        refreshAvailableBalanceLabel(label: availableBalanceLabel)
        budget.sortCategoriesByKey(withUnallocated: true)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
