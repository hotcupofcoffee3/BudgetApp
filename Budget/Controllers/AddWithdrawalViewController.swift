//
//  AddWithdrawalViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddWithdrawalViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        withdrawalNameTextField.resignFirstResponder()
        withdrawalAmountTextField.resignFirstResponder()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    func updateLeftLabelAtTopRight() {
        if let uncategorized = budget.categories[uncategorizedKey] {
            leftAmountAtTopRight.text = "Left: $\(String(format: doubleFormatKey, uncategorized.available))"
        }
    }
    
    func updateCurrentCategoryBalanceLabel(for categoryName: String) {
        
        if let selectedCategory = budget.categories[categoryName] {
            currentCategoryBalanceLabel.text = "Current left: $\(String(format: doubleFormatKey, selectedCategory.available))"
        }
        
    }

    @IBOutlet weak var withdrawalNameTextField: UITextField!
    
    @IBOutlet weak var withdrawalAmountTextField: UITextField!
    
    
    // Date Picker
    
    @IBOutlet weak var withdrawalDatePicker: UIDatePicker!
    
    @IBAction func changeDateOnPicker(_ sender: UIDatePicker) {
        
        withdrawalNameTextField.resignFirstResponder()
        withdrawalAmountTextField.resignFirstResponder()
        
    }
    
    
    // Category Picker
    
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
        
        withdrawalNameTextField.resignFirstResponder()
        withdrawalAmountTextField.resignFirstResponder()
        
        let categorySelected = budget.sortedCategoryKeys[row]
        
        updateCurrentCategoryBalanceLabel(for: categorySelected)
    }
    
    @IBOutlet weak var currentCategoryBalanceLabel: UILabel!
    
    @IBOutlet weak var withdrawalWarningLabel: UILabel!
    
    @IBAction func addWithdrawal(_ sender: UIButton) {
        
        withdrawalNameTextField.resignFirstResponder()
        withdrawalAmountTextField.resignFirstResponder()
        
        if let title = withdrawalNameTextField.text, let amount = withdrawalAmountTextField.text {
            
            let date = withdrawalDatePicker.date
            
            let categoryIndexFromSelectedPickerRow = categoryPicked.selectedRow(inComponent: 0)
            
            let category = budget.sortedCategoryKeys[categoryIndexFromSelectedPickerRow]
            
            let convertedDates = convertDateToInts(dateToConvert: date)
            
            if title == "" || amount == "" {
                
                // Warning notification haptic
                let warningHaptic = UINotificationFeedbackGenerator()
                warningHaptic.notificationOccurred(.error)
                
                withdrawalWarningLabel.textColor = UIColor.red
                withdrawalWarningLabel.text = "You have to fill in all fields."
                
            } else {
                
                if let amount = Double(amount), let year = convertedDates[yearKey], let month = convertedDates[monthKey], let day = convertedDates[dayKey] {
                    
                    guard let categoryBeingWithdrawnFrom = budget.categories[category] else { return }
                        
                    if (categoryBeingWithdrawnFrom.available - amount) < 0 {
                        
                        // Warning notification haptic
                        let warningHaptic = UINotificationFeedbackGenerator()
                        warningHaptic.notificationOccurred(.error)
                        
                        withdrawalWarningLabel.textColor = UIColor.red
                        withdrawalWarningLabel.text = "You don't have enough funds in this category."
                        
                    } else if amount <= 0 {
                        
                        // Warning notification haptic
                        let warningHaptic = UINotificationFeedbackGenerator()
                        warningHaptic.notificationOccurred(.error)
                        
                        withdrawalWarningLabel.textColor = UIColor.red
                        withdrawalWarningLabel.text = "You have to enter a number greater than 0."
                    } else {
                        
                        let alert = UIAlertController(title: nil, message: "Make a withdrawal called \"\(title)\" in the amount of \(String(format: doubleFormatKey, amount))?", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                            
                            budget.addTransaction(type: TransactionType.withdrawal, title: title, forCategory: category, inTheAmountOf: amount, year: year, month: month, day: day)
                            
                            self.withdrawalWarningLabel.textColor = successColor
                            self.withdrawalWarningLabel.text = "$\(String(format: doubleFormatKey, amount)) withdrawn from \(category)"
                            
                            // Success notification haptic
                            let successHaptic = UINotificationFeedbackGenerator()
                            successHaptic.notificationOccurred(.success)
                            
                            // Update Left label at top right & current balance
                            self.updateLeftLabelAtTopRight()
                            self.updateCurrentCategoryBalanceLabel(for: category)
                            
                            // Clearing text fields
                            self.withdrawalNameTextField.text = nil
                            self.withdrawalAmountTextField.text = nil
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        
                        present(alert, animated: true, completion: nil)
                    
                    }
                            
                } else {
                    
                    // Warning notification haptic
                    let warningHaptic = UINotificationFeedbackGenerator()
                    warningHaptic.notificationOccurred(.error)
                    
                    withdrawalWarningLabel.textColor = UIColor.red
                    withdrawalWarningLabel.text = "You have to enter a number for the amount."
                        
                }
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        budget.sortCategoriesByKey(withUncategorized: true)
        
        updateLeftLabelAtTopRight()
        updateCurrentCategoryBalanceLabel(for: budget.sortedCategoryKeys[0])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        budget.sortCategoriesByKey(withUncategorized: true)
        categoryPicked.reloadAllComponents()
        
        updateLeftLabelAtTopRight()
        updateCurrentCategoryBalanceLabel(for: budget.sortedCategoryKeys[0])
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
