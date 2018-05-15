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
    // MARK: - Header for Main
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    
    
    
    
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
    // MARK: - Keyboard functions
    // *****
    
    
    
    
    
}

extension UIViewController {
    
    
    
    // MARK: - Convert Amount to Double
    
    func convertedAmountToDouble(amount: Double) -> String {
        
        let convertedAmount = "\(String(format: "%0.2f", amount))"
        
        return convertedAmount
        
    }
    
    
    
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
    
    
    
    // MARK: - Convert Day/Int to Ordinal
    
    func convertDayToOrdinal(day: Int) -> String {
        
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .ordinal
        
        guard let ordinalNumber = formatter.string(from: NSNumber(value: day)) else {
            
            return "No number"
            
        }
        
        return ordinalNumber
        
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
    
    
    
    // MARK: - Cell for Budget
    
    func addBorderAroundBudgetTableCellViews(cellView: UIView) {
        
        cellView.layer.cornerRadius = 15
        cellView.layer.masksToBounds = true
        cellView.layer.borderWidth = 2
        cellView.layer.borderColor = tealColor.cgColor
        
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
    
    func updateBalanceAndUnallocatedLabelsAtTop(barButton: UIBarButtonItem, unallocatedButton: UILabel) {
        
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
        
        if selectedCategory == nil {
            
            loadSavedTransactions(descending: true)
            
            transactionsToDisplay = budget.transactions
            
        } else {
            
            if let category = selectedCategory {
                
                transactionsToDisplay = loadTransactionsByCategory(selectedCategory: category)
                
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
    
    
    // MARK: - Convert Calendar Components to Date
    
    func convertComponentsToDate(year: Int, month: Int, day: Int) -> Date {
        
        var dateConverted: Date
        
        let calender = Calendar(identifier: .gregorian)
        
        let components = DateComponents(year: Int(year), month: Int(month), day: Int(day))
        
        guard let conversion = calender.date(from: components) else {
            fatalError("Date components could not be converted.")
        }
        
        dateConverted = conversion
        
        return dateConverted
        
    }
    
    
    
    
    
    
    // MARK: - Toolbar with 'Done' button
    
    // 'Done' button on number pad to submit for review of final submitability
    @objc func dismissNumberKeyboard() {
        
        
        
    }
    
    func addToolBarToNumberPad(textField: UITextField) {
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor.black
        
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.dismissNumberKeyboard))
        doneButton.tintColor = UIColor.white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        textField.inputAccessoryView = toolbar
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}



















