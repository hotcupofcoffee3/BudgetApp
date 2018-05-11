//
//  EditTransactionTitleViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditTransactionTitleViewController: UIViewController, UITextFieldDelegate {
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var currentTransaction: Transaction!
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var editingItemLabel: UILabel!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var newTitleTextField: UITextField!
    
    @IBOutlet weak var updateItemButton: UIButton!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateItem(_ sender: UIButton) {
        changeTitleSubmittedForReview()
    }
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    func showAlertToConfirmUpdate(newTitle: String) {
        
        // *** Alert message to pop up to confirmation
        
        let alert = UIAlertController(title: nil, message: "Change transaction title from \"\(currentTransaction.title!)\" to \"\(newTitle)\"?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            guard let updatedTransaction = loadSpecificTransaction(idSubmitted: editableTransactionID) else { return }
            
            budget.updateTransactionTitle(title: newTitle, withID: Int(updatedTransaction.id))
            
            self.successHaptic()
            
            budget.sortTransactionsDescending()
            
            self.editingItemLabel.text = updatedTransaction.title
            
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
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let editableTransaction = loadSpecificTransaction(idSubmitted: editableTransactionID) else { return }
        
        currentTransaction = editableTransaction
        
        
        // MARK: Add tap gesture to textfields and their labels
        
        let nameViewTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        
        nameView.addGestureRecognizer(nameViewTap)
        
        
        
        self.updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        
        self.editingItemLabel.text = currentTransaction.title
        self.addCircleAroundButton(named: self.updateItemButton)
        
        self.newTitleTextField.delegate = self
        
        
        // MARK: - Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    @objc func nameTapped() {
        
        newTitleTextField.becomeFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newTitleTextField.resignFirstResponder()
        changeTitleSubmittedForReview()
        return true
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
    
    
    
    
    
    
    

    
    
  
    
   

}

















