//
//  MoveFundsViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/19/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class MoveFundsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    
    
    // MARK: Update labels
    
    func updateLeftLabelAtTopRight() {
        if let uncategorized = budget.categories[uncategorizedKey] {
            leftAmountAtTopRight.text = "Left: $\(String(format: doubleFormatKey, uncategorized.available))"
        }
    }
    
    func updateCategoryBalanceLabel(for categoryName: String, atLabel: UILabel) {
        
        if let selectedCategory = budget.categories[categoryName] {
            
            if categoryName == uncategorizedKey {
                
                atLabel.text = "Current: $\(String(format: doubleFormatKey, selectedCategory.available))"
                
            } else {
                
                atLabel.text = "Budgeted: $\(String(format: doubleFormatKey, selectedCategory.budgeted))\nCurrent: $\(String(format: doubleFormatKey, selectedCategory.available))"
                
            }
            
        }
        
    }
    
    
    
    // MARK: Update elements because of success
    
    func updateUIElementsBecauseOfSuccess(forFromCategory: String, forToCategory: String) {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Update Left label at top right & balance labels
        updateLeftLabelAtTopRight()
        updateCategoryBalanceLabel(for: forFromCategory, atLabel: fromCategoryCurrentBalanceLabel)
        updateCategoryBalanceLabel(for: forToCategory, atLabel: toCategoryCurrentBalanceLabel)
        
        // Clear text field
        fundsTextField.text = nil
        
    }
    
    // MARK:  Update for Move Funds Switch
    
    func updateUIForAllocate() {
        
        moveFundsButtonTitle.setTitle("Allocate Funds", for: .normal)
        
        // Disable picker 1 & enable picker 2
        
        toCategoryPicker.isUserInteractionEnabled = true
        toCategoryPicker.alpha = 1.0
        
        fromCategoryPicker.isUserInteractionEnabled = false
        fromCategoryPicker.alpha = 0.3
        
        
        // Set disabled 'from' picker to "Uncategorized"
        fromCategoryPicker.selectRow(0, inComponent: 0, animated: true)
        
        // Update 'from' balance label to 'Uncategorized'
        updateCategoryBalanceLabel(for: uncategorizedKey, atLabel: fromCategoryCurrentBalanceLabel)
        
    }
    
    func updateUIForRemove() {
        
        moveFundsButtonTitle.setTitle("Remove Funds", for: .normal)
        
        // Disable picker 2 & enable picker 1
        fromCategoryPicker.isUserInteractionEnabled = true
        fromCategoryPicker.alpha = 1.0
        
        toCategoryPicker.isUserInteractionEnabled = false
        toCategoryPicker.alpha = 0.3
        
        
        
        // Set disabled 'to' picker to 'Uncategorized'
        toCategoryPicker.selectRow(0, inComponent: 0, animated: true)
        
        // Update 'to' balance label to 'Uncategorized'
        updateCategoryBalanceLabel(for: uncategorizedKey, atLabel: toCategoryCurrentBalanceLabel)
        
    }
    
    func updateUIForShift() {
        
        moveFundsButtonTitle.setTitle("Shift Funds", for: .normal)
        
        // Enable both pickers
        fromCategoryPicker.isUserInteractionEnabled = true
        fromCategoryPicker.alpha = 1.0
        
        toCategoryPicker.isUserInteractionEnabled = true
        toCategoryPicker.alpha = 1.0
        
    }
    
    
    // MARK: Failure message
    
    func failureWithWarning(message: String) {
        
        // Warning notification haptic
        let warning = UINotificationFeedbackGenerator()
        warning.notificationOccurred(.error)
        
        warningLabel.textColor = UIColor.red
        warningLabel.text = message
        
    }
    
    
    // MARK: Allocate, Remove, or Shift Switch
    
    @IBOutlet weak var allocateRemoveOrShift: UISegmentedControl!
    
    @IBAction func allocateRemoveOrShiftSwitch(_ sender: UISegmentedControl) {
        
        if allocateRemoveOrShift.selectedSegmentIndex == 0 {
            
            updateUIForAllocate()
       
        } else if allocateRemoveOrShift.selectedSegmentIndex == 1 {
            
            updateUIForRemove()
        
        } else if allocateRemoveOrShift.selectedSegmentIndex == 2 {
           
            updateUIForShift()
       
        }
        
        fundsTextField.resignFirstResponder()
    }
    
    
    
    
    // MARK: Funds Text Field
    
    @IBOutlet weak var fundsTextField: UITextField!
    
    
    
    
    // MARK: Picker
    
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
        
        fundsTextField.resignFirstResponder()
        
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
    
    
    
    
    // MARK: From and To Labels
    
    @IBOutlet weak var fromCategoryCurrentBalanceLabel: UILabel!
    
    @IBOutlet weak var toCategoryCurrentBalanceLabel: UILabel!
    
    
    
    
    // MARK: Warning Label
    
    @IBOutlet weak var warningLabel: UILabel!
    
    
    
    
    // MARK: Funds Button
    
    @IBOutlet weak var moveFundsButtonTitle: UIButton!
    
    
    
    @IBAction func moveFundsButton(_ sender: UIButton) {
        
        fundsTextField.resignFirstResponder()
        
        if let amountFromTextField = fundsTextField.text {
            
            // *************************************
            
            // MARK: Allocate
            
            // *************************************
            
            if allocateRemoveOrShift.selectedSegmentIndex == 0 {
                
                let toCategorySelectedIndex = toCategoryPicker.selectedRow(inComponent: 0)
                let toCategorySelectedName = budget.sortedCategoryKeys[toCategorySelectedIndex]
                
                guard let selectedCategory = budget.categories[toCategorySelectedName] else { return }
                guard let uncategorizedCategory = budget.categories[uncategorizedKey] else { return }

                
                
                // Allocation submitted, with the amount being the default set budgeted amount
                if amountFromTextField == "" {

                    if (uncategorizedCategory.available - selectedCategory.budgeted) < 0 {
                        
                        failureWithWarning(message: "You don't have enough funds for that.")
                        
                    } else {
                        
                        let alert = UIAlertController(title: nil, message: "Allocate $\(String(format: doubleFormatKey, selectedCategory.budgeted)) to \(toCategorySelectedName)?", preferredStyle: .alert)
                        
                        // Success!!! Adds default amount
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                            
                            budget.allocateFundsToCategory(withThisAmount: selectedCategory.budgeted, to: toCategorySelectedName)
                            
                            self.warningLabel.textColor = successColor
                            self.warningLabel.text = "$\(String(format: doubleFormatKey, selectedCategory.budgeted)) allocated to \(toCategorySelectedName)"
                            
                            // Haptics triggered, labels updated, and text field cleared
                            self.updateUIElementsBecauseOfSuccess(forFromCategory: uncategorizedKey, forToCategory: toCategorySelectedName)
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        
                        present(alert, animated: true, completion: nil)
                        
                    }
                    
                    
                    
                // Allocation submitted, with the amount being specifically set
                } else if let amount = Double(amountFromTextField) {
                    
                    guard let uncategorizedCategory = budget.categories[uncategorizedKey] else { return }
                    
                    if (uncategorizedCategory.available - amount) < 0 {
                        
                        failureWithWarning(message: "You don't have enough funds left that.")
                        
                    } else if amount <= 0 {
                        
                        failureWithWarning(message: "The amount can't be negative.")
                        
                    } else {
                        
                        let alert = UIAlertController(title: nil, message: "Allocate $\(String(format: doubleFormatKey, amount)) to \(toCategorySelectedName)?", preferredStyle: .alert)
                        
                        // Success!!! Adds specified amount
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                            
                            budget.allocateFundsToCategory(withThisAmount: amount, to: toCategorySelectedName)
                            
                            self.warningLabel.textColor = successColor
                            self.warningLabel.text = "$\(String(format: doubleFormatKey, amount)) allocated to \(toCategorySelectedName)"
                            
                            // Haptics triggered, labels updated, and text field cleared
                            self.updateUIElementsBecauseOfSuccess(forFromCategory: uncategorizedKey, forToCategory: toCategorySelectedName)
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        
                        present(alert, animated: true, completion: nil)
                        
                    }
                    
                } else {
                    
                    failureWithWarning(message: "You can't have letters for the amount.")
                    
                }
                
                
                
              
            // *************************************
            
            // MARK: Remove
            
            // *************************************
                
            } else if allocateRemoveOrShift.selectedSegmentIndex == 1 {
                
                let fromCategorySelectedIndex = fromCategoryPicker.selectedRow(inComponent: 0)
                let fromCategorySelectedName = budget.sortedCategoryKeys[fromCategorySelectedIndex]
                
                guard let selectedCategory = budget.categories[fromCategorySelectedName] else { return }
                
                
                
                // Removal submitted, with the amount being the default set budgeted amount
                if amountFromTextField == "" {
                    
                    if (selectedCategory.available - selectedCategory.budgeted) < 0 {
                        
                        failureWithWarning(message: "Not enough funds in this category for that.")
                        
                    } else {
                            
                        let alert = UIAlertController(title: nil, message: "Remove $\(String(format: doubleFormatKey, selectedCategory.budgeted)) from \(fromCategorySelectedName)?", preferredStyle: .alert)
                        
                        // Success!!! Removes default amount
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                            
                            budget.removeFundsFromCategory(withThisAmount: selectedCategory.budgeted, from: fromCategorySelectedName)
                            
                            self.warningLabel.textColor = successColor
                            self.warningLabel.text = "$\(String(format: doubleFormatKey, selectedCategory.budgeted)) removed from \(fromCategorySelectedName)"
                            
                            // Haptics triggered, labels updated, and text field cleared
                            self.updateUIElementsBecauseOfSuccess(forFromCategory: fromCategorySelectedName, forToCategory: uncategorizedKey)
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        
                        present(alert, animated: true, completion: nil)
                        
                    }
                    
                    
                    
                    // Removal submitted, with the amount being specifically set
                } else if let amount = Double(amountFromTextField) {
                    
                    if (selectedCategory.available - amount) < 0 {
                        
                        failureWithWarning(message: "You don't have enough funds in there for that.")
                        
                    } else if amount <= 0 {
                        
                        failureWithWarning(message: "The amount has to be greater than 0.")
                        
                    } else {
                        
                        let alert = UIAlertController(title: nil, message: "Remove $\(String(format: doubleFormatKey, amount)) from \(fromCategorySelectedName)?", preferredStyle: .alert)
                        
                        // Success!!! Removes specified amount
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                            
                            budget.removeFundsFromCategory(withThisAmount: amount, from: fromCategorySelectedName)
                            
                            self.warningLabel.textColor = successColor
                            self.warningLabel.text = "$\(String(format: doubleFormatKey, amount)) removed from \(fromCategorySelectedName)"
                            
                            // Haptics triggered, labels updated, and text field cleared
                            self.updateUIElementsBecauseOfSuccess(forFromCategory: fromCategorySelectedName, forToCategory: uncategorizedKey)
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        
                        present(alert, animated: true, completion: nil)
                        
                    }
                    
                } else {
                    
                    failureWithWarning(message: "You can't have letters for the amount.")
                    
                }
                
                
                
                
                
            // *************************************
            
            // MARK: Shift
            
            // *************************************
                
            } else if allocateRemoveOrShift.selectedSegmentIndex == 2 {
                
                // Enable both pickers
                fromCategoryPicker.isUserInteractionEnabled = true
                toCategoryPicker.isUserInteractionEnabled = true
                
                
                let fromCategoryIndexSelected = fromCategoryPicker.selectedRow(inComponent: 0)
                let fromCategorySelectedName = budget.sortedCategoryKeys[fromCategoryIndexSelected]
                
                let toCategoryIndexSelected = toCategoryPicker.selectedRow(inComponent: 0)
                let toCategorySelectedName = budget.sortedCategoryKeys[toCategoryIndexSelected]
                
                
                if fundsTextField.text == "" {
                    
                    failureWithWarning(message: "You have to enter an amount first.")
                    
                } else {
                    
                    if let amount = Double(amountFromTextField) {
                        
                        guard let fromCategory = budget.categories[fromCategorySelectedName] else { return }
                        
                        if (fromCategory.available - amount) < 0 {
                            
                            failureWithWarning(message: "You don't enough to shift from this category.")
                            
                        } else if amount <= 0 {
                            
                            failureWithWarning(message: "The amount has to be greater than 0.")
                            
                        } else {
                            
                            let alert = UIAlertController(title: nil, message: "Shift $\(String(format: doubleFormatKey, amount)) from \(fromCategorySelectedName) to \(toCategorySelectedName)?", preferredStyle: .alert)
                            
                            // Adds specified amount
                            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                
                                budget.removeFundsFromCategory(withThisAmount: amount, from: fromCategorySelectedName)
                                budget.allocateFundsToCategory(withThisAmount: amount, to: toCategorySelectedName)
                                
                                self.warningLabel.textColor = successColor
                                self.warningLabel.text = "$\(String(format: doubleFormatKey, amount)) shifted from \(fromCategorySelectedName) to \(toCategorySelectedName)"
                                
                                self.updateUIElementsBecauseOfSuccess(forFromCategory: fromCategorySelectedName, forToCategory: toCategorySelectedName)
                                
                            }))
                            
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            
                            present(alert, animated: true, completion: nil)
                            
                        }
                        
                    } else {
                        
                        failureWithWarning(message: "You can't use letters for the amount.")
                        
                    }
                    
                }
                
            }
            
        }
        
    }

    // MARK: Loading stuff
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        budget.sortCategoriesByKey(withUncategorized: true)
        updateLeftLabelAtTopRight()
        
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: fromCategoryCurrentBalanceLabel)
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: toCategoryCurrentBalanceLabel)
        
        moveFundsButtonTitle.layer.cornerRadius = 18
        moveFundsButtonTitle.layer.masksToBounds = true
        
        updateUIForAllocate()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        budget.sortCategoriesByKey(withUncategorized: true)
        updateLeftLabelAtTopRight()
        
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: fromCategoryCurrentBalanceLabel)
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: toCategoryCurrentBalanceLabel)
        
        updateUIForAllocate()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}
