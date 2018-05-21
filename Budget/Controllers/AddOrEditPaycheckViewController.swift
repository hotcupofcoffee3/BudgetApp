//
//  AddOrEditPaycheckViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddOrEditPaycheckViewController: UIViewController, UITextFieldDelegate {
    
    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - Declared
    // *****
    
    var isNewPaycheck = true
    
    var editablePaycheck: Paycheck?
    
    var editablePaycheckName = String()
    
    var editablePaycheckAmount = Double()
    
    
    
    // *****
    // Mark: - IBOutlets
    // *****
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var submitPaycheckButton: UIButton!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - General Functions
    // *****
    
    func updateUIElementsBecauseOfSuccess() {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Set text fields back to being empty
        nameTextField.text = nil
        amountTextField.text = nil
        
    }
    
    
    
    // *****
    // Mark: - IBActions
    // *****
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitPaycheck(_ sender: UIButton) {
        
        if isNewPaycheck {
            
            submitAddPaycheckForReview()
            
        } else {
            
            submitEditPaycheckForReview()
            
        }
        
    }
    
    
    
    // *****
    // Mark: - Submissions
    // *****
    
    // ************************************************************************************************
    // ************************************************************************************************
    /*
     
     Add Or Edit Section
     
     */
    // ************************************************************************************************
    // ************************************************************************************************
    
    
    
    // **************************************
    // ***** Add Paycheck
    // **************************************
    
    
    
    // *** Add Transaction Check
    
    func submitAddPaycheckForReview() {
        
        guard let newName = nameTextField.text else { return }
        guard let newAmount = amountTextField.text else { return }
        
        // *** Checks if it's already created.
        var isAlreadyCreated = false
        
        for paycheck in budget.paychecks {
            
            if paycheck.name! == newName {
                
                isAlreadyCreated = true
                
            }
            
        }
        
        // *** If everything is blank
        if newName == "" || newAmount == "" {
            
            failureWithWarning(label: warningLabel, message: "You have to complete both fields.")
            
            
            // *** If "Unallocated" is the attempted name
        } else if newName == unallocatedKey {
            
            failureWithWarning(label: warningLabel, message: "You can't use the word \"Unallocated\"")
            
            
            // *** If the category name already exists.
        } else if isAlreadyCreated == true {
            
            failureWithWarning(label: warningLabel, message: "A paycheck with the name \"\(newName)\" has already been created.")
            
            
            // *** If both are filled out, but the amount is not a double
        } else if newName != "" && newAmount != "" && Double(newAmount) == nil {
            
            failureWithWarning(label: warningLabel, message: "You have to enter a number for the amount.")
            
            
        } else {
            
            if let newAmountAsDouble = Double(newAmount) {
                
                if newAmountAsDouble < 0.0 {
                    
                    failureWithWarning(label: warningLabel, message: "You have to enter a positive number")
                    
                    
                } else {
                    
                    showAlertToConfirmAddPaycheck(newPaycheckName: newName, with: newAmountAsDouble)
                    
                }
                
            }
            
        }
        
    }
    
    
    // Alert Confirmation
    
    func showAlertToConfirmAddPaycheck(newPaycheckName name: String, with amount: Double) {
        
        nameTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        
        let alert = UIAlertController(title: nil, message: "Add a paycheck called \"\(name)\" in the amount of \(self.convertedAmountToDollars(amount: amount))?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            createAndSaveNewPaycheck(named: name, withAmount: amount)
            
            self.warningLabel.textColor = successColor
            self.warningLabel.text = "A paycheck named \"\(name)\" with \(self.convertedAmountToDollars(amount: amount)) was just created. Congrats!"
            
            self.successHaptic()
            
            self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    // **************************************
    // ***** Edit Paycheck
    // **************************************
    
    
    
    func submitEditPaycheckForReview() {
        
        // The 'else' on this leads to the next 'submit' check, and so on, until the end, in which case the 'else' calls the 'showAlertToConfirmEdits' function.
        submitEditNameForReview()
        
    }
    
    // ***** Edit Name
    
    func submitEditNameForReview() {
        
        guard let newName = nameTextField.text else { return }
        
        if newName == "" {
            
            failureWithWarning(label: warningLabel, message: "You haven't entered anything yet.")
            
            
        } else if newName.count > 20 {
            
            failureWithWarning(label: warningLabel, message: "Really, that's too many characters.")
            
            
        } else {
            
            submitEditAmountForReview()
            
        }
        
    }
    
    
    
    // ***** Edit Amount
    
    func submitEditAmountForReview() {
        
        guard let newAmountText = amountTextField.text else { return }
        
        if newAmountText == "" {
            
            failureWithWarning(label: warningLabel, message: "You haven't entered anything yet.")
            
            
        } else if Double(newAmountText) == nil {
            
            failureWithWarning(label: warningLabel, message: "You have to enter a number")
            
            
        } else {
            
            guard let newAmount = Double(newAmountText) else { return }

            if newAmount < 0.0 {
                
                failureWithWarning(label: warningLabel, message: "You have to enter an amount greater than 0")
                
                
            } else {
                
                showAlertToConfirmEdits()
                
            }
            
        }
        
    }
    
    func showAlertToConfirmEdits() {
        
        // *** Add in all checks to see if something has been changed or not, then pop up alert message with specific items to update.
        // *** Alert only shows actual changes being made.
        
        guard let currentPaycheck = editablePaycheck else { return }
        
        var updatedItemsConfirmationMessage = ""
        
        
        // Name
        guard let newName = nameTextField.text else { return }
        var changeName = false
        if newName != currentPaycheck.name {
            changeName = true
            updatedItemsConfirmationMessage += "Change name to: \(newName)?\n"
        }
        
        
        // Amount
        guard let newAmount = Double(amountTextField.text!) else { return }
        var changeAmount = false
        if newAmount != currentPaycheck.amount {
            changeAmount = true
            updatedItemsConfirmationMessage += "Change amount to: \(convertedAmountToDollars(amount: newAmount))?\n"
        }
    
        
        if !changeName && !changeAmount {
            
            failureWithWarning(label: warningLabel, message: "There is nothing to update.")
            
        } else {
            
            let alert = UIAlertController(title: nil, message: updatedItemsConfirmationMessage, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                if changeName {
                    budget.updatePaycheckName(newName: newName, forPaycheck: currentPaycheck)
                }
                if changeAmount {
                    budget.updatePaycheckAmount(newAmount: newAmount, forPaycheck: currentPaycheck)
                }
                
                self.successHaptic()
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    
   
    
    
    
    // *****
    // Mark: - Delegates
    // *****
    
    
    
    
    
    // *****
    // Mark: - Segues
    // *****
    
    
    
    
    
    // *****
    // Mark: - Tap Functions
    // *****
    
    @objc func nameTapped() {
        
        nameTextField.becomeFirstResponder()
        
    }
    
    @objc func amountTapped() {
        
        amountTextField.becomeFirstResponder()
        
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
    
    
    
    // *****
    // Mark: - Keyboard functions
    // *****
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // Test for submitability
    func submissionFromKeyboardReturnKey(specificTextField: UITextField) {
        
        if nameTextField.text != "" && amountTextField.text != "" {
            
            if isNewPaycheck {
                
                submitAddPaycheckForReview()
                
            } else {
                
                submitEditPaycheckForReview()
                
            }
            
        } else {
            specificTextField.resignFirstResponder()
        }
        
    }
    
    // Submit for review of final submitability
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        submissionFromKeyboardReturnKey(specificTextField: textField)
        
        return true
    }
    
    // Remove warning label text
    func textFieldDidBeginEditing(_ textField: UITextField) {
        warningLabel.text = ""
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCircleAroundButton(named: submitPaycheckButton)

        let nameViewTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        let amountViewTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped))
        
        nameView.addGestureRecognizer(nameViewTap)
        amountView.addGestureRecognizer(amountViewTap)
        
        addToolBarToNumberPad(textField: amountTextField)
        
        
        // MARK: - Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
        
        self.updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        
        addCircleAroundButton(named: submitPaycheckButton)
        
        self.nameTextField.delegate = self
        self.amountTextField.delegate = self
        
        
        
        if isNewPaycheck == true {
            
            backButton.title = "Back"
            
            navBar.topItem?.title = "Add Paycheck"
            
            submitPaycheckButton.setTitle("Add Paycheck", for: .normal)
            
        } else {
            
            backButton.title = "Cancel"
            
            navBar.topItem?.title = "Edit Paycheck"
            
            guard let currentPaycheck = editablePaycheck else { return }
            
            guard let name = currentPaycheck.name else { return }
            
            nameTextField.text = name
            amountTextField.text = "\(convertedAmountToDouble(amount: currentPaycheck.amount))"
            
            submitPaycheckButton.setTitle("Save Changes", for: .normal)
            
        }
        
        
        
        
    }
    








}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension AddOrEditPaycheckViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    
    
    
}





















