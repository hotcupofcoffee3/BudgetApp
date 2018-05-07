//
//  MainScreen.swift
//  Budget
//
//  Created by Adam Moore on 4/3/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit
import CoreData

class MainScreen: UIViewController {
  
    
    @IBOutlet weak var hiddenDeleteButton: UIButton!
    @IBOutlet weak var hiddenResetWithCategoriesAndTransactions: UIButton!
    
    @IBOutlet weak var availableBalanceLabel: UILabel!
    
    @IBOutlet weak var budgetButtonTitle: UIButton!
    
    @IBOutlet weak var categoriesButtonTitle: UIButton!
    
    @IBOutlet weak var transactionsButtonTitle: UIButton!

    @IBAction func budgetButton(_ sender: UIButton) {
        performSegue(withIdentifier: mainToBudgetSegueKey, sender: self)
    }
    
    @IBAction func categoriesButton(_ sender: UIButton) {
        performSegue(withIdentifier: mainToCategoriesSegueKey, sender: self)
    }
    
    @IBAction func transactionsButton(_ sender: UIButton) {
        performSegue(withIdentifier: mainToTransactionsSegueKey, sender: self)
    }
    
    @IBAction func addSomething(_ sender: UIButton) {
        
        addSomethingAlertPopup(addCategorySegue: mainToAddCategorySegueKey, addTransactionSegue: mainToAddTransactionSegueKey, moveFundsSegue: mainToMoveFundsSegueKey)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        // ********************
        // Core Data Testing (& Other Testing)
        // ********************
      
       
        
        
        
        // ********************
        // ********************
        // ********************
        
        loadSavedCategories()
        loadSavedTransactions(descending: true)
        selectedCategory = nil
        selectedStartDate = nil
        selectedEndDate = nil
        
        refreshAvailableBalanceLabel(label: availableBalanceLabel)

        addCircleAroundMainButtons(named: categoriesButtonTitle)
        addCircleAroundMainButtons(named: transactionsButtonTitle)
        addCircleAroundMainButtons(named: budgetButtonTitle)
        
        // Long press gesture recognizers
        let uilprDELETE = UILongPressGestureRecognizer(target: self, action: #selector(MainScreen.longpressDeleteEverything(gestureRecognizer:)))
        
        let uilprADD = UILongPressGestureRecognizer(target: self, action: #selector(MainScreen.longpressAddCategoriesAndTransactions(gestureRecognizer:)))
        
        uilprDELETE.minimumPressDuration = 2
        uilprADD.minimumPressDuration = 2
        
        hiddenDeleteButton.addGestureRecognizer(uilprDELETE)
        hiddenResetWithCategoriesAndTransactions.addGestureRecognizer(uilprADD)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        refreshAvailableBalanceLabel(label: availableBalanceLabel)
        selectedCategory = nil
        selectedStartDate = nil
        selectedEndDate = nil
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Long press recognizer function to - DELETE EVERYTHING
    @objc func longpressDeleteEverything(gestureRecognizer: UILongPressGestureRecognizer) {
        
        // Only does it once, even if it is held down for longer.
        // If this isn't done, then it'll keep adding a new one of these every 2 seconds (the amount of time we have it set).
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            let alert = UIAlertController(title: nil, message: "Delete EVERYTHING?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                budget.deleteEVERYTHING()
                self.refreshAvailableBalanceLabel(label: self.availableBalanceLabel)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    // MARK: - Long press recognizer function to - Add Categories and Transactions
    @objc func longpressAddCategoriesAndTransactions(gestureRecognizer: UILongPressGestureRecognizer) {
        
        // Only does it once, even if it is held down for longer.
        // If this isn't done, then it'll keep adding a new one of these every 2 seconds (the amount of time we have it set).
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            if budget.transactions.count == 0 && budget.categories.count == 1 {
                
                let alert = UIAlertController(title: nil, message: "Populate from scratch?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                    
                    
                    
                    // Two categories with some budgeted amounts
                    budget.addCategory(named: "Food", withBudgeted: 200.0)
                    budget.addCategory(named: "Extra", withBudgeted: 50.0)
                    
                    // Allocate their budgeted amounts into their available amounts
                    budget.shiftFunds(withThisAmount: 200, from: unallocatedKey, to: "Food")
                    budget.shiftFunds(withThisAmount: 50, from: unallocatedKey, to: "Extra")
                    
                    loadSavedCategories()
                    loadSavedTransactions(descending: true)
                    loadSavedBudgetedTimeFrames()
                    
                    if budget.budgetedTimeFrames.count == 0 {
                        
                        let start = Date.distantPast
                        let end = Date()
                        
                        budget.addTimeFrame(start: start, end: end)
                        loadSavedBudgetedTimeFrames()
                        
                    }
                    
                    self.refreshAvailableBalanceLabel(label: self.availableBalanceLabel)
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    
    

}













