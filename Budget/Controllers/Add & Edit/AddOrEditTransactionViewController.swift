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
    
    var isAddingNewItem = true
    
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
    
    @IBOutlet weak var addTransactionButtonTitle: UIButton!
    
    
    
    // *** IBActions
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTransaction(_ sender: UIButton) {
        submitAddTransactionForReview()
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .short
        
        dateLabel.text = dateFormat.string(from: Date())
        
        if let category = selectedCategory {
            
            categoryLabel.text = category
            
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
        
        addCircleAroundButton(named: addTransactionButtonTitle)
        
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        updateAddTransactionButtonBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
        
        self.transactionNameTextField.delegate = self
        self.transactionAmountTextField.delegate = self
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        budget.sortCategoriesByKey(withUnallocated: true)
        
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        updateAddTransactionButtonBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
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
        
        if transactionSegmentedControl.selectedSegmentIndex == 0 {
            
            transactionSelection = .withdrawal
            
            updateAddTransactionButtonBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
            
        } else if transactionSegmentedControl.selectedSegmentIndex == 1 {
            
            transactionSelection = .deposit
            
            updateAddTransactionButtonBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Functions
    // *****
   
    
    // Update elements because of success
    
    func updateUIElementsBecauseOfSuccess(forCategory category: String) {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Clearing text fields
        transactionNameTextField.text = nil
        transactionAmountTextField.text = nil
        
    }
    
    func updateAddTransactionButtonBasedOnTransactionChoice(typeOfTransaction: TransactionType) {
        
        if typeOfTransaction == .withdrawal {
            
            addTransactionButtonTitle.setTitle("Add Withdrawal", for: .normal)
            categoryLabel.isEnabled = true
            
        } else if typeOfTransaction == .deposit {
            
            addTransactionButtonTitle.setTitle("Add Deposit", for: .normal)
            
            categoryLabel.text = unallocatedKey
            categoryLabel.isEnabled = false
            
        }
        
    }
    
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
    
    
    
    
    
    
    
    
    
    // ****************************************************************************************
    
    
    
    
    
    
    
    
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
    
    
    
    
    
    
    
    // ****************************************************************************************
    
    
    
    
    
    
    
    
    
    func showAlertToConfirmUpdate(date: Date, newMonth: Int, newDay: Int, newYear: Int) {
        
        // *** Alert message to pop up to confirmation
        
        let alert = UIAlertController(title: nil, message: "Change transaction date to \(newMonth)/\(newDay)/\(newYear)?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            guard let updatedTransaction = loadSpecificTransaction(idSubmitted: editableTransactionID) else { return }
            
            guard let oldTransactionIndex = budget.transactions.index(of: updatedTransaction) else { return }
            
            budget.updateTransactionDate(newDate: date, withID: Int(updatedTransaction.id), atIndex: oldTransactionIndex)
            
            self.successHaptic()
            
            budget.sortTransactionsDescending()
            
            editableTransactionID = budget.mostRecentidFromAddedTransaction
            
            self.editingItemLabel.text = "\(newMonth)/\(newDay)/\(newYear)"
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func changeDateSubmittedForReview () {
        
        let newDateDictionary = convertDateToInts(dateToConvert: date)
        guard let newMonth = newDateDictionary[monthKey] else { return }
        guard let newDay = newDateDictionary[dayKey] else { return }
        guard let newYear = newDateDictionary[yearKey] else { return }
        
        if currentTransaction.month == newMonth && currentTransaction.day == newDay && currentTransaction.year == newYear {
            
            failureWithWarning(label: warningLabel, message: "This is already the date.")
            
        } else {
            
            showAlertToConfirmUpdate(date: date, newMonth: newMonth, newDay: newDay, newYear: newYear)
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    // ****************************************************************************************
    
    
    
    
    
    
    
    func showAlertToConfirmUpdate(newCategoryName: String) {
        
        // *** Alert message to pop up to confirmation
        
        let alert = UIAlertController(title: nil, message: "Change transaction category from \"\(currentTransaction.forCategory!)\" to \"\(newCategoryName)\"?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            guard let updatedTransaction = loadSpecificTransaction(idSubmitted: editableTransactionID) else { return }
            
            budget.updateTransactionCategory(category: newCategoryName, withID: Int(updatedTransaction.id))
            
            self.successHaptic()
            
            budget.sortTransactionsDescending()
            
            self.editingItemLabel.text = updatedTransaction.forCategory
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func changeCategorySubmittedForReview () {
        
        guard let newSelectedCategoryName = categoryLabel.text else { return }
        guard let newCategoryItself = loadSpecificCategory(named: newSelectedCategoryName) else { return }
        
        if newSelectedCategoryName == currentTransaction.forCategory {
            
            failureWithWarning(label: warningLabel, message: "The category is already set to \(newSelectedCategoryName)")
            
        } else if currentTransaction.inTheAmountOf > newCategoryItself.available {
            
            failureWithWarning(label: warningLabel, message: "There are not enough funds in that category for this transaction.")
            
        } else {
            
            showAlertToConfirmUpdate(newCategoryName: newSelectedCategoryName)
            
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
        
        performSegue(withIdentifier: addTransactionToDatePickerSegueKey, sender: self)
        
    }
    
    @objc func categoryTapped() {
        
        if transactionSelection == .withdrawal {
            
            performSegue(withIdentifier: addTransactionToCategoryPickerSegueKey, sender: self)
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == addTransactionToDatePickerSegueKey {
            
            let datePickerVC = segue.destination as! DatePickerViewController
            
            datePickerVC.delegate = self
            
            datePickerVC.date = date
            
        } else if segue.identifier == addTransactionToCategoryPickerSegueKey {
            
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


















