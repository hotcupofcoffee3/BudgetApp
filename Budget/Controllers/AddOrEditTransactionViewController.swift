//
//  AddOrEditTransactionViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/20/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddOrEditTransactionViewController: UIViewController, UITextFieldDelegate, ChooseDate, ChooseCategory {
    
    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - Declared
    // *****
    
    var isNewTransaction = true
    
    var editableTransaction: Transaction?
    
    var transactionSelection = TransactionType.withdrawal
    
    var date = Date()
    
    var dateFormatYYYYMMDD = Int()
    
    
    
    // *****
    // Mark: - IBOutlets
    // *****
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var submitTransactionButton: UIButton!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var transactionSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var transactionNameTextField: UITextField!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var transactionAmountTextField: UITextField!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dateView: UIView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categoryView: UIView!
    
    @IBOutlet weak var holdToggle: UISwitch!
    
    @IBOutlet weak var holdView: UIView!
    
    @IBOutlet weak var paycheckLabel: UITextField!
    
    @IBOutlet weak var paycheckView: UIView!
    
    
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - General Functions
    // *****
    
    func updateUIElementsBecauseOfSuccess(forCategory category: String) {
        
        if isNewTransaction {
            
            // Success notification haptic
            let successHaptic = UINotificationFeedbackGenerator()
            successHaptic.notificationOccurred(.success)
            
            // Clearing text fields
            transactionNameTextField.text = nil
            transactionAmountTextField.text = nil
            
        }
        
    }
    
    func updateTransactionButtonBasedOnTransactionChoice(typeOfTransaction: TransactionType) {
        
        if isNewTransaction {
            
            if typeOfTransaction == .withdrawal {
                
                submitTransactionButton.setTitle("Add Withdrawal", for: .normal)
                categoryLabel.isEnabled = true
                
            } else if typeOfTransaction == .deposit {
                
                submitTransactionButton.setTitle("Add Deposit", for: .normal)
                
                categoryLabel.text = unallocatedKey
                categoryLabel.isEnabled = false
                
            }
            
        }
        
    }
    
    
    
    // *****
    // Mark: - IBActions
    // *****
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitTransaction(_ sender: UIButton) {
        
        if isNewTransaction {
            
            submitAddTransactionForReview()
            
        } else {
            
            submitEditItemsForReview()
            
        }
        
    }
    
    @IBAction func transactionSelected(_ sender: UISegmentedControl) {
       
        if isNewTransaction {
            
            if transactionSegmentedControl.selectedSegmentIndex == 0 {
                
                transactionSelection = .withdrawal
                
                updateTransactionButtonBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
                
            } else if transactionSegmentedControl.selectedSegmentIndex == 1 {
                
                transactionSelection = .deposit
                
                updateTransactionButtonBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
                
            }
            
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
    // ***** Add Transaction
    // **************************************
    
    
    
    // *** Add Transaction Check
    
    func submitAddTransactionForReview() {
        
        guard let title = transactionNameTextField.text else { return }
        guard let amount = transactionAmountTextField.text else { return }
        
        guard let category = categoryLabel.text else { return }
        
        let convertedDates = convertDateToInts(dateToConvert: date)
        
        if title == "" || amount == "" {
            
            failureWithWarning(label: warningLabel, message: "You have to fill in all fields.")
            
        } else {
            
            if let amount = Double(amount), let year = convertedDates[yearKey], let month = convertedDates[monthKey], let day = convertedDates[dayKey] {
                
                // MARK: Withdrawal
                
                if transactionSelection == .withdrawal {
                    
                    guard let categoryBeingWithdrawnFrom = loadSpecificCategory(named: category) else { return }
                    
                    if (categoryBeingWithdrawnFrom.available - amount) < 0 {
                        
                        failureWithWarning(label: warningLabel, message: "You don't have enough funds in this category.")
                        
                    } else if amount <= 0 {
                        
                        failureWithWarning(label: warningLabel, message: "You have to enter a number greater than 0.")
                        
                    } else {
                        
                        showAlertToConfirmTransaction(fullDate: date, type: .withdrawal, title: title, amount: amount, categoryName: category, year: year, month: month, day: day)
                        
                    }
                    
                    
                    // MARK: Deposit - Only can deposit into 'Uncategorized' category
                } else if transactionSelection == .deposit {
                    
                    if amount <= 0 {
                        
                        failureWithWarning(label: warningLabel, message: "You have to enter a number greater than 0.")
                        
                    } else {
                        
                        showAlertToConfirmTransaction(fullDate: date, type: .deposit, title: title, amount: amount, categoryName: unallocatedKey, year: year, month: month, day: day)
                        
                    }
                    
                }
                
            } else {
                
                failureWithWarning(label: warningLabel, message: "You have to enter a number for the amount.")
                
            }
            
        }
        
    }
    
    
    // Alert Confirmation
    
    func showAlertToConfirmTransaction(fullDate: Date, type: TransactionType, title: String, amount: Double, categoryName: String, year: Int, month: Int, day: Int) {
        
        transactionNameTextField.resignFirstResponder()
        transactionAmountTextField.resignFirstResponder()
        
        if type == .withdrawal {
            
            let alert = UIAlertController(title: nil, message: "Make a withdrawal called \"\(title)\" in the amount of \(self.convertedAmountToDollars(amount: amount))?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                var onHold = false
                
                if self.holdToggle.isOn {
                    
                    onHold = true
                    
                }
                
                budget.addTransaction(onHold: onHold, type: TransactionType.withdrawal, title: title, forCategory: categoryName, inTheAmountOf: amount, year: year, month: month, day: day)
                
                self.warningLabel.textColor = successColor
                self.warningLabel.text = "\(self.convertedAmountToDollars(amount: amount)) withdrawn from \(categoryName)"
                
                self.successHaptic()
                
                self.updateUIElementsBecauseOfSuccess(forCategory: categoryName)
                self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        } else if type == .deposit {
            
            let alert = UIAlertController(title: nil, message: "Deposit \"\(title)\" in the amount of \(self.convertedAmountToDollars(amount: amount))?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                var onHold = false
                
                if self.holdToggle.isOn {
                    
                    onHold = true
                    
                }
                
                budget.addTransaction(onHold: onHold, type: TransactionType.deposit, title: title, forCategory: unallocatedKey, inTheAmountOf: amount, year: year, month: month, day: day)
                
                self.warningLabel.textColor = successColor
                self.warningLabel.text = "\(self.convertedAmountToDollars(amount: amount)) was deposited."
                
                self.successHaptic()
                
                self.updateUIElementsBecauseOfSuccess(forCategory: unallocatedKey)
                self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    

    
    // **************************************
    // ***** Edit Transaction
    // **************************************
    
    
    
    func submitEditItemsForReview() {
        
        // The 'else' on this leads to the next 'submit' check, and so on, until the end, in which case the 'else' calls the 'showAlertToConfirmEdits' function.
        submitEditNameForReview()
        
    }
    
    func showAlertToConfirmEdits() {
        
        // *** Add in all checks to see if something has been changed or not, then pop up alert message with specific items to update.
        // *** Alert only shows actual changes being made.
        
        guard let currentTransaction = editableTransaction else { return }
        
        var updatedItemsConfirmationMessage = ""
        
        
        // Title
        guard let newTitle = transactionNameTextField.text else { return }
        var changeTitle = false
        if newTitle != currentTransaction.title {
            changeTitle = true
            updatedItemsConfirmationMessage += "Change title to: \(newTitle)\n"
        }
        
        
        // Amount
        guard let newAmount = Double(transactionAmountTextField.text!) else { return }
        var changeAmount = false
        if newAmount != currentTransaction.inTheAmountOf {
            changeAmount = true
            updatedItemsConfirmationMessage += "Change amount to: \(convertedAmountToDollars(amount: newAmount))\n"
        }
        
        
        // Date
        let newDate = date
        var changeDate = false
        let newDateDict = convertDateToInts(dateToConvert: newDate)
        let currentDate = convertComponentsToDate(year: Int(currentTransaction.year), month: Int(currentTransaction.month), day: Int(currentTransaction.day))
        guard let month = newDateDict[monthKey] else { return }
        guard let day = newDateDict[dayKey] else { return }
        guard let year = newDateDict[yearKey] else { return }
        
        if newDate != currentDate {
            changeDate = true
            updatedItemsConfirmationMessage += "Change Date to: \(month)/\(day)/\(year)\n"
        }
        
        
        // Category
        guard let newCategory = categoryLabel.text else { return }
        var changeCategory = false
        if newCategory != currentTransaction.forCategory {
            changeCategory = true
            updatedItemsConfirmationMessage += "Change category to: \(newCategory)\n"
        }
        
        
        // On Hold
        let newHoldStatus = holdToggle.isOn
        var changeHoldStatus = false
        if newHoldStatus != currentTransaction.onHold {
            changeHoldStatus = true
            updatedItemsConfirmationMessage += "Change 'On Hold' to: \(newHoldStatus)"
        }
        
        if !changeTitle && !changeAmount && !changeDate && !changeCategory && !changeHoldStatus {
            
            failureWithWarning(label: warningLabel, message: "There is nothing to update.")
            
        } else {
            
            let alert = UIAlertController(title: nil, message: updatedItemsConfirmationMessage, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                let id = Int(currentTransaction.id)
                
                if changeTitle {
                    budget.updateTransactionTitle(title: newTitle, withID: id)
                }
                if changeAmount {
                    budget.updateTransactionAmount(amount: newAmount, withID: id)
                }
                if changeDate {
                    budget.updateTransactionDate(newDate: newDate, withID: id)
                }
                if changeCategory {
                    budget.updateTransactionCategory(category: newCategory, withID: id)
                }
                if changeHoldStatus {
                    budget.updateBalanceAndAvailableForOnHold(withID: id)
                }
                
                self.successHaptic()
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    // ***** Edit Name
    
    func submitEditNameForReview() {
        
        guard let newNameText = transactionNameTextField.text else { return }
        
        if newNameText == "" {
            
            failureWithWarning(label: warningLabel, message: "You haven't entered anything yet.")
            
            
        } else if newNameText.count > 20 {
            
            failureWithWarning(label: warningLabel, message: "Really, that's too many characters.")
            
            
        } else {
            
            submitEditAmountForReview()
            
        }
        
    }
    
    
    
    // ***** Edit Amount
    
    func submitEditAmountForReview() {
        
        guard let newAmountText = transactionAmountTextField.text else { return }
        guard let currentTransaction = editableTransaction else { return }
        
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
                
                submitEditCategoryForReview()
                
            }
            
        }
        
    }
    
    
    
    // ***** Edit Category
    
    func submitEditCategoryForReview() {
        
        guard let currentTransaction = editableTransaction else { return }
        
        guard let newSelectedCategoryName = categoryLabel.text else { return }
        guard let newCategoryItself = loadSpecificCategory(named: newSelectedCategoryName) else { return }
        
        if currentTransaction.inTheAmountOf > newCategoryItself.available && currentTransaction.type == withdrawalKey {
            
            failureWithWarning(label: warningLabel, message: "There are not enough funds in that category for this transaction.")
            
            
        } else {
            
            showAlertToConfirmEdits()
            
        }
        
    }
    
    
    
    // *****
    // Mark: - Delegates
    // *****
    
    func setDate(date: Date) {
        
        self.date = date
        
        var dateDict = convertDateToInts(dateToConvert: date)
        
        if let year = dateDict[yearKey], let month = dateDict[monthKey], let day = dateDict[dayKey] {
            
            dateFormatYYYYMMDD = convertDateInfoToYYYYMMDD(year: year, month: month, day: day)
            
            dateLabel.text = "\(month)/\(day)/\(year)"
            
        }
        
    }
    
    func setCategory(category: String) {
        categoryLabel.text = category
    }
    
    
    
    // *****
    // Mark: - Segues
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == addOrEditTransactionToDatePickerSegueKey {
            
            let datePickerVC = segue.destination as! DatePickerViewController
            
            datePickerVC.delegate = self
            
            datePickerVC.date = date
            
        } else if segue.identifier == addOrEditTransactionToCategoryPickerSegueKey {
            
            let categoryPickerVC = segue.destination as! CategoryPickerViewController
            
            categoryPickerVC.delegate = self
            
            guard let currentCategory = categoryLabel.text else { return }
            
            categoryPickerVC.selectedCategory = currentCategory
            
        }
        
    }
    
    
    
    // *****
    // Mark: - Tap Functions
    // *****
    
    @objc func nameTapped() {
        
        transactionNameTextField.becomeFirstResponder()
        
    }
    
    @objc func amountTapped() {
        
        transactionAmountTextField.becomeFirstResponder()
        
    }
    
    @objc func dateTapped() {
        
        performSegue(withIdentifier: addOrEditTransactionToDatePickerSegueKey, sender: self)
        
    }
    
    @objc func categoryTapped() {
        
        if transactionSelection == .withdrawal {
            
            performSegue(withIdentifier: addOrEditTransactionToCategoryPickerSegueKey, sender: self)
            
        }
        
    }
    
    
    
    // *****
    // Mark: - Keyboard functions
    // *****
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func submissionFromKeyboardReturnKey(specificTextField: UITextField) {
        
        if transactionNameTextField.text != "" && transactionAmountTextField.text != "" {
            
            if isNewTransaction {
                
                submitAddTransactionForReview()
                
            } else {
                
                submitEditItemsForReview()
                
            }
            
        } else {
            specificTextField.resignFirstResponder()
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        submissionFromKeyboardReturnKey(specificTextField: textField)
        
        return true
    }
    
    @objc override func dismissNumberKeyboard() {
        transactionAmountTextField.resignFirstResponder()
        submissionFromKeyboardReturnKey(specificTextField: transactionAmountTextField)
        
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if isNewTransaction == true {
            
            let dateFormat = DateFormatter()
            dateFormat.dateStyle = .short
            
            dateLabel.text = dateFormat.string(from: Date())
            
            if let category = selectedCategory {
                
                categoryLabel.text = category
                
            }
            
            backButton.title = "Back"
            
            navBar.topItem?.title = "Add Transaction"
            
            submitTransactionButton.setTitle("Add Withdrawal", for: .normal)
            
        } else {
            
            backButton.title = "Cancel"
            navBar.topItem?.title = "Edit Transaction"
            
            guard let currentTransaction = editableTransaction else { return }
            
            guard let name = currentTransaction.title else { return }
            guard let category = currentTransaction.forCategory else { return }
            
            
            guard let type = currentTransaction.type else { return }
            transactionSegmentedControl.selectedSegmentIndex = (type == withdrawalKey) ? 0 : 1
            transactionSelection = (type == withdrawalKey) ? .withdrawal : .deposit
            transactionSegmentedControl.isEnabled = false
            categoryLabel.isEnabled = (transactionSelection == .withdrawal)
            
            transactionNameTextField.text = name
            transactionAmountTextField.text = "\(convertedAmountToDouble(amount: currentTransaction.inTheAmountOf))"
            date = convertComponentsToDate(year: Int(currentTransaction.year), month: Int(currentTransaction.month), day: Int(currentTransaction.day))
            categoryLabel.text = category
            setDate(date: date)
            holdToggle.isOn = currentTransaction.onHold
            
            submitTransactionButton.setTitle("Save Changes", for: .normal)
            
        }
        
        
        // MARK: Add tap gesture to textfields and their labels
        
        let nameViewTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        let amountViewTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped))
        let dateViewTap = UITapGestureRecognizer(target: self, action: #selector(dateTapped))
        let categoryViewTap = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        
        nameView.addGestureRecognizer(nameViewTap)
        amountView.addGestureRecognizer(amountViewTap)
        dateView.addGestureRecognizer(dateViewTap)
        categoryView.addGestureRecognizer(categoryViewTap)
        
        
        addToolBarToNumberPad(textField: transactionAmountTextField)
        
        
        
        // MARK: Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
        
        budget.sortCategoriesByKey(withUnallocated: true)
        
        addCircleAroundButton(named: submitTransactionButton)
        
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        updateTransactionButtonBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
        
        self.transactionNameTextField.delegate = self
        self.transactionAmountTextField.delegate = self
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        budget.sortCategoriesByKey(withUnallocated: true)
        
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        updateTransactionButtonBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
    }
    
    

    
}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension AddOrEditTransactionViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    
    
    
}


















