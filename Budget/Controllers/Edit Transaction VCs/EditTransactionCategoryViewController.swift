//
//  EditTransactionCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditTransactionCategoryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

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
    
    @IBOutlet weak var leftInCategoryLabel: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    
    // MARK: - Picker
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    
    
    
    
    func showAlertToConfirmUpdate(newAmount: Double) {
        
        // *** Alert message to pop up to confirmation
        
        let alert = UIAlertController(title: nil, message: "Change transaction amount from $\(String(format: doubleFormatKey, currentTransaction.inTheAmountOf)) to $\(String(format: doubleFormatKey, newAmount))?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            let current = self.currentTransaction
            
            let newTransaction = Transaction(transactionID: current.transactionID, type: current.type, title: current.title, forCategory: current.forCategory, inTheAmountOf: newAmount, year: current.year, month: current.month, day: current.day)
            
            budget.updateTransaction(named: newTransaction, forOldTransactionAtIndex: editableTransactionIndex)
            
            // Finds the index where this new transactionID is located, in order to set it to the current 'editableTransactionIndex' for the main 'EditTransactions' VC.
            if let newTransactionIndex = budget.transactions.index(where: { $0.transactionID == newTransaction.transactionID }) {
                
                editableTransactionIndex = newTransactionIndex
                
            }
            
            self.editingItemLabel.text = newTransaction.title
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func changeAmountSubmittedForReview () {
        
        
        
    }
    
    
    @IBOutlet weak var updateItemButton: UIButton!
    
    @IBAction func updateItem(_ sender: UIButton) {
        
        changeAmountSubmittedForReview()
        
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
        
        self.editingItemLabel.text = "$\(String(format: doubleFormatKey, currentTransaction.inTheAmountOf))"
        
        if let currentCategory = budget.categories[currentTransaction.forCategory] {
            
            self.leftInCategoryLabel.text = "~ Left in \(currentTransaction.forCategory): $\(String(format: doubleFormatKey, currentCategory.available)) ~"
            
        }
        
        self.addCircleAroundButton(named: self.updateItemButton)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
