//
//  EditTransactionDateViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditTransactionDateViewController: UIViewController {

    var currentTransaction = budget.transactions[editableTransactionIndex]
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Update Amounts At Top
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    func updateLeftLabelAtTopRight() {
        
        leftLabelOnNavBar.title = "$\(String(format: doubleFormatKey, budget.balance))"
        
        guard let unallocated = budget.categories[unallocatedKey] else { return }
        leftAmountAtTopRight.text = "Unallocated: $\(String(format: doubleFormatKey, unallocated.available))"
    }
    
    
    // MARK: Failure message
    
    func failureWithWarning(label: UILabel, message: String) {
        
        // Warning notification haptic
        let warning = UINotificationFeedbackGenerator()
        warning.notificationOccurred(.error)
        
        label.textColor = UIColor.red
        label.text = message
        
    }
    
    @IBOutlet weak var editingItemLabel: UILabel!
    
    @IBOutlet weak var newDatePicker: UIDatePicker!
    
    
    func showAlertToConfirmUpdate(newMonth: Int, newDay: Int, newYear: Int) {
        
        // *** Alert message to pop up to confirmation
        
        let alert = UIAlertController(title: nil, message: "Change transaction date to \(newMonth)/\(newDay)/\(newYear)?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            let current = self.currentTransaction
            
            let newID = budget.convertedDateComponentsToTransactionID(year: newYear, month: newMonth, day: newDay)
            
            let newTransaction = Transaction(transactionID: newID, type: current.type, title: current.title, forCategory: current.forCategory, inTheAmountOf: current.inTheAmountOf, year: newYear, month: newMonth, day: newDay)
            
            budget.updateTransaction(named: newTransaction, forOldTransactionAtIndex: editableTransactionIndex)
            
            budget.sortTransactionsDescending()
            
            // Finds the index where this new transactionID is located, in order to set it to the current 'editableTransactionIndex' for the main 'EditTransactions' VC.
            if let newTransactionIndex = budget.transactions.index(where: { $0.transactionID == newTransaction.transactionID }) {
                
                editableTransactionIndex = newTransactionIndex
                
            }
            
            self.editingItemLabel.text = "\(newMonth)/\(newDay)/\(newYear)"
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func changeDateSubmittedForReview () {
        
        let newDateDictionary = convertDateToInts(dateToConvert: newDatePicker.date)
        guard let newMonth = newDateDictionary[monthKey] else { return }
        guard let newDay = newDateDictionary[dayKey] else { return }
        guard let newYear = newDateDictionary[yearKey] else { return }
        
        if currentTransaction.month == newMonth && currentTransaction.day == newDay && currentTransaction.year == newYear {
            
            failureWithWarning(label: warningLabel, message: "This is already the date.")
            
        } else {
            
            showAlertToConfirmUpdate(newMonth: newMonth, newDay: newDay, newYear: newYear)
            
        }
        
    }
    
    @IBOutlet weak var warningLabel: UILabel!
    
    
    @IBOutlet weak var updateItemButton: UIButton!
    
    @IBAction func updateItem(_ sender: UIButton) {
        
        changeDateSubmittedForReview()
        
    }
    
    
    // MARK: - Button Formatter
    func addCircleAroundButton(named button: UIButton) {
        
        button.layer.cornerRadius = 27
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = lightGreenColor.cgColor
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateLeftLabelAtTopRight()
        
        self.editingItemLabel.text = "\(currentTransaction.month)/\(currentTransaction.day)/\(currentTransaction.year)"
        
        
        self.addCircleAroundButton(named: self.updateItemButton)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
    

}
