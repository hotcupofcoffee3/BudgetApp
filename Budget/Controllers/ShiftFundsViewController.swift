//
//  ShiftFundsViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/13/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class ShiftFundsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        amountTextField.resignFirstResponder()
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    func updateLeftLabelAtTopRight() {
        if let uncategorized = budget.categories[uncategorizedKey] {
            leftAmountAtTopRight.text = "Left: $\(String(format: doubleFormatKey, uncategorized.available))"
        }
    }
    
    func updateCategoryBalanceLabel(for categoryName: String, atLabel: UILabel) {
        
        if let selectedCategory = budget.categories[categoryName] {
            atLabel.text = "Current: $\(String(format: doubleFormatKey, selectedCategory.available))"
        }
        
    }
    
    @IBOutlet weak var amountTextField: UITextField!
    
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
        
        amountTextField.resignFirstResponder()
        
        if pickerView.tag == 1 {
            
            let fromCategoryIndexSelected = fromCategoryPicker.selectedRow(inComponent: 0)
            let fromCategorySelected = budget.sortedCategoryKeys[fromCategoryIndexSelected]
            
            updateCategoryBalanceLabel(for: fromCategorySelected, atLabel: fromCategoryCurrentBalanceLabel)
            
        } else {
            
            let toCategoryIndexSelected = toCategoryPicker.selectedRow(inComponent: 0)
            let toCategorySelected = budget.sortedCategoryKeys[toCategoryIndexSelected]
            
            updateCategoryBalanceLabel(for: toCategorySelected, atLabel: toCategoryCurrentBalanceLabel)
            
        }
        
    }
    
    @IBOutlet weak var fromCategoryPicker: UIPickerView!
    
    @IBOutlet weak var toCategoryPicker: UIPickerView!
    
    @IBOutlet weak var fromCategoryCurrentBalanceLabel: UILabel!
    
    @IBOutlet weak var toCategoryCurrentBalanceLabel: UILabel!
    
    @IBOutlet weak var successLabel: UILabel!
    
    @IBAction func shiftFundsButton(_ sender: UIButton) {
        
        amountTextField.resignFirstResponder()
        
        let fromCategoryIndexSelected = fromCategoryPicker.selectedRow(inComponent: 0)
        let fromCategorySelected = budget.sortedCategoryKeys[fromCategoryIndexSelected]
        
        let toCategoryIndexSelected = toCategoryPicker.selectedRow(inComponent: 0)
        let toCategorySelected = budget.sortedCategoryKeys[toCategoryIndexSelected]
        
        guard let amountText = amountTextField.text else { return }
        
        if amountTextField.text == "" {
            
            // Warning notification haptic
            let warningHaptic = UINotificationFeedbackGenerator()
            warningHaptic.notificationOccurred(.error)
            
            successLabel.textColor = UIColor.red
            successLabel.text = "You have to enter an amount first."
            
        } else {
            
            if let amount = Double(amountText) {
                
                guard let fromCategory = budget.categories[fromCategorySelected] else { return }
                
                if (fromCategory.available - amount) < 0 {
                    
                    // Warning notification haptic
                    let warningHaptic = UINotificationFeedbackGenerator()
                    warningHaptic.notificationOccurred(.error)
                    
                    successLabel.textColor = UIColor.red
                    successLabel.text = "You don't enough to shift from this category."
                    
                } else if amount <= 0 {
                    
                    // Warning notification haptic
                    let warningHaptic = UINotificationFeedbackGenerator()
                    warningHaptic.notificationOccurred(.error)
                    
                    successLabel.textColor = UIColor.red
                    successLabel.text = "The amount has to be greater than 0."
                    
                } else {
                    
                    let alert = UIAlertController(title: nil, message: "Shift $\(String(format: doubleFormatKey, amount)) from \(fromCategorySelected) to \(toCategorySelected)?", preferredStyle: .alert)
                    
                    // Adds specified amount
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        
                        budget.removeFundsFromCategory(withThisAmount: amount, from: fromCategorySelected)
                        budget.allocateFundsToCategory(withThisAmount: amount, to: toCategorySelected)
                        
                        self.successLabel.textColor = successColor
                        self.successLabel.text = "$\(String(format: doubleFormatKey, amount)) shifted from \(fromCategorySelected) to \(toCategorySelected)"
                        
                        // Success notification haptic
                        let successHaptic = UINotificationFeedbackGenerator()
                        successHaptic.notificationOccurred(.success)
                        
                        // Update Left label at top right & balance labels
                        self.updateLeftLabelAtTopRight()
                        self.updateCategoryBalanceLabel(for: fromCategorySelected, atLabel: self.fromCategoryCurrentBalanceLabel)
                        self.updateCategoryBalanceLabel(for: toCategorySelected, atLabel: self.toCategoryCurrentBalanceLabel)
                        
                        // Clear text field
                        self.amountTextField.text = nil
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    present(alert, animated: true, completion: nil)
                    
                }
                
            } else {
                
                // Warning notification haptic
                let warningHaptic = UINotificationFeedbackGenerator()
                warningHaptic.notificationOccurred(.error)
                
                successLabel.textColor = UIColor.red
                successLabel.text = "You can't use letters for the amount."
                
            }
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        budget.sortCategoriesByKey(withUncategorized: true)
        updateLeftLabelAtTopRight()
        
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: fromCategoryCurrentBalanceLabel)
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: toCategoryCurrentBalanceLabel)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        budget.sortCategoriesByKey(withUncategorized: true)
//        categoryPicker.reloadAllComponents()
        updateLeftLabelAtTopRight()
        
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: fromCategoryCurrentBalanceLabel)
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: toCategoryCurrentBalanceLabel)
        
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
