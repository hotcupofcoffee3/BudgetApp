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
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
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
        guard let unallocated = budget.categories[unallocatedKey] else { return }
        leftAmountAtTopRight.text = "Unallocated: $\(String(format: doubleFormatKey, unallocated.available))"
        leftLabelOnNavBar.title = "$\(String(format: doubleFormatKey, budget.balance))"
    }
    
    func updateCurrentCategoryBalanceLabel(forCategory categoryName: String) {
        
        if let selectedCategory = budget.categories[categoryName] {
            currentCategoryBalanceLabel.text = "Left: $\(String(format: doubleFormatKey, selectedCategory.available))"
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
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = NSAttributedString(string: budget.sortedCategoryKeys[row], attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        transactionNameTextField.resignFirstResponder()
        transactionAmountTextField.resignFirstResponder()
        
        let categorySelected = budget.sortedCategoryKeys[row]
        
        updateCurrentCategoryBalanceLabel(forCategory: categorySelected)
    }
    
    @IBOutlet weak var currentCategoryBalanceLabel: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var addTransactionButtonTitle: UIButton!
    
    @IBAction func addTransaction(_ sender: UIButton) {
        
        transactionNameTextField.resignFirstResponder()
        transactionAmountTextField.resignFirstResponder()
        
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
                        
                        guard let categoryBeingWithdrawnFrom = budget.categories[categoryName] else { return }
                        
                        if (categoryBeingWithdrawnFrom.available - amount) < 0 {
                            
                            failureWithWarning(message: "You don't have enough funds in this category.")
                            
                        } else if amount <= 0 {
                            
                            failureWithWarning(message: "You have to enter a number greater than 0.")
                            
                        } else {
                            
                            let alert = UIAlertController(title: nil, message: "Make a withdrawal called \"\(title)\" in the amount of $\(String(format: doubleFormatKey, amount))?", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                
                                budget.addTransaction(type: TransactionType.withdrawal, title: title, forCategory: categoryName, inTheAmountOf: amount, year: year, month: month, day: day)
                                
                                self.warningLabel.textColor = successColor
                                self.warningLabel.text = "$\(String(format: doubleFormatKey, amount)) withdrawn from \(categoryName)"
                                
                                self.updateUIElementsBecauseOfSuccess(forCategory: categoryName)
                                
                            }))
                            
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            
                            present(alert, animated: true, completion: nil)
                            
                        }
                        
                        
                    // MARK: Deposit - Only can deposit into 'Uncategorized' category
                    } else if transactionSelection == .deposit {
                        
                        if amount <= 0 {
                            
                            failureWithWarning(message: "You have to enter a number greater than 0.")
                            
                        } else {
                            
                            let alert = UIAlertController(title: nil, message: "Deposit \"\(title)\" in the amount of $\(String(format: doubleFormatKey, amount))?", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                
                                budget.addTransaction(type: TransactionType.deposit, title: title, forCategory: unallocatedKey, inTheAmountOf: amount, year: year, month: month, day: day)
                                
                                self.warningLabel.textColor = successColor
                                self.warningLabel.text = "$\(String(format: doubleFormatKey, amount)) was deposited."
                                
                                self.updateUIElementsBecauseOfSuccess(forCategory: unallocatedKey)
                                
                            }))
                            
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            
                            present(alert, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                } else {
                    
                    failureWithWarning(message: "You have to enter a number for the amount.")
                    
                }
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        budget.sortCategoriesByKey(withUnallocated: true)
        
        addTransactionButtonTitle.layer.cornerRadius = 27
        addTransactionButtonTitle.layer.masksToBounds = true
        addTransactionButtonTitle.layer.borderWidth = 1
        addTransactionButtonTitle.layer.borderColor = lightGreenColor.cgColor
        
        updateLeftLabelAtTopRight()
        updateCurrentCategoryBalanceLabel(forCategory: budget.sortedCategoryKeys[0])
        updatePickerBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
        
        self.transactionNameTextField.delegate = self
        self.transactionAmountTextField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        budget.sortCategoriesByKey(withUnallocated: true)
        categoryPicked.reloadAllComponents()
        
        updateLeftLabelAtTopRight()
        updateCurrentCategoryBalanceLabel(forCategory: budget.sortedCategoryKeys[0])
        updatePickerBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // Keyboard dismissals
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
