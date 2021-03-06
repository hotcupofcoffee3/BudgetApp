//
//  ExtensionFunctionsViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/4/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class ExtensionFunctionsViewController: UIViewController {
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - Declared
    // *****
    
    
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - General Functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    
    
    
    
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
    
    
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    
    
    
    
    
    
    
    // IN EXTENSION
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    



    
    
    
    
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
    
    
    
    // MARK: - Convert Dollars to Amount
    
    func convertedDollarsToAmount(dollars: String) -> Double? {
        
        var convertedDollars: Double?
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        if let convertedAmountOptional = numberFormatter.number(from: dollars) {
            
            convertedDollars = convertedAmountOptional.doubleValue
            
        }
        
        return convertedDollars
        
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
    
    
    
    
    // MARK: - Convert Day/Int to Date with Current Month and Year
    
    func convertDayToCurrentDate(day: Int) -> Date {
        
        let calendar = Calendar.current

        let month = calendar.component(.month, from: Date())
        let year = calendar.component(.year, from: Date())
        let day = day
        
        let convertedDate = convertComponentsToDate(year: year, month: month, day: day)

        return convertedDate
        
    }
    
    
    
    
    // MARK: - Main Views Updating Budget Balance Label
    
    func refreshAvailableBalanceLabel(label: UILabel) {
        
        let periods = loadAndSortBudgetedTimeFrames()
        
        label.text = "\(convertedAmountToDollars(amount: periods[0].balance))"
        
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
    
//    func addSomethingAlertPopup(addCategorySegue: String, addTransactionSegue: String) {
//        
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        
//        // Just so I don't forget the structure, this is the only one being left like this.
//        // All the rest use the "performSegue()" function.
//        
//        //  let addACategoryViewController = self.storyboard?.instantiateViewController(withIdentifier: addACategoryViewControllerKey) as! AddCategoryViewController
//        //
//        //  self.present(addACategoryViewController, animated: true, completion: nil)
//        
//        alert.addAction(UIAlertAction(title: "Add Category", style: .default) { (action) in
//            
//            self.performSegue(withIdentifier: addCategorySegue, sender: self)
//            
//        })
//        
//        alert.addAction(UIAlertAction(title: "Add Transaction", style: .default) { (action) in
//            
//            self.performSegue(withIdentifier: addTransactionSegue, sender: self)
//            
//        })
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        present(alert, animated: true, completion: nil)
//        
//    }
    
    
    
    // MARK: - Update Budget Balance & Unallocated Balance on Top Right of Nav Bars
    
    func updatePeriodBalanceAndClickedBalanceLabelsAtTop(barButton: UIBarButtonItem, itemOrTransactionBalance: UILabel, startID: Int, itemName: String?, itemType: String?, isNewBudgetItem: Bool) {
        
        
        
        // Period Balance
        guard let period = loadSpecificBudgetedTimeFrame(startID: startID) else { return }
        
        barButton.title = "\(convertedAmountToDollars(amount: period.balance))"
        
        
        
        // Item Balance
        var currentItem: BudgetItem?
        
        if isNewBudgetItem {
            
            guard let unallocated = loadUnallocatedItem(startID: startID) else { return }
            
            currentItem = unallocated
            
        } else {
            
            if let name = itemName, let type = itemType {
                
                guard let chosenItem = loadSpecificBudgetItem(startID: startID, named: name, type: type) else { return }
                
                currentItem = chosenItem
                
            } else {
                
                return print("Cannot load the balance of this item")
                
            }
        
        }
        
        if let item = currentItem {
            
            itemOrTransactionBalance.text = "\(item.name!): \(convertedAmountToDollars(amount: item.available))"
            
        } else {
            
            return print("Something didn't go right with the item or transaction balance.")
            
        }
        
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
    
    
    
    // MARK: - Update Left In Category Amount For Editting VCs
    
    func updateLeftInCategoryAmount(categoryName: String, forLabel: UILabel) {
        
        guard let category = loadSpecificCategory(named: categoryName) else {
            
            forLabel.text = "Nothing"
            return
            
        }
        
        forLabel.text = "~ Left in \(categoryName): \(convertedAmountToDollars(amount: category.budgeted)) ~"
        
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



















