//
//  AllocateFundsViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AllocateFundsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        addFundsTextField.resignFirstResponder()
        
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
            categoryCurrentBalanceLabel.text = "Budgeted: $\(String(format: doubleFormatKey, selectedCategory.budgeted))\nCurrent: $\(String(format: doubleFormatKey, selectedCategory.available))"
        }
        
    }
    
    @IBOutlet weak var allocateOrRemove: UISegmentedControl!
    
    @IBAction func allocateOrRemoveSwitch(_ sender: UISegmentedControl) {
        
        if allocateOrRemove.selectedSegmentIndex == 0 {
            allocateFundsButtonTitle.setTitle("Allocate Funds", for: .normal)
        } else {
            allocateFundsButtonTitle.setTitle("Remove Funds", for: .normal)
        }
        
        addFundsTextField.resignFirstResponder()
    }
    
    
    @IBOutlet weak var addFundsTextField: UITextField!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
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
        
        let categorySelected = budget.sortedCategoryKeys[row]
        
        updateCurrentCategoryBalanceLabel(for: categorySelected)
        
    }
    
    @IBOutlet weak var allocateSuccessLabel: UILabel!
    
    @IBOutlet weak var categoryCurrentBalanceLabel: UILabel!
    
    @IBOutlet weak var allocateFundsButtonTitle: UIButton!
    
    @IBAction func allocateFundsButton(_ sender: UIButton) {
        
        addFundsTextField.resignFirstResponder()
        
        let categoryIndexSelected = categoryPicker.selectedRow(inComponent: 0)
        
        let categorySelected = budget.sortedCategoryKeys[categoryIndexSelected]
        
        if let amount = addFundsTextField.text {
            
            if allocateOrRemove.selectedSegmentIndex == 0 {
                
                // Successful allocation submitted, with the amount being the default set budgeted amount
                if amount == "" {
                    
                    guard let selectedCategory = budget.categories[categorySelected] else { return }
                    guard let uncategorizedCategory = budget.categories[uncategorizedKey] else { return }
                    
                    if (uncategorizedCategory.available - selectedCategory.budgeted) < 0 {
                        
                        // Warning notification haptic
                        let warning = UINotificationFeedbackGenerator()
                        warning.notificationOccurred(.error)
                        
                        self.allocateSuccessLabel.textColor = UIColor.red
                        self.allocateSuccessLabel.text = "You don't have enough funds left for this allocation."
                        
                    } else {
                        
                        if let category = budget.categories[categorySelected] {
                            let alert = UIAlertController(title: nil, message: "Allocate $\(String(format: doubleFormatKey, category.budgeted)) to \(categorySelected)?", preferredStyle: .alert)
                            
                            // Success!!! Adds default amount
                            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                
                                budget.allocateFundsToCategory(withThisAmount: nil, to: categorySelected)
                                
                                self.allocateSuccessLabel.textColor = successColor
                                self.allocateSuccessLabel.text = "$\(String(format: doubleFormatKey, category.budgeted)) allocated to \(categorySelected)"
                                
                                // Success notification haptic
                                let successHaptic = UINotificationFeedbackGenerator()
                                successHaptic.notificationOccurred(.success)
                                
                                // Update Left label at top right & balance
                                self.updateLeftLabelAtTopRight()
                                self.updateCurrentCategoryBalanceLabel(for: categorySelected)
                                
                                // Clear text field
                                self.addFundsTextField.text = nil
                                
                            }))
                            
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            
                            present(alert, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                // Successful allocation submitted, with the amount being specifically set
                } else if let amount = Double(amount) {
                    
                    guard let uncategorizedCategory = budget.categories[uncategorizedKey] else { return }
                    
                    if (uncategorizedCategory.available - amount) < 0 {
                        
                        // Warning notification haptic
                        let warning = UINotificationFeedbackGenerator()
                        warning.notificationOccurred(.error)
                        
                        self.allocateSuccessLabel.textColor = UIColor.red
                        self.allocateSuccessLabel.text = "You don't have enough funds left for this allocation."
                        
                    } else {
                        
                        let alert = UIAlertController(title: nil, message: "Allocate $\(String(format: doubleFormatKey, amount)) to \(categorySelected)?", preferredStyle: .alert)
                        
                        // Success!!! Adds specified amount
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                            
                            budget.allocateFundsToCategory(withThisAmount: amount, to: categorySelected)
                            
                            self.allocateSuccessLabel.textColor = successColor
                            self.allocateSuccessLabel.text = "$\(String(format: doubleFormatKey, amount)) allocated to \(categorySelected)"
                            
                            // Success notification haptic
                            let successHaptic = UINotificationFeedbackGenerator()
                            successHaptic.notificationOccurred(.success)
                            
                            // Update Left label at top right & balance
                            self.updateLeftLabelAtTopRight()
                            self.updateCurrentCategoryBalanceLabel(for: categorySelected)
                            
                            // Clear text field
                            self.addFundsTextField.text = nil
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        
                        present(alert, animated: true, completion: nil)
                        
                    }

                } else {
                    
                    self.allocateSuccessLabel.textColor = UIColor.red
                    self.allocateSuccessLabel.text = "You can't have letters for the amount."
                    
                    // Warning notification haptic
                    let warning = UINotificationFeedbackGenerator()
                    warning.notificationOccurred(.error)
                    
                }
                
            } else if allocateOrRemove.selectedSegmentIndex == 1 {
                
                // Successful removal submitted, with the amount being the default set budgeted amount
                if amount == "" {
                    
                    guard let selectedCategory = budget.categories[categorySelected] else { return }
                    
                    if (selectedCategory.available - selectedCategory.budgeted) < 0 {
                        
                        // Warning notification haptic
                        let warning = UINotificationFeedbackGenerator()
                        warning.notificationOccurred(.error)
                        
                        self.allocateSuccessLabel.textColor = UIColor.red
                        self.allocateSuccessLabel.text = "You don't have enough in this category for that."
                        
                    } else {
                        
                        if let category = budget.categories[categorySelected] {
                            
                            let alert = UIAlertController(title: nil, message: "Remove $\(String(format: doubleFormatKey, category.budgeted)) from \(categorySelected)?", preferredStyle: .alert)
                            
                            // Success!!! Removes default amount
                            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                
                                budget.removeFundsFromCategory(withThisAmount: nil, from: categorySelected)
                                
                                self.allocateSuccessLabel.textColor = successColor
                                self.allocateSuccessLabel.text = "$\(String(format: doubleFormatKey, category.budgeted)) removed from \(categorySelected)"
                                
                                // Success notification haptic
                                let successHaptic = UINotificationFeedbackGenerator()
                                successHaptic.notificationOccurred(.success)
                                
                                // Update Left label at top right & balance
                                self.updateLeftLabelAtTopRight()
                                self.updateCurrentCategoryBalanceLabel(for: categorySelected)
                                
                                // Clear text field
                                self.addFundsTextField.text = nil
                                
                            }))
                            
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            
                            present(alert, animated: true, completion: nil)
                            
                        }
                        
                    }

                // Successful removal submitted, with the amount being specifically set
                } else if let amount = Double(amount) {
                    
                    guard let selectedCategory = budget.categories[categorySelected] else { return }
                    
                    if (selectedCategory.available - amount) < 0 {
                        
                        // Warning notification haptic
                        let warning = UINotificationFeedbackGenerator()
                        warning.notificationOccurred(.error)
                        
                        self.allocateSuccessLabel.textColor = UIColor.red
                        self.allocateSuccessLabel.text = "You don't have enough funds in there for that."
                        
                    } else {
                        
                        let alert = UIAlertController(title: nil, message: "Remove $\(String(format: doubleFormatKey, amount)) from \(categorySelected)?", preferredStyle: .alert)
                        
                        // Success!!! Removes specified amount
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                            
                            budget.removeFundsFromCategory(withThisAmount: amount, from: categorySelected)
                            
                            self.allocateSuccessLabel.textColor = successColor
                            self.allocateSuccessLabel.text = "$\(String(format: doubleFormatKey, amount)) removed from \(categorySelected)"
                            
                            // Success notification haptic
                            let successHaptic = UINotificationFeedbackGenerator()
                            successHaptic.notificationOccurred(.success)
                            
                            // Update Left label at top right & balance
                            self.updateLeftLabelAtTopRight()
                            self.updateCurrentCategoryBalanceLabel(for: categorySelected)
                            
                            // Clear text field
                            self.addFundsTextField.text = nil
                            
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        
                        present(alert, animated: true, completion: nil)
                        
                    }
                    
                } else {
                    
                    self.allocateSuccessLabel.textColor = UIColor.red
                    self.allocateSuccessLabel.text = "You can't have letters for the amount."
                    
                    // Warning notification haptic
                    let warning = UINotificationFeedbackGenerator()
                    warning.notificationOccurred(.error)
                    
                }
                
            }
            
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        budget.sortCategoriesByKey(withUncategorized: false)
        
        updateLeftLabelAtTopRight()
        updateCurrentCategoryBalanceLabel(for: budget.sortedCategoryKeys[0])

    }
    
    override func viewDidAppear(_ animated: Bool) {
        budget.sortCategoriesByKey(withUncategorized: false)
        categoryPicker.reloadAllComponents()
        
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
