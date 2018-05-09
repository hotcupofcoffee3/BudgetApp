//
//  ExtensionFunctionsViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/4/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class ExtensionFunctionsViewController: UIViewController {
    
    // *****
    // MARK: - Variables
    // *****
    
    
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    
    
    
    
    // *****
    // MARK: - TableView
    // *****
    
    
    
    
    
    // *****
    // MARK: - PickerView
    // *****
    
    
    
    
    
    // *****
    // MARK: - DatePickerView
    // *****
    
    
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
}

extension UIViewController {
    
    
    
    // MARK: - Convert Amount to Dollars
        
    func convertedAmountToDollars(amount: Double) -> String {
        
        var convertedAmount = ""
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        if let convertedAmountOptional = numberFormatter.string(from: NSNumber(value: amount)) {
            
            convertedAmount = convertedAmountOptional
            
        }
        
        return convertedAmount
        
    }
    
    
    
    // MARK: - Main Views Updating Budget Balance Label
    
    func refreshAvailableBalanceLabel(label: UILabel) {
        
        budget.updateBalance()
        
        label.text = "\(convertedAmountToDollars(amount: budget.balance))"
        
    }
    
    
    
    // MARK: - Button for Editing Screens Formatter
    func addCircleAroundButton(named button: UIButton) {
        
        button.layer.cornerRadius = 27
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = lightGreenColor.cgColor
        
    }
    
    
    
    // MARK: - Button for Main Views Formatter
    func addCircleAroundMainButtons(named button: UIButton) {
        
        button.layer.cornerRadius = 35
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = tealColor.cgColor
        
    }
    
    
    
    // MARK: - Add Something Alert Popup Function
    
    func addSomethingAlertPopup(addCategorySegue: String, addTransactionSegue: String, moveFundsSegue: String) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Just so I don't forget the structure, this is the only one being left like this.
        // All the rest use the "performSegue()" function.
        
        //  let addACategoryViewController = self.storyboard?.instantiateViewController(withIdentifier: addACategoryViewControllerKey) as! AddCategoryViewController
        //
        //  self.present(addACategoryViewController, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            self.performSegue(withIdentifier: addCategorySegue, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Add Transaction", style: .default) { (action) in
            
            self.performSegue(withIdentifier: addTransactionSegue, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Move Funds", style: .default) { (action) in
            
            self.performSegue(withIdentifier: moveFundsSegue, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    // MARK: - Update Budget Balance & Unallocated Balance on Top Right of Nav Bars
    
    func updateLeftLabelAtTopRight(barButton: UIBarButtonItem, unallocatedButton: UILabel) {
        
        budget.updateBalance()
        barButton.title = "\(convertedAmountToDollars(amount: budget.balance))"
        
        guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
        unallocatedButton.text = "Unallocated: \(convertedAmountToDollars(amount: unallocated.available))"
    }
    
    
    
    // MARK: - Failure message
    
    func failureWithWarning(label: UILabel, message: String) {
        
        // Warning notification haptic
        let warning = UINotificationFeedbackGenerator()
        warning.notificationOccurred(.error)
        
        label.textColor = UIColor.red
        label.text = message
        
    }
    
    
    
    // MARK: - Success Haptic
    func successHaptic() {
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
    }
    
    
    
    // MARK: - Load Chosen Transactions
    
    func loadChosenTransactions() -> [Transaction] {
        
        var transactionsToDisplay = [Transaction]()
        
        if selectedCategory == nil && selectedStartDate == nil {
            
            loadSavedTransactions(descending: true)
            
            transactionsToDisplay = budget.transactions
            
        } else if selectedCategory != nil && selectedStartDate == nil {
            
            if let category = selectedCategory {
                
                transactionsToDisplay = loadTransactionsByCategory(selectedCategory: category)
                
            }
            
        } else if selectedCategory == nil && selectedStartDate != nil && selectedEndDate != nil {
            
            if let start = selectedStartDate, let end = selectedEndDate {
                
                transactionsToDisplay = loadTransactionsByDate(selectedStartDate: start, selectedEndDate: end)
                
            }
            
        }
        
        return transactionsToDisplay
        
    }
    
    
    // MARK: - Update Left In Category Amount For Editting VCs
    
    func updateLeftInCategoryAmount(categoryName: String, forLabel: UILabel) {
        
        guard let category = loadSpecificCategory(named: categoryName) else {
            
            forLabel.text = "Nothing"
            return
            
        }
        
        forLabel.text = "~ Left in \(categoryName): \(convertedAmountToDollars(amount: category.available)) ~"
        
    }
    
    
    
}











