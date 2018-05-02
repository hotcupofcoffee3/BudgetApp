//
//  EditTransactionAmountViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditTransactionAmountViewController: UIViewController, UITextFieldDelegate {

    var currentTransaction = budget.transactions[editableTransactionIndex]
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Update Amounts At Top
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    func updateLeftLabelAtTopRight() {
        
        budget.updateBalance()
        leftLabelOnNavBar.title = "$\(String(format: doubleFormatKey, budget.balance))"
        
        guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
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
    
    @IBOutlet weak var warningLabel: UILabel!
    
    
    
    
    @IBOutlet weak var editingItemLabel: UILabel!
    
    @IBOutlet weak var leftInCategoryLabel: UILabel!
    
    @IBOutlet weak var newAmountTextField: UITextField!
    
    
    func showAlertToConfirmUpdate(newAmount: Double) {
        
        // *** Alert message to pop up to confirmation
        
        let alert = UIAlertController(title: nil, message: "Change transaction amount from $\(String(format: doubleFormatKey, currentTransaction.inTheAmountOf)) to $\(String(format: doubleFormatKey, newAmount))?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            let updatedTransaction = budget.transactions[editableTransactionIndex]
            
            updatedTransaction.inTheAmountOf = newAmount
            
            budget.updateTransaction(named: updatedTransaction, forOldTransactionAtIndex: editableTransactionIndex)
            
            // Finds the index where this new transactionID is located, in order to set it to the current 'editableTransactionIndex' for the main 'EditTransactions' VC.
            if let newTransactionIndex = budget.transactions.index(where: { $0.id == updatedTransaction.id }) {
                
                editableTransactionIndex = newTransactionIndex
                
            }
            
            self.editingItemLabel.text = updatedTransaction.title
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func changeAmountSubmittedForReview () {
        
        guard let newAmountText = newAmountTextField.text else { return }
        
        if newAmountText == "" {
            
            failureWithWarning(label: warningLabel, message: "You haven't entered anything yet.")
            
        } else if Double(newAmountText) == nil {
            
            failureWithWarning(label: warningLabel, message: "You have to enter a number")
            
        } else {
            
            guard let newAmount = Double(newAmountText) else { return }
            guard let currentCategory = loadSpecificCategory(named: currentTransaction.forCategory!) else { return }
            
            if newAmount < 0.0 {
                
                failureWithWarning(label: warningLabel, message: "You have to enter an amount greater than 0")
                
            } else if newAmount > (currentTransaction.inTheAmountOf + currentCategory.available) && currentTransaction.type == withdrawalKey {
                
                failureWithWarning(label: warningLabel, message: "You don't have enough funds for this.")
                
            } else {
                
                showAlertToConfirmUpdate(newAmount: newAmount)
                
            }
            
        }
        
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
        
        
        
        // MARK: - Add done button
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor.black
        
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.dismissNumberKeyboard))
        doneButton.tintColor = UIColor.white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        newAmountTextField.inputAccessoryView = toolbar
        
        
        
        self.updateLeftLabelAtTopRight()
        
        self.editingItemLabel.text = "$\(String(format: doubleFormatKey, currentTransaction.inTheAmountOf))"
        
        if let currentCategory = loadSpecificCategory(named: currentTransaction.forCategory!) {
            
            self.leftInCategoryLabel.text = "~ Left in \(currentTransaction.forCategory!): $\(String(format: doubleFormatKey, currentCategory.available)) ~"
            
        }
        
        self.addCircleAroundButton(named: self.updateItemButton)
        
        self.newAmountTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: - Keyboard dismissals
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // 'Done' button on number pad to submit for review of final submitability
    @objc func dismissNumberKeyboard() {
        
        changeAmountSubmittedForReview()
        newAmountTextField.resignFirstResponder()
        
    }
    
    // Remove warning label text
    func textFieldDidBeginEditing(_ textField: UITextField) {
        warningLabel.text = ""
    }

}











