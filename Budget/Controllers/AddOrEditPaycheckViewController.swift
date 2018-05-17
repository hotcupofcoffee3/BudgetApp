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
    
    
    
    
    
    // *****
    // Mark: - IBOutlets
    // *****
    
    
    
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - General Functions
    // *****
    
    
    
    
    
    // *****
    // Mark: - IBActions
    // *****
    
    
    
    
    
    // *****
    // Mark: - Submissions
    // *****
    
    
    
    
    
    // *****
    // Mark: - Delegates
    // *****
    
    
    
    
    
    // *****
    // Mark: - Segues
    // *****
    
    
    
    
    
    // *****
    // Mark: - Tap Functions
    // *****
    
    
    
    
    
    // *****
    // Mark: - Keyboard functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    
    
    
    
    
    
    
    // IN EXTENSION
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    
    
    
    
    
//
//
//    // *****
//    // MARK: - Variables
//    // *****
//
//    var isNewPaycheck = true
//
//    var editablePaycheck: Paycheck?
//
//    var editablePaycheckName = String()
//
//    var editablePaycheckAmount = Double()
//
//
//
//    // *****
//    // MARK: - Header for Add & Main Edit Views
//    // *****
//
//    // *** IBOutlets
//
//    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
//
//    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
//
//    @IBOutlet weak var warningLabel: UILabel!
//
//    @IBOutlet weak var addPaycheckButton: UIButton!
//
//
//
//    // *** IBActions
//
//    @IBAction func backButton(_ sender: UIBarButtonItem) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func addPaycheck(_ sender: UIButton) {
//        submitAddPaycheckForReview()
//    }
//
//
//
//    // *****
//    // MARK: - Loadables
//    // *****
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        loadSavedPaychecks()
//
//        let nameViewTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
//        let amountViewTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped))
//
//        nameView.addGestureRecognizer(nameViewTap)
//        amountView.addGestureRecognizer(amountViewTap)
//
//        addToolBarToNumberPad(textField: amountTextField)
//
//
//        // MARK: - Add swipe gesture to close keyboard
//
//        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
//        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
//        self.view.addGestureRecognizer(closeKeyboardGesture)
//
//
//        self.updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
//
//        addCircleAroundButton(named: addPaycheckButton)
//
//        self.nameTextField.delegate = self
//        self.amountTextField.delegate = self
//
//
//
//        if isNewTransaction == true {
//
//            let dateFormat = DateFormatter()
//            dateFormat.dateStyle = .short
//
//            dateLabel.text = dateFormat.string(from: Date())
//
//            if let category = selectedCategory {
//
//                categoryLabel.text = category
//
//            }
//
//            backButton.title = "Back"
//
//            navBar.topItem?.title = "Add Transaction"
//
//            submitTransactionButton.setTitle("Add Withdrawal", for: .normal)
//
//        } else {
//
//            backButton.title = "Cancel"
//            navBar.topItem?.title = "Edit Transaction"
//
//            guard let currentTransaction = editableTransaction else { return }
//
//            guard let name = currentTransaction.title else { return }
//            guard let category = currentTransaction.forCategory else { return }
//
//
//            guard let type = currentTransaction.type else { return }
//            transactionSegmentedControl.selectedSegmentIndex = (type == withdrawalKey) ? 0 : 1
//            transactionSelection = (type == withdrawalKey) ? .withdrawal : .deposit
//            transactionSegmentedControl.isEnabled = false
//            categoryLabel.isEnabled = (transactionSelection == .withdrawal)
//
//            transactionNameTextField.text = name
//            transactionAmountTextField.text = "\(convertedAmountToDouble(amount: currentTransaction.inTheAmountOf))"
//            date = convertComponentsToDate(year: Int(currentTransaction.year), month: Int(currentTransaction.month), day: Int(currentTransaction.day))
//            categoryLabel.text = category
//            setDate(date: date)
//            holdToggle.isOn = currentTransaction.onHold
//
//            submitTransactionButton.setTitle("Save Changes", for: .normal)
//
//        }
//
//
//
//
//    }
//
//
//
//    // *****
//    // MARK: - IBOutlets
//    // *****
//
//    @IBOutlet weak var nameView: UIView!
//
//    @IBOutlet weak var nameTextField: UITextField!
//
//    @IBOutlet weak var amountView: UIView!
//
//    @IBOutlet weak var amountTextField: UITextField!
//
//
//
//    // *****
//    // MARK: - IBActions
//    // *****
//
//
//
//
//
//    // *****
//    // MARK: - Functions
//    // *****
//
//    func updateUIElementsBecauseOfSuccess() {
//
//        // Success notification haptic
//        let successHaptic = UINotificationFeedbackGenerator()
//        successHaptic.notificationOccurred(.success)
//
//        // Set text fields back to being empty
//        nameTextField.text = nil
//        amountTextField.text = nil
//
//    }
//
//
//
//    @objc func nameTapped() {
//
//        nameTextField.becomeFirstResponder()
//
//    }
//
//    @objc func amountTapped() {
//
//        amountTextField.becomeFirstResponder()
//
//    }
//
//
//
//
//
//
//
//    // *****
//    // MARK: - Keyboard functions
//    // *****
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//
//
//    // Test for submitability
//    func submissionFromKeyboardReturnKey(specificTextField: UITextField) {
//
//        if nameTextField.text != "" && amountTextField.text != "" {
//
//            submitAddPaycheckForReview()
//
//        } else {
//            specificTextField.resignFirstResponder()
//        }
//
//    }
//
//    // Submit for review of final submitability
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//
//        submissionFromKeyboardReturnKey(specificTextField: textField)
//
//        return true
//    }
//
//    // Swipe to close keyboard
//    @objc func closeKeyboardFromSwipe() {
//
//        self.view.endEditing(true)
//
//    }
//
//    // Remove warning label text
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        warningLabel.text = ""
//    }
//
//
//    // ************************************************************************************************
//    // ************************************************************************************************
//    /*
//
//     Add Or Edit Section
//
//     */
//    // ************************************************************************************************
//    // ************************************************************************************************
//
//
//
//    // *****
//    // MARK: - Add Paycheck
//    // *****
//
//    // *** Add Category Check
//
//    func submitAddPaycheckForReview() {
//
//        if let name = nameTextField.text, let amount = amountTextField.text {
//
//            // *** Checks if it's already created.
//            var isAlreadyCreated = false
//
//            for paycheck in budget.paychecks {
//
//                if paycheck.name! == name {
//
//                    isAlreadyCreated = true
//
//                }
//
//            }
//
//            // *** If everything is blank
//            if name == "" || amount == "" {
//
//                failureWithWarning(label: warningLabel, message: "You have to complete both fields.")
//
//
//                // *** If the category name already exists.
//            } else if isAlreadyCreated == true {
//
//                failureWithWarning(label: warningLabel, message: "A paycheck with this name has already been created.")
//
//
//                // *** If both are filled out, but the amount is not a double
//            } else if name != "" && amount != "" && Double(amount) == nil {
//
//                failureWithWarning(label: warningLabel, message: "You have to enter a number for the amount.")
//
//
//            } else {
//
//                if let amountAsDouble = Double(amount) {
//
//                    if amountAsDouble < 0.0 {
//
//                        failureWithWarning(label: warningLabel, message: "You have to enter a positive number")
//
//
//                    } else {
//
//                        showAlertToConfirmAddPaycheck(newPaycheckName: name, with: amountAsDouble)
//
//                    }
//
//                }
//
//            }
//
//        }
//
//    }
//
//
//
//    // Alert Confirmation
//
//    func showAlertToConfirmAddPaycheck(newPaycheckName: String, with amount: Double) {
//
//        nameTextField.resignFirstResponder()
//        amountTextField.resignFirstResponder()
//
//        let alert = UIAlertController(title: nil, message: "Create a paycheck named \"\(newPaycheckName)\" with an amount of \(convertedAmountToDollars(amount: amount))?", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
//
//            createAndSaveNewPaycheck(named: newPaycheckName, withAmount: amount)
//
//            saveData()
//
//            self.warningLabel.textColor = successColor
//            self.warningLabel.text = "\"\(newPaycheckName)\" with an amount of \(self.convertedAmountToDollars(amount: amount)) has been added."
//
//            self.updateUIElementsBecauseOfSuccess()
//            self.successHaptic()
//            self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
//
//        }))
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        present(alert, animated: true, completion: nil)
//
//    }
//
//
//
//
//    // *****
//    // MARK: - Edit Paycheck
//    // *****
//
//
//
//    // *** Submit Edit Items For Review
//
//    func submitEditItemsForReview() {
//
//        // The 'else' on this leads to the next 'submit' check, and so on, until the end, in which case the 'else' calls the 'showAlertToConfirmEdits' function.
//        submitEditNameForReview()
//
//    }
//
//
//
//    // *** Show Alert To Confirm Edits
//
//    func showAlertToConfirmEdits() {
//
//        // *** Add in all checks to see if something has been changed or not, then pop up alert message with specific items to update.
//        // *** Alert only shows actual changes being made.
//
//        guard let currentCategory = editableCategory else { return }
//        guard let currentCategoryName = currentCategory.name else { return }
//
//        var updatedItemsConfirmationMessage = ""
//
//
//        // Name
//        guard let newName = categoryNameTextField.text else { return }
//        var changeName = false
//        if newName != currentCategory.name {
//            changeName = true
//            updatedItemsConfirmationMessage += "Change name to: \(newName)\n"
//        }
//
//
//        // Amount
//        guard let newAmount = Double(categoryAmountTextField.text!) else { return }
//        var changeAmount = false
//        if newAmount != currentCategory.budgeted {
//            changeAmount = true
//            updatedItemsConfirmationMessage += "Change budgeted amount to: \(convertedAmountToDollars(amount: newAmount))\n"
//        }
//
//
//        // Date
//        let newDate = date
//        var changeDate = false
//        let currentDate = convertDayToCurrentDate(day: Int(currentCategory.dueDay))
//
//        if dateLabel.text != "" && newDate != currentDate {
//
//            let newDateDict = convertDateToInts(dateToConvert: newDate)
//            guard let newDueDay = newDateDict[dayKey] else { return }
//
//            changeDate = true
//            updatedItemsConfirmationMessage += "Change Date to the \(convertDayToOrdinal(day: newDueDay))\n"
//        }
//
//
//        // Allocate
//        let willAllocate = currentAllocationStatus.isOn
//        if willAllocate == true {
//            updatedItemsConfirmationMessage += "Allocate: \(convertedAmountToDollars(amount: currentCategory.budgeted))"
//        }
//
//        // Final confirmation, checking to see if there is even anything to change.
//        if !changeName && !changeAmount && !changeDate && !willAllocate {
//
//            failureWithWarning(label: warningLabel, message: "There is nothing to update.")
//
//        } else {
//
//            let alert = UIAlertController(title: nil, message: updatedItemsConfirmationMessage, preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
//
//                if changeName {
//                    budget.updateCategory(named: currentCategoryName, updatedNewName: newName, andNewAmountBudgeted: currentCategory.budgeted)
//                }
//                if changeAmount {
//                    budget.updateCategory(named: currentCategoryName, updatedNewName: currentCategoryName, andNewAmountBudgeted: newAmount)
//                }
//                if willAllocate {
//                    budget.shiftFunds(withThisAmount: currentCategory.budgeted, from: unallocatedKey, to: currentCategoryName)
//                }
//                if changeDate {
//                    let newDateDict = convertDateToInts(dateToConvert: newDate)
//                    guard let newDueDay = newDateDict[dayKey] else { return }
//                    currentCategory.dueDay = Int64(newDueDay)
//                }
//
//                self.successHaptic()
//
//                self.dismiss(animated: true, completion: nil)
//
//            }))
//
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//            present(alert, animated: true, completion: nil)
//
//        }
//
//    }
//
//
//
//    // *** Edit Name Check
//
//    func submitEditNameForReview() {
//
//        if let newCategoryName = categoryNameTextField.text {
//
//            // *** Is the field empty?
//            if newCategoryName == "" {
//
//                failureWithWarning(label: warningLabel, message: "You can't leave the name blank.")
//
//
//                // *** Is the new category name equal to "Unallocated"?
//            } else if newCategoryName == unallocatedKey {
//
//                failureWithWarning(label: warningLabel, message: "You cannot rename a category to \"Unallocated\"")
//
//
//                // *** All impossible entries are taken care of.
//            } else {
//
//                // *** Go to Budgeted Amount Check
//
//                submitEditBudgetedForReview()
//
//            }
//
//        }
//
//    }
//
//
//
//    // *** Edit Budgeted Check
//
//    func submitEditBudgetedForReview() {
//
//        if let newBudgetedAmount = categoryAmountTextField.text {
//
//            var newCategoryBudgeted = Double()
//
//            // *** Is the field empty?
//            if newBudgetedAmount == ""  {
//
//                failureWithWarning(label: warningLabel, message: "You can't leave the budgeted amount empty.")
//
//
//                // *** Was the amount not convertible to a Double?
//            } else if Double(newBudgetedAmount) == nil {
//
//                failureWithWarning(label: warningLabel, message: "You have to enter a number.")
//
//
//                // *** All impossible entries are taken care of.
//            } else {
//
//                // Sets 'newCategoryBudgeted' to the number entered.
//                if let newCategoryBudgetedDouble = Double(newBudgetedAmount) {
//
//                    newCategoryBudgeted = newCategoryBudgetedDouble
//
//                }
//
//                // *** Was the amount entered less than 0?
//                if newCategoryBudgeted < 0.0 {
//
//                    failureWithWarning(label: warningLabel, message: "You have to enter a positive amount")
//
//
//                    // ***** SUCCESS!
//                } else {
//
//                    // ***** Go to Allocation Check
//
//                    submitAllocateForReview()
//
//                }
//
//            }
//
//        }
//
//    }
//
//
//
//    // *** Allocate Check
//
//    func submitAllocateForReview() {
//
//        if currentAllocationStatus.isOn {
//
//            guard let currentCategory = editableCategory else { return }
//            guard let unallocatedCategory = loadSpecificCategory(named: unallocatedKey) else { return }
//
//            // *** Were there enough funds available in the 'From' Category?
//            if currentCategory.budgeted > unallocatedCategory.available {
//
//                failureWithWarning(label: warningLabel, message: "There are not enough funds available to allocate the budgeted amount at this time.")
//
//
//                // ***** SUCCESS!
//            } else {
//
//                // ***** Present confirm popup
//
//                showAlertToConfirmEdits()
//
//            }
//
//        } else {
//
//            showAlertToConfirmEdits()
//
//        }
//
//    }
//
//    
//
//
//

}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension AddOrEditPaycheckViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    
    
    
}





















