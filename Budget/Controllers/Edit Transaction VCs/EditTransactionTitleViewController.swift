//
//  EditTransactionTitleViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditTransactionTitleViewController: UIViewController, UITextFieldDelegate {
    
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
    
    @IBOutlet weak var warningLabel: UILabel!
    
    
    
    
    @IBOutlet weak var editingItemLabel: UILabel!
    
    @IBOutlet weak var newTitleTextField: UITextField!
    
    
    func showAlertToConfirmUpdate(newTitle: String) {
        
        // *** Alert message to pop up to confirmation
        
        let alert = UIAlertController(title: nil, message: "Change transaction title from \"\(currentTransaction.title)\" to \"\(newTitle)\"?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            let current = self.currentTransaction
            
            let newTransaction = Transaction(transactionID: current.transactionID, type: current.type, title: newTitle, forCategory: current.forCategory, inTheAmountOf: current.inTheAmountOf, year: current.year, month: current.month, day: current.day)
            
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
    
    func changeTitleSubmittedForReview () {
        
        guard let newTitleText = newTitleTextField.text else { return }
        
        if newTitleText == "" {
            
            failureWithWarning(label: warningLabel, message: "You haven't entered anything yet.")
            
        } else if newTitleText.count > 20 {
            
            failureWithWarning(label: warningLabel, message: "Really, that's too many characters.")
            
        } else {
            
            showAlertToConfirmUpdate(newTitle: newTitleText)
            
        }
        
    }
    
    
    @IBOutlet weak var updateItemButton: UIButton!
    
    @IBAction func updateItem(_ sender: UIButton) {
        
        changeTitleSubmittedForReview()

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
        
        self.editingItemLabel.text = currentTransaction.title
        self.addCircleAroundButton(named: self.updateItemButton)
        
        self.newTitleTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newTitleTextField.resignFirstResponder()
        changeTitleSubmittedForReview()
        return true
    }

}


//extension UIViewController {
//
//    // MARK: Failure message
//
//    func failureWithWarning(label: UILabel, message: String) {
//
//        // Warning notification haptic
//        let warning = UINotificationFeedbackGenerator()
//        warning.notificationOccurred(.error)
//
//        label.textColor = UIColor.red
//        label.text = message
//
//    }
//}






