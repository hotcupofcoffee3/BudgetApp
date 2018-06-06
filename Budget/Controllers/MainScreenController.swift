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
    
    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - Declared
    // *****
    
    var isDeleted = false
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var hiddenDeleteButton: UIButton!
    
    @IBOutlet weak var hiddenResetWithCategoriesAndTransactions: UIButton!
    
    @IBOutlet weak var availableBalanceLabel: UILabel!
    
    @IBOutlet weak var budgetButtonTitle: UIButton!
    
    @IBOutlet weak var paycheckButtonTitle: UIButton!
    
    @IBOutlet weak var categoriesButtonTitle: UIButton!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - General Functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func budgetButton(_ sender: UIButton) {
        performSegue(withIdentifier: mainToBudgetSegueKey, sender: self)
    }
    
    @IBAction func paycheckButton(_ sender: UIButton) {
        performSegue(withIdentifier: mainToPaycheckSegueKey, sender: self)
    }
    
    @IBAction func categoriesButton(_ sender: UIButton) {
        performSegue(withIdentifier: mainToCategoriesSegueKey, sender: self)
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
    
    
    
    
    
    // *****
    // MARK: - Tap Functions
    // *****
    
    // *** Long press recognizer function to - DELETE EVERYTHING
    
    @objc func longpressDeleteEverything(gestureRecognizer: UILongPressGestureRecognizer) {
        
        // Only does it once, even if it is held down for longer.
        // If this isn't done, then it'll keep adding a new one of these every 2 seconds (the amount of time we have it set).
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            let alert = UIAlertController(title: nil, message: "Delete EVERYTHING?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                budget.deleteEVERYTHING()
                self.refreshAvailableBalanceLabel(label: self.availableBalanceLabel)
                self.isDeleted = true
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    // *** Long press recognizer function to - Add Categories and Transactions
    
    @objc func longpressAddSomeStarterStuff(gestureRecognizer: UILongPressGestureRecognizer) {
        
        // Only does it once, even if it is held down for longer.
        // If this isn't done, then it'll keep adding a new one of these every 2 seconds (the amount of time we have it set).
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            if isDeleted {
                
                let alert = UIAlertController(title: nil, message: "Populate from scratch?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                    
//                    // An initial Deposit
//                    budget.addTransaction(onHold: false, type: .deposit, title: "Madelyn's Paycheck", forCategory: unallocatedKey, inTheAmountOf: 1700.00, year: 2018, month: 5, day: 15)
                    
                    //One Paycheck
                    createAndSaveNewPaycheck(named: "Madelyn's Paycheck", withAmount: 2000.00)
                    
                    // Three categories with some budgeted amounts
                    budget.addCategory(named: "Food", withBudgeted: 200.0, withDueDay: 0)
                    budget.addCategory(named: "Extra", withBudgeted: 80.0, withDueDay: 0)
                    budget.addCategory(named: "Netflix", withBudgeted: 20.0, withDueDay: 7)
                    
//                    // Three transactions with some amounts.
//                    budget.addTransaction(onHold: false, type: .withdrawal, title: "Sprouts", forCategory: "Food", inTheAmountOf: 25, year: 2018, month: 5, day: 16)
//                    budget.addTransaction(onHold: false, type: .withdrawal, title: "Whole Foods", forCategory: "Food", inTheAmountOf: 15.45, year: 2018, month: 5, day: 17)
//                    budget.addTransaction(onHold: false, type: .withdrawal, title: "Starbucks", forCategory: "Extra", inTheAmountOf: 2.98, year: 2018, month: 5, day: 24)
                    
                    
                    // One Past and One Future Budget Period
                    
                    let pastStartDate1 = convertComponentsToDate(year: 2018, month: 3, day: 1)
                    let pastEndDate1 = convertComponentsToDate(year: 2018, month: 3, day: 31)
                    addNewPeriod(start: pastStartDate1, end: pastEndDate1)

                    let futureStartDate1 = convertComponentsToDate(year: 2018, month: 12, day: 1)
                    let futureEndDate1 = convertComponentsToDate(year: 2018, month: 12, day: 31)
                    addNewPeriod(start: futureStartDate1, end: futureEndDate1)
                    
                    self.refreshAvailableBalanceLabel(label: self.availableBalanceLabel)
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // ********************
        // Core Data Testing (& Other Testing)
        // ********************
        
        
        
        // ********************
        // ********************
        // ********************
        
        
        // ***** Starting From Scratch on New Device
        loadSavedCategories()
        
        if budget.categories.count == 0 {
            budget.deleteEVERYTHING()
        }
        
        
        
        selectedCategory = nil
        
        addCircleAroundMainButtons(named: categoriesButtonTitle)
        addCircleAroundMainButtons(named: paycheckButtonTitle)
        addCircleAroundMainButtons(named: budgetButtonTitle)
        
        // Long press gesture recognizers
        let uilprDELETE = UILongPressGestureRecognizer(target: self, action: #selector(MainScreen.longpressDeleteEverything(gestureRecognizer:)))
        
        let uilprADD = UILongPressGestureRecognizer(target: self, action: #selector(MainScreen.longpressAddSomeStarterStuff(gestureRecognizer:)))
        
        uilprDELETE.minimumPressDuration = 1
        uilprADD.minimumPressDuration = 1
        
        hiddenDeleteButton.addGestureRecognizer(uilprDELETE)
        hiddenResetWithCategoriesAndTransactions.addGestureRecognizer(uilprADD)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        refreshAvailableBalanceLabel(label: availableBalanceLabel)
        selectedCategory = nil
        
    }
    
    
    
    
    
  
    
    
    


}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension MainScreen {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    
    
    
}













