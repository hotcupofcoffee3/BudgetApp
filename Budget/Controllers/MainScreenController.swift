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
  
    
<<<<<<< HEAD
    @IBOutlet weak var availableBalanceLabel: UILabel!
    
    func refreshAvailableBalanceLabel() {
        if let availableBalance = budget.categories[uncategorizedKey] {
            availableBalanceLabel.text = "$\(String(format: doubleFormatKey, availableBalance.available))"
        }
=======
    @IBOutlet weak var hiddenDeleteButton: UIButton!
    @IBOutlet weak var hiddenResetWithCategoriesAndTransactions: UIButton!
    
    @IBOutlet weak var availableBalanceLabel: UILabel!
    
    func refreshAvailableBalanceLabel() {
        budget.updateBalance()
        availableBalanceLabel.text = "\(convertedAmountToDollars(amount: budget.balance))"
>>>>>>> switchToCoreData
    }
    
    @IBAction func categoriesButton(_ sender: UIButton) {
        performSegue(withIdentifier: mainToCategoriesSegueKey, sender: self)
    }
    
    @IBAction func transactionsButton(_ sender: UIButton) {
        performSegue(withIdentifier: mainToTransactionsSegueKey, sender: self)
    }
    
    @IBAction func deleteEVERYTHING(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: "Delete EVERYTHING?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            budget.deleteEVERYTHING()
            self.refreshAvailableBalanceLabel()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func addSomething(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            // Just so I don't forget the structure, this is the only one being left like this.
            // All the rest use the "performSegue()" function.
            
//            let addACategoryViewController = self.storyboard?.instantiateViewController(withIdentifier: addACategoryViewControllerKey) as! AddCategoryViewController
//
//            self.present(addACategoryViewController, animated: true, completion: nil)
            
            self.performSegue(withIdentifier: mainToAddCategorySegueKey, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Add Transaction", style: .default) { (action) in
          
            self.performSegue(withIdentifier: mainToAddTransactionSegueKey, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Move Funds", style: .default) { (action) in
            
            self.performSegue(withIdentifier: mainToMoveFundsSegueKey, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
<<<<<<< HEAD
//        for transaction in budget.transactions {
//            print(transaction.transactionID)
//        }
=======
        
        
        // ********************
        // Core Data Testing
        // ********************
      
       
        
        
        // ********************
        // ********************
        // ********************
        
        loadSavedCategories()
        loadSavedTransactions(descending: true)
        
        refreshAvailableBalanceLabel()

        categoriesButtonTitle.layer.cornerRadius = 35
        categoriesButtonTitle.layer.masksToBounds = true
        categoriesButtonTitle.layer.borderWidth = 2
        categoriesButtonTitle.layer.borderColor = tealColor.cgColor
        
        transactionsButtonTitle.layer.cornerRadius = 35
        transactionsButtonTitle.layer.masksToBounds = true
        transactionsButtonTitle.layer.borderWidth = 2
        transactionsButtonTitle.layer.borderColor = tealColor.cgColor
        
        
        // Long press gesture recognizers
        let uilprDELETE = UILongPressGestureRecognizer(target: self, action: #selector(MainScreen.longpressDeleteEverything(gestureRecognizer:)))
        
        let uilprADD = UILongPressGestureRecognizer(target: self, action: #selector(MainScreen.longpressAddCategoriesAndTransactions(gestureRecognizer:)))
        
        uilprDELETE.minimumPressDuration = 2
        uilprADD.minimumPressDuration = 2
        
        hiddenDeleteButton.addGestureRecognizer(uilprDELETE)
        hiddenResetWithCategoriesAndTransactions.addGestureRecognizer(uilprADD)
>>>>>>> switchToCoreData
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshAvailableBalanceLabel()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
<<<<<<< HEAD
    
    
=======
    // MARK: - Long press recognizer function to - DELETE EVERYTHING
    @objc func longpressDeleteEverything(gestureRecognizer: UILongPressGestureRecognizer) {
        
        // Only does it once, even if it is held down for longer.
        // If this isn't done, then it'll keep adding a new one of these every 2 seconds (the amount of time we have it set).
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            let alert = UIAlertController(title: nil, message: "Delete EVERYTHING?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                budget.deleteEVERYTHING()
                self.refreshAvailableBalanceLabel()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
>>>>>>> switchToCoreData
    
    // MARK: - Long press recognizer function to - Add Categories and Transactions
    @objc func longpressAddCategoriesAndTransactions(gestureRecognizer: UILongPressGestureRecognizer) {
        
        // Only does it once, even if it is held down for longer.
        // If this isn't done, then it'll keep adding a new one of these every 2 seconds (the amount of time we have it set).
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            if budget.transactions.count == 0 && budget.categories.count == 1 {
                
                let alert = UIAlertController(title: nil, message: "Populate from scratch?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                    
                    // An initial Deposit
                    budget.addTransaction(type: .deposit, title: "Paycheck", forCategory: unallocatedKey, inTheAmountOf: 500.00, year: 2018, month: 4, day: 25)
                    
                    // Two categories with some budgeted amounts
                    budget.addCategory(named: "Food", withBudgeted: 200.0)
                    budget.addCategory(named: "Extra", withBudgeted: 50.0)
                    
                    // Allocate their budgeted amounts into their available amounts
                    budget.allocateFundsToCategory(withThisAmount: 200, to: "Food")
                    budget.allocateFundsToCategory(withThisAmount: 50, to: "Extra")
                    
                    
                    
                    // Two transactions with some amounts.
                    budget.addTransaction(type: .withdrawal, title: "Sprouts", forCategory: "Food", inTheAmountOf: 25, year: 2018, month: 4, day: 26)
                    budget.addTransaction(type: .withdrawal, title: "Whole Foods", forCategory: "Food", inTheAmountOf: 15.45, year: 2018, month: 4, day: 27)
                    
                    loadSavedCategories()
                    loadSavedTransactions(descending: true)
                    
                    self.refreshAvailableBalanceLabel()
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    
    

}



// MARK: - Convert Amount to Dollars

extension UIViewController {
    
    func convertedAmountToDollars(amount: Double) -> String {
        
        var convertedAmount = ""
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        if let convertedAmountOptional = numberFormatter.string(from: NSNumber(value: amount)) {
            
            convertedAmount = convertedAmountOptional
            
        }
        
        return convertedAmount
        
    }
    
}













