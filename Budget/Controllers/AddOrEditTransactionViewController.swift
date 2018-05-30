//
//  AddOrEditTransactionViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/20/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddOrEditTransactionViewController: UIViewController, UITextFieldDelegate, ChooseDate, ChooseCategory, ChoosePaycheck {
    
    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - Declared
    // *****
    
    var isNewTransaction = true
    
    var editableTransaction: Transaction?
    
    var transactionSelection = TransactionType.withdrawal
    
    var date = Date()
    
    var dateFormatYYYYMMDD = Int()
    
    
    
    // *****
    // MARK: - IBOutlets
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
    
    @IBOutlet weak var paycheckTitleLabel: UILabel!
    
    @IBOutlet weak var paycheckLabel: UILabel!
    
    @IBOutlet weak var paycheckView: UIView!
    
    @IBOutlet weak var paycheckViewHeight: NSLayoutConstraint!
    
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - General Functions
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
                transactionNameTextField.text = ""
                transactionAmountTextField.text = ""
                categoryLabel.isEnabled = true
                
                if !budget.paychecks.isEmpty {
                    
                    paycheckLabel.isEnabled = false
                    
                    UIView.animate(withDuration: 0.3) {
                        self.paycheckViewHeight.constant = 0
                        self.view.layoutIfNeeded()
                    }
                    
                    paycheckTitleLabel.text = ""
                    paycheckLabel.text = ""
                    
                }
                
            } else if typeOfTransaction == .deposit {
                
                submitTransactionButton.setTitle("Add Deposit", for: .normal)
                
                categoryLabel.text = unallocatedKey
                categoryLabel.isEnabled = false
                
                if !budget.paychecks.isEmpty {
                    
                    paycheckLabel.isEnabled = true
                    
                    UIView.animate(withDuration: 0.3) {
                        self.paycheckViewHeight.constant = 50
                        self.view.layoutIfNeeded()
                    }
                    
                    paycheckTitleLabel.text = "Paycheck?"
                    paycheckLabel.text = "Click to select"
                    
                }
                
            }
            
        }
        
    }
    
    
    
    // *****
    // MARK: - IBActions
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
    // MARK: - Submissions
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
            
            let periods = loadSavedBudgetedTimeFrames()
            
            let dateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: date, isEnd: false)
            
            var dateIsInAPeriod = false
            
            for period in periods {
                
                if dateAsPeriodID > period.startDateID && dateAsPeriodID < period.endDateID {
                    
                    dateIsInAPeriod = true
                    
                }
                
            }
            
            if !dateIsInAPeriod {
                
                failureWithWarning(label: warningLabel, message: "The date you chose is not in a Budget Period.")
                
            } else if let amount = Double(amount), let year = convertedDates[yearKey], let month = convertedDates[monthKey], let day = convertedDates[dayKey] {
                
                // MARK: Withdrawal
                
                if transactionSelection == .withdrawal {
                    
                    guard let categoryBeingWithdrawnFrom = loadSpecificCategory(named: category) else { return }
                    
                    if (categoryBeingWithdrawnFrom.budgeted - amount) < 0 {
                        
                        failureWithWarning(label: warningLabel, message: "You don't have enough funds in this category.")
                        
                    } else if amount <= 0 {
                        
                        failureWithWarning(label: warningLabel, message: "You have to enter a number greater than 0.")
                        
                    } else {
                        
                        addTransactionSubmission(fullDate: date, type: .withdrawal, title: title, amount: amount, categoryName: category, year: year, month: month, day: day)
                        
                    }
                    
                    
                    // MARK: Deposit - Only can deposit into 'Uncategorized' category
                } else if transactionSelection == .deposit {
                    
                    if amount <= 0 {
                        
                        failureWithWarning(label: warningLabel, message: "You have to enter a number greater than 0.")
                        
                    } else {
                        
                        addTransactionSubmission(fullDate: date, type: .deposit, title: title, amount: amount, categoryName: unallocatedKey, year: year, month: month, day: day)
                        
                    }
                    
                }
                
            } else {
                
                failureWithWarning(label: warningLabel, message: "You have to enter a number for the amount.")
                
            }
            
        }
        
    }
    
    
    // Add Transaction Submission
    
    func addTransactionSubmission(fullDate: Date, type: TransactionType, title: String, amount: Double, categoryName: String, year: Int, month: Int, day: Int) {
        
        transactionNameTextField.resignFirstResponder()
        transactionAmountTextField.resignFirstResponder()
        
        if type == .withdrawal {
            
            var onHold = false
            
            if self.holdToggle.isOn {
                
                onHold = true
                
            }
            
            budget.addTransaction(onHold: onHold, type: TransactionType.withdrawal, title: title, forCategory: categoryName, inTheAmountOf: amount, year: year, month: month, day: day)
            
            warningLabel.textColor = successColor
            warningLabel.text = "\(convertedAmountToDollars(amount: amount)) withdrawn from \(categoryName)"
            
            successHaptic()
            
            updateUIElementsBecauseOfSuccess(forCategory: categoryName)
            updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
            
        } else if type == .deposit {
            
                var onHold = false
                
                if self.holdToggle.isOn {
                    
                    onHold = true
                    
                }
                
                budget.addTransaction(onHold: onHold, type: TransactionType.deposit, title: title, forCategory: unallocatedKey, inTheAmountOf: amount, year: year, month: month, day: day)
                
                warningLabel.textColor = successColor
                warningLabel.text = "\(convertedAmountToDollars(amount: amount)) was deposited."
                
                successHaptic()
                
                updateUIElementsBecauseOfSuccess(forCategory: unallocatedKey)
                updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
            
        }
        
    }
    

    
    // **************************************
    // ***** Edit Transaction
    // **************************************
    
    
    
    func submitEditItemsForReview() {
        
        // The 'else' on this leads to the next 'submit' check, and so on, until the end, in which case the 'else' calls the 'showAlertToConfirmEdits' function.
        submitEditNameForReview()
        
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
                
                
            } else if newAmount > (currentTransaction.inTheAmountOf + currentCategory.budgeted) && currentTransaction.type == withdrawalKey {
                
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
        
        if currentTransaction.inTheAmountOf > newCategoryItself.budgeted && currentTransaction.type == withdrawalKey {
            
            failureWithWarning(label: warningLabel, message: "There are not enough funds in that category for this transaction.")
            
            
        } else {
            
            editSubmission()
            
        }
        
    }
    
    
    
    func editSubmission() {
        
        // *** Add in all checks to see if something has been changed or not, then pop up alert message with specific items to update.
        // *** Alert only shows actual changes being made.
        
        guard let currentTransaction = editableTransaction else { return }
       
        
        // Title
        guard let newTitle = transactionNameTextField.text else { return }
        var changeTitle = false
        if newTitle != currentTransaction.title {
            changeTitle = true
        }
        
        
        // Amount
        guard let newAmount = Double(transactionAmountTextField.text!) else { return }
        var changeAmount = false
        if newAmount != currentTransaction.inTheAmountOf {
            changeAmount = true
        }
        
        
        // Date
        let newDate = date
        var changeDate = false
        
        let currentDate = convertComponentsToDate(year: Int(currentTransaction.year), month: Int(currentTransaction.month), day: Int(currentTransaction.day))
        
        if newDate != currentDate {
            changeDate = true
        }
        
        
        // Category
        guard let newCategory = categoryLabel.text else { return }
        var changeCategory = false
        if newCategory != currentTransaction.forCategory {
            changeCategory = true
        }
        
        
        // On Hold
        let newHoldStatus = holdToggle.isOn
        var changeHoldStatus = false
        if newHoldStatus != currentTransaction.onHold {
            changeHoldStatus = true
        }
        
        if !changeTitle && !changeAmount && !changeDate && !changeCategory && !changeHoldStatus {
            
            failureWithWarning(label: warningLabel, message: "There is nothing to update.")
            
        } else {
            
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
            
            successHaptic()
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Delegates
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
    
    func setPaycheck(paycheck: Paycheck) {
        paycheckLabel.text = paycheck.name!
        transactionNameTextField.text = paycheck.name!
        transactionAmountTextField.text = "\(String(format: "%0.2f", paycheck.amount))"
    }
    
    
    
    // *****
    // MARK: - Segues
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
            
            categoryPickerVC.categoryList = budget.sortedCategoryKeys
            
            categoryPickerVC.selectedCategory = currentCategory
            
        } else if segue.identifier == addOrEditTransactionToPaycheckPickerSegueKey {
            
            let paycheckPickerVC = segue.destination as! PaycheckPickerViewController
            
            paycheckPickerVC.delegate = self
            
            if paycheckLabel.text != "Click to select" {
                
                guard let paycheck = loadSpecificPaycheck(named: paycheckLabel.text!) else { return }
                
                paycheckPickerVC.selectedPaycheck = paycheck
                
            } else {
                
                if budget.paychecks.count > 0 {
                    
                    paycheckPickerVC.selectedPaycheck = budget.paychecks[0]
                    
                }
                
            }
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Tap Functions
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
    
    @objc func paycheckTapped() {
        
        if transactionSelection == .deposit {
            
            performSegue(withIdentifier: addOrEditTransactionToPaycheckPickerSegueKey, sender: self)
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
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
        
        self.paycheckViewHeight.constant = 0
        
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
            
            paycheckTitleLabel.text = ""
            paycheckLabel.text = ""
            
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
            paycheckLabel.isEnabled = (transactionSelection == .deposit)
            
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
        let paycheckViewTap = UITapGestureRecognizer(target: self, action: #selector(paycheckTapped))
        
        nameView.addGestureRecognizer(nameViewTap)
        amountView.addGestureRecognizer(amountViewTap)
        dateView.addGestureRecognizer(dateViewTap)
        categoryView.addGestureRecognizer(categoryViewTap)
        paycheckView.addGestureRecognizer(paycheckViewTap)
        
        
        addToolBarToNumberPad(textField: transactionAmountTextField)
        
        
        
        // MARK: Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
        
        budget.sortCategoriesByKey(withUnallocated: true)
        loadSavedPaychecks()
        
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


















