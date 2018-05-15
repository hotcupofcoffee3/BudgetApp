//
//  AddOrEditTransactionViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/20/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddOrEditTransactionViewController: UIViewController, UITextFieldDelegate, ChooseDate, ChooseCategory {
    
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var isNewTransaction = true
    
    var editableTransaction: Transaction?
    
    var transactionSelection = TransactionType.withdrawal
    
    var date = Date()
    
    var dateFormatYYYYMMDD = Int()
    
    
    
    // *****
    // MARK: - Header for Add & Main Edit Views
    // *****
    
    // *** IBOutlets
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var submitTransactionButton: UIButton!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    
    
    // *** IBActions
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitTransaction(_ sender: UIButton) {
        
        if isNewTransaction {
            
            submitAddTransactionForReview()
            
        } else {
            
            submitEditItemsForReview()
            
        }
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        budget.sortCategoriesByKey(withUnallocated: true)
        
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        updateTransactionButtonBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
    }
    
    
    
    
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
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
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
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
    // MARK: - Functions
    // *****
   
    
    // Update elements because of success
    
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
    
    
    
    
    
    
    
    
    
    
    
    
    // ********************************************************************************
    
    // ***** If this is a new transaction, the old check is all that is needed.
    
    // *** Add Transaction Check
    
    // Error Check
    
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
    
    

    
    
    // ****************************************************************************************
    // ****************************************************************************************
    
    
    /*
     
     The checks are going to see if anything doesn't match, and then if there is a problem that specific one is going to be dealt with from the top down.
     
     Then, once all safety checks have been passed, the alert confirmation is going to present all of the information for the transaction, whether changed or not.
     
     Then, upon clicking "Yes" to confirm the changes, each item is going to be checked to see if it is different, and if it is, then it'll update; otherwise, it will skip and not worry about updating, as it will already be set to that value.
 
    */
    
    
    // ****************************************************************************************
    // ****************************************************************************************
    

    func submitEditItemsForReview() {
        
        submitEditNameForReview()
        
    }
    
    func showAlertToConfirmEdits() {
        
        // *** Add in all checks to see if something has been changed or not, then pop up alert message with specific items to update.
        // *** Alert only shows actual changes being made.
        
    }
    
    
    // ****************************************************************************************
    
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

    
    
    // ****************************************************************************************
    
    // ***** Edit Amount
    
    
    
    func submitEditAmountForReview() {
        
        guard let newAmountText = transactionAmountTextField.text else { return }
        
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
                
                submitEditDateForReview()
                
            }
            
        }
        
    }
    

    
    // ****************************************************************************************
    
    // ***** Edit Date
    
    
    
    func submitEditDateForReview() {
        
        let newDateDictionary = convertDateToInts(dateToConvert: date)
        guard let newMonth = newDateDictionary[monthKey] else { return }
        guard let newDay = newDateDictionary[dayKey] else { return }
        guard let newYear = newDateDictionary[yearKey] else { return }
        
        if currentTransaction.month == newMonth && currentTransaction.day == newDay && currentTransaction.year == newYear {
            
            failureWithWarning(label: warningLabel, message: "This is already the date.")
            
            
        } else {
            
            submitEditCategoryForReview()
            
        }
        
    }

    
    
    // ****************************************************************************************
    
    // ***** Edit Category
    
    
    
    func submitEditCategoryForReview() {
        
        guard let newSelectedCategoryName = categoryLabel.text else { return }
        guard let newCategoryItself = loadSpecificCategory(named: newSelectedCategoryName) else { return }
        
        if newSelectedCategoryName == currentTransaction.forCategory {
            
            failureWithWarning(label: warningLabel, message: "The category is already set to \(newSelectedCategoryName)")

            
        } else if currentTransaction.inTheAmountOf > newCategoryItself.available {
            
            failureWithWarning(label: warningLabel, message: "There are not enough funds in that category for this transaction.")

            
        } else {
            
            showAlertToConfirmEdits()
            
        }
        
    }

    
    
    // ****************************************************************************************
    
    
    
    

    
    
    
    
    
    
    
    
    
    
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
    // MARK: - Keyboard functions
    // *****
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func submissionFromKeyboardReturnKey(specificTextField: UITextField) {
        
        if transactionNameTextField.text != "" && transactionAmountTextField.text != "" {
            
            submitAddTransactionForReview()
            
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
    
    
  
    
   
    
}


















