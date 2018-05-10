//
//  EditTransactionAmountViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditTransactionAmountViewController: UIViewController, UITextFieldDelegate {

    
    // *****
    // MARK: - Variables
    // *****
    
    var currentTransaction = Transaction()
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var editingItemLabel: UILabel!
    
    @IBOutlet weak var leftInCategoryLabel: UILabel!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var newAmountTextField: UITextField!
    
    @IBOutlet weak var updateItemButton: UIButton!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateItem(_ sender: UIButton) {
        changeAmountSubmittedForReview()
    }


    
    // *****
    // MARK: - Functions
    // *****
    
    func showAlertToConfirmUpdate(newAmount: Double) {
        
        // *** Alert message to pop up to confirmation
        
        let alert = UIAlertController(title: nil, message: "Change transaction amount from \(convertedAmountToDollars(amount: currentTransaction.inTheAmountOf)) to \(convertedAmountToDollars(amount: newAmount))?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            guard let updatedTransaction = loadSpecificTransaction(idSubmitted: editableTransactionID) else { return }
            
            budget.updateTransactionAmount(amount: newAmount, withID: Int(updatedTransaction.id))
            
            self.successHaptic()
            
            budget.sortTransactionsDescending()
            
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
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let editableTransaction = loadSpecificTransaction(idSubmitted: editableTransactionID) else { return }
        
        currentTransaction = editableTransaction
        
        
        // MARK: Add tap gesture to textfields and their labels
        
        let amountViewTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped))
        
        amountView.addGestureRecognizer(amountViewTap)
        
        
        
        // MARK: - Add done button
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor.black
        
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.dismissNumberKeyboard))
        doneButton.tintColor = UIColor.white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        newAmountTextField.inputAccessoryView = toolbar
        
        
        // MARK: - Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
        
        self.updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        
        self.editingItemLabel.text = "\(convertedAmountToDollars(amount: currentTransaction.inTheAmountOf))"
        
        if let currentCategory = loadSpecificCategory(named: currentTransaction.forCategory!) {
            
            self.leftInCategoryLabel.text = "~ Left in \(currentTransaction.forCategory!): \(convertedAmountToDollars(amount: currentCategory.available)) ~"
            
        }
        
        self.addCircleAroundButton(named: self.updateItemButton)
        
        self.newAmountTextField.delegate = self
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    @objc func amountTapped() {
        
        newAmountTextField.becomeFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // 'Done' button on number pad to submit for review of final submitability
    @objc func dismissNumberKeyboard() {
        
        changeAmountSubmittedForReview()
        newAmountTextField.resignFirstResponder()
        
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
    
    // Remove warning label text
    func textFieldDidBeginEditing(_ textField: UITextField) {
        warningLabel.text = ""
    }
    
    
    
    
    
    
    
 
    
    
    
 
}















