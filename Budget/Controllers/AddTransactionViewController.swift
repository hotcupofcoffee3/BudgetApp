//
//  AddTransactionViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/20/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddTransactionViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var transactionSelection = TransactionType.withdrawal
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        transactionNameTextField.resignFirstResponder()
        transactionAmountTextField.resignFirstResponder()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    @IBOutlet weak var transactionSegmentedControl: UISegmentedControl!
    
    @IBAction func transactionSelected(_ sender: UISegmentedControl) {
        
        if transactionSegmentedControl.selectedSegmentIndex == 0 {
            
            transactionSelection = .withdrawal
            
            updatePickerBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
            
        } else if transactionSegmentedControl.selectedSegmentIndex == 1 {
            
            transactionSelection = .deposit
            
            updatePickerBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
            
        }
        
    }
    
    func updatePickerBasedOnTransactionChoice(typeOfTransaction: TransactionType) {
        
        if typeOfTransaction == .withdrawal {
            
            addTransactionButtonTitle.setTitle("Add Withdrawal", for: .normal)
            
            categoryPicked.isUserInteractionEnabled = true
            categoryPicked.alpha = 1.0
            
        } else if typeOfTransaction == .deposit {
            
            addTransactionButtonTitle.setTitle("Add Deposit", for: .normal)
            
            categoryPicked.isUserInteractionEnabled = false
            
            guard let unallocatedIndex = budget.sortedCategoryKeys.index(of: unallocatedKey) else { return }

            categoryPicked.selectRow(unallocatedIndex, inComponent: 0, animated: true)
            
            updateCurrentCategoryBalanceLabel(forCategory: unallocatedKey)
            
            categoryPicked.alpha = 0.5
            
        }
        
    }
    
    
    // MARK: Update labels
    
    func updateLeftLabelAtTopRight() {
<<<<<<< HEAD
        if let uncategorized = budget.categories[uncategorizedKey] {
            leftAmountAtTopRight.text = "Left: $\(String(format: doubleFormatKey, uncategorized.available))"
        }
=======
        guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
        leftAmountAtTopRight.text = "Unallocated: \(convertedAmountToDollars(amount: unallocated.available))"
        
        budget.updateBalance()
        leftLabelOnNavBar.title = "\(convertedAmountToDollars(amount: budget.balance))"
>>>>>>> switchToCoreData
    }
    
    func updateCurrentCategoryBalanceLabel(forCategory categoryName: String) {
        
        if let selectedCategory = loadSpecificCategory(named: categoryName) {
            currentCategoryBalanceLabel.text = "Left: \(convertedAmountToDollars(amount: selectedCategory.available))"
        }
        
    }
    
    
    
    // MARK: Update elements because of success
    
    func updateUIElementsBecauseOfSuccess(forCategory category: String) {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Update Left label at top right & current balance
        updateLeftLabelAtTopRight()
        updateCurrentCategoryBalanceLabel(forCategory: category)
        
        // Clearing text fields
        transactionNameTextField.text = nil
        transactionAmountTextField.text = nil
        
    }
    
    // MARK: Failure message
    
    func failureWithWarning(message: String) {
        
        // Warning notification haptic
        let warning = UINotificationFeedbackGenerator()
        warning.notificationOccurred(.error)
        
        warningLabel.textColor = UIColor.red
        warningLabel.text = message
        
    }
    
    @IBOutlet weak var transactionNameTextField: UITextField!
    
    @IBOutlet weak var transactionAmountTextField: UITextField!
    
    
    //MARK:  Date Picker
    
    @IBOutlet weak var transactionDatePicker: UIDatePicker!
    
    @IBAction func changeDateOnPicker(_ sender: UIDatePicker) {
        
        transactionNameTextField.resignFirstResponder()
        transactionAmountTextField.resignFirstResponder()
        
    }
    
    
    //MARK:  Category Picker
    
    @IBOutlet weak var categoryPicked: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return budget.sortedCategoryKeys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return budget.sortedCategoryKeys[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        transactionNameTextField.resignFirstResponder()
        transactionAmountTextField.resignFirstResponder()
        
        let categorySelected = budget.sortedCategoryKeys[row]
        
        updateCurrentCategoryBalanceLabel(forCategory: categorySelected)
    }
    
    @IBOutlet weak var currentCategoryBalanceLabel: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    
    
    
    
    // MARK: Add Transaction Check
    
    
    // Error Check
    
    func submitAddTransactionForReview() {
        
        if let title = transactionNameTextField.text, let amount = transactionAmountTextField.text {
            
            let date = transactionDatePicker.date
            
            let categoryIndexFromSelectedPickerRow = categoryPicked.selectedRow(inComponent: 0)
            
            let categoryName = budget.sortedCategoryKeys[categoryIndexFromSelectedPickerRow]
            
            let convertedDates = convertDateToInts(dateToConvert: date)
            
            if title == "" || amount == "" {
                
                failureWithWarning(message: "You have to fill in all fields.")
                
            } else {
                
                if let amount = Double(amount), let year = convertedDates[yearKey], let month = convertedDates[monthKey], let day = convertedDates[dayKey] {
                    
                    // MARK: Withdrawal
                    
                    if transactionSelection == .withdrawal {
                        
                        guard let categoryBeingWithdrawnFrom = loadSpecificCategory(named: categoryName) else { return }
                        
                        if (categoryBeingWithdrawnFrom.available - amount) < 0 {
                            
                            failureWithWarning(message: "You don't have enough funds in this category.")
                            
                        } else if amount <= 0 {
                            
<<<<<<< HEAD
                            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                
                                budget.addTransaction(type: TransactionType.deposit, title: title, forCategory: uncategorizedKey, inTheAmountOf: amount, year: year, month: month, day: day)
                                
                                self.warningLabel.textColor = successColor
                                self.warningLabel.text = "$\(String(format: doubleFormatKey, amount)) was deposited."
                                
                                self.updateUIElementsBecauseOfSuccess(forCategory: uncategorizedKey)
                                
                            }))
=======
                            failureWithWarning(message: "You have to enter a number greater than 0.")
>>>>>>> switchToCoreData
                            
                        } else {
                            
                            showAlertToConfirmTransaction(type: .withdrawal, title: title, amount: amount, categoryName: categoryName, year: year, month: month, day: day)
                            
                        }
                        
                        
                        // MARK: Deposit - Only can deposit into 'Uncategorized' category
                    } else if transactionSelection == .deposit {
                        
                        if amount <= 0 {
                            
                            failureWithWarning(message: "You have to enter a number greater than 0.")
                            
                        } else {
                            
                            showAlertToConfirmTransaction(type: .deposit, title: title, amount: amount, categoryName: unallocatedKey, year: year, month: month, day: day)
                            
                        }
                        
                    }
                    
                } else {
                    
                    failureWithWarning(message: "You have to enter a number for the amount.")
                    
                }
                
            }
            
        }
        
    }
    
    
    // Alert Confirmation
    
    func showAlertToConfirmTransaction(type: TransactionType, title: String, amount: Double, categoryName: String, year: Int, month: Int, day: Int) {
        
        transactionNameTextField.resignFirstResponder()
        transactionAmountTextField.resignFirstResponder()
        
        if type == .withdrawal {
            
            let alert = UIAlertController(title: nil, message: "Make a withdrawal called \"\(title)\" in the amount of \(self.convertedAmountToDollars(amount: amount))?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                budget.addTransaction(type: TransactionType.withdrawal, title: title, forCategory: categoryName, inTheAmountOf: amount, year: year, month: month, day: day)
                
                self.warningLabel.textColor = successColor
                self.warningLabel.text = "\(self.convertedAmountToDollars(amount: amount)) withdrawn from \(categoryName)"
                
                self.updateUIElementsBecauseOfSuccess(forCategory: categoryName)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        } else if type == .deposit {
            
            let alert = UIAlertController(title: nil, message: "Deposit \"\(title)\" in the amount of \(self.convertedAmountToDollars(amount: amount))?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                budget.addTransaction(type: TransactionType.deposit, title: title, forCategory: unallocatedKey, inTheAmountOf: amount, year: year, month: month, day: day)
                
                self.warningLabel.textColor = successColor
                self.warningLabel.text = "\(self.convertedAmountToDollars(amount: amount)) was deposited."
                
                self.updateUIElementsBecauseOfSuccess(forCategory: unallocatedKey)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    
    
    @IBOutlet weak var addTransactionButtonTitle: UIButton!
    
    @IBAction func addTransaction(_ sender: UIButton) {
        
        submitAddTransactionForReview()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
<<<<<<< HEAD
        budget.sortCategoriesByKey(withUncategorized: true)
=======
        
        
        
        // MARK: - Add done button
            
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor.black
        
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.dismissNumberKeyboard))
        doneButton.tintColor = UIColor.white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        transactionAmountTextField.inputAccessoryView = toolbar

        
        
        // MARK: - Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
        
        
        
        
        budget.sortCategoriesByKey(withUnallocated: true)
>>>>>>> switchToCoreData
        
        addTransactionButtonTitle.layer.cornerRadius = 18
        addTransactionButtonTitle.layer.masksToBounds = true
        
        updateLeftLabelAtTopRight()
        updateCurrentCategoryBalanceLabel(forCategory: budget.sortedCategoryKeys[0])
        updatePickerBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
        
        self.transactionNameTextField.delegate = self
        self.transactionAmountTextField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
<<<<<<< HEAD
        budget.sortCategoriesByKey(withUncategorized: true)
=======
        budget.sortCategoriesByKey(withUnallocated: true)
>>>>>>> switchToCoreData
        categoryPicked.reloadAllComponents()
        
        updateLeftLabelAtTopRight()
        updateCurrentCategoryBalanceLabel(forCategory: budget.sortedCategoryKeys[0])
        updatePickerBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: - Keyboard dismissals
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
    
    @objc func dismissNumberKeyboard() {
        
        submissionFromKeyboardReturnKey(specificTextField: transactionAmountTextField)
        
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
    
}














