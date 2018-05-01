//
//  EditCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/22/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditCategoryViewController: UIViewController, UITextFieldDelegate {
    
    var currentCategoryNameString = String()
    var currentCategoryAmountDouble = Double()
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    func updateLeftLabelAtTopRight() {
        
        leftLabelOnNavBar.title = "$\(String(format: doubleFormatKey, budget.balance))"
        
        guard let unallocated = budget.categories[unallocatedKey] else { return }
        leftAmountAtTopRight.text = "Unallocated: $\(String(format: doubleFormatKey, unallocated.available))"
    }
    
    func updateLabelsAtTop() {
        
        if let currentCategory = budget.categories[currentCategoryNameString] {
            
            currentCategoryName.text = currentCategoryNameString
            currentCategoryAmount.text = "Left: $\(String(format: doubleFormatKey, currentCategory.available))"
            
        }
    
    }
    
    // MARK: Update elements because of success
    
    func updateUIElementsBecauseOfSuccess(label: UILabel, textFieldUsed: UITextField, successMessage: String) {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Warning label update
        label.textColor = successColor
        label.text = successMessage
        
        
        // Update Left label at top right & balance labels
        updateLabelsAtTop()
        
        // Clear text field
        textFieldUsed.text = nil
        textFieldUsed.text = nil
        
    }
    
    // MARK: Failure message
    
    func failureWithWarning(label: UILabel, message: String) {
        
        // Warning notification haptic
        let warning = UINotificationFeedbackGenerator()
        warning.notificationOccurred(.error)
        
        label.textColor = UIColor.red
        label.text = message
        
    }
    
    @IBOutlet weak var currentCategoryName: UILabel!
    
    @IBOutlet weak var currentCategoryAmount: UILabel!

    
    
    @IBOutlet weak var newCategoryName: UITextField!
    
    @IBOutlet weak var newCategoryAmount: UITextField!
    
    
    
    
    @IBOutlet weak var nameWarningLabel: UILabel!
    
    @IBOutlet weak var amountWarningLabel: UILabel!
    
    
    
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var amountView: UIView!
    
    
    
    // MARK: - Edit Category Name Check
    
    
    // Name Error Check
    
    func submitEditCategoryNameForReview() {
        
        if let oldCategoryTitle = currentCategoryName.text, let newCategoryTitleFromTextField = newCategoryName.text {
            
            // *** Is the field empty?
            if newCategoryTitleFromTextField == "" {
                
                failureWithWarning(label: nameWarningLabel, message: "There is nothing to update.")
                
                
                // *** Is the new category name equal to "Unallocated"?
            } else if newCategoryTitleFromTextField == unallocatedKey {
                
                failureWithWarning(label: nameWarningLabel, message: "You cannot rename a category to \"Unallocated\"")
                
                
                // *** Was the new category entered the same as the one already set?
            } else if oldCategoryTitle == newCategoryTitleFromTextField {
                
                failureWithWarning(label: nameWarningLabel, message: "The category is already named '\(currentCategoryNameString)'")
                
                
                // *** All impossible entries are taken care of.
            } else {
                
                // *** Alert message to pop up to confirmation
                
                showAlertToConfirmEditCategoryName(oldCategoryTitle: oldCategoryTitle, newCategoryTitle: newCategoryTitleFromTextField)
                
            }
            
        }
        
    }
    
    // Name Alert Confirmation
    
    func showAlertToConfirmEditCategoryName(oldCategoryTitle: String, newCategoryTitle: String) {
        
        let alert = UIAlertController(title: nil, message: "Change '\(oldCategoryTitle)' to '\(newCategoryTitle)'?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            budget.updateCategory(named: oldCategoryTitle, updatedNewName: newCategoryTitle, andNewAmountAdded: 0.0)
            
            
            // Update the UI elements with the new info
            self.currentCategoryNameString = newCategoryTitle
            
            self.updateUIElementsBecauseOfSuccess(label: self.nameWarningLabel, textFieldUsed: self.newCategoryName, successMessage: "'\(oldCategoryTitle)' successfully changed to '\(newCategoryTitle)'!")
            
            self.updateLabelsAtTop()
            self.updateLeftLabelAtTopRight()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    // MARK: - Update Name Button
    
    @IBAction func changeName(_ sender: UIButton) {
        
        submitEditCategoryNameForReview()
        
    }
    
    
    
    
    
    // MARK: - Edit Category Amount Check
    
    
    // Amount Error Check
    
    func submitEditCategoryAmountForReview() {
        
        if let oldCategoryTitle = currentCategoryName.text, let newCategoryAmountStringFromTextField = newCategoryAmount.text {
            
            var newCategoryAmount = Double()
            
            guard let oldCategory = budget.categories[oldCategoryTitle] else { return }
            
            
            // *** Is the field empty?
            if newCategoryAmountStringFromTextField == ""  {
                
                failureWithWarning(label: amountWarningLabel, message: "There is nothing to update.")
                
                
                // *** Was the amount not convertible to a Double?
            } else if Double(newCategoryAmountStringFromTextField) == nil {
                
                failureWithWarning(label: amountWarningLabel, message: "You have to enter a number.")
                
                
                // *** All impossible entries are taken care of.
            } else {
                
                guard let unallocated = budget.categories[unallocatedKey] else { return }
                
                // Sets 'newCategoryAmount' to the number entered.
                if let newCategoryAmountDouble = Double(newCategoryAmountStringFromTextField) {
                    
                    newCategoryAmount = newCategoryAmountDouble
                    
                }
                
                // *** Was the amount entered less than 0?
                if newCategoryAmount < 0.0 {
                    
                    failureWithWarning(label: amountWarningLabel, message: "You have to enter a positive amount")
                    
                    // *** If there was not enough unallocated funds available.
                } else if newCategoryAmount > unallocated.available {
                    
                    failureWithWarning(label: amountWarningLabel, message: "You don't have enough unallocated funds for this")
                    
                    
                    // ***** SUCCESS!
                } else {
                    
                    // ***** Alert message to pop up to confirmation
                    
                    showAlertToConfirmEditCategoryAmount(newCategoryAmount: newCategoryAmount, oldCategoryTitle: oldCategoryTitle, oldCategory: oldCategory)
                    
                }
                
            }
            
        }
        
    }
    
    // Amount Alert Confirmation
    
    func showAlertToConfirmEditCategoryAmount(newCategoryAmount: Double, oldCategoryTitle: String, oldCategory: Category) {
        
        let alert = UIAlertController(title: nil, message: "Add $\(String(format: doubleFormatKey, newCategoryAmount)) to '\(oldCategoryTitle)'?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            // Update Category function called & local variables for labels set
            
            print(newCategoryAmount)
            
            budget.updateCategory(named: oldCategoryTitle, updatedNewName: oldCategoryTitle, andNewAmountAdded: newCategoryAmount)
            
            
            // Update the UI element with the new info
            self.currentCategoryAmountDouble = newCategoryAmount
            
            self.updateUIElementsBecauseOfSuccess(label: self.amountWarningLabel, textFieldUsed: self.newCategoryAmount, successMessage: "$\(String(format: doubleFormatKey, newCategoryAmount)) successfully added to '\(oldCategoryTitle)'! \nNew '\(oldCategoryTitle)' balance: $\(String(format: doubleFormatKey, (oldCategory.available + newCategoryAmount)))")
            
            self.updateLabelsAtTop()
            self.updateLeftLabelAtTopRight()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    // MARK: - Update Amount Button
    
    @IBAction func addFunds(_ sender: UIButton) {
        
        submitEditCategoryAmountForReview()
        
    }
    
    
    
    // MARK: - Buttons as outets for rounded borders.
    
    @IBOutlet weak var addFundsButton: UIButton!
    
    @IBOutlet weak var changeNameButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // MARK: - Add done button
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor.black
        
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.dismissNumberKeyboard))
        doneButton.tintColor = UIColor.white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        newCategoryAmount.inputAccessoryView = toolbar
        
        

        // Do any additional setup after loading the view.
        currentCategoryNameString = editableCategoryName
        
        updateLabelsAtTop()
        updateLeftLabelAtTopRight()
        
        self.addFundsButton.layer.cornerRadius = 27
        self.addFundsButton.layer.masksToBounds = true
        self.addFundsButton.layer.borderWidth = 1
        self.addFundsButton.layer.borderColor = lightGreenColor.cgColor
        
        self.changeNameButton.layer.cornerRadius = 27
        self.changeNameButton.layer.masksToBounds = true
        self.changeNameButton.layer.borderWidth = 1
        self.changeNameButton.layer.borderColor = lightGreenColor.cgColor
        
        self.newCategoryName.delegate = self
        self.newCategoryAmount.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Keyboard dismissals
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // Submit for review of final submitability
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == 1 {
            
            submitEditCategoryNameForReview()
            
        }
        
        return true
    }
    
    // 'Done' button on number pad to submit for review of final submitability
    @objc func dismissNumberKeyboard() {
        
        submitEditCategoryAmountForReview()
        
        newCategoryAmount.resignFirstResponder()
        
    }
    
    // Remove warning label text
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameWarningLabel.text = ""
        amountWarningLabel.text = ""
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        nameWarningLabel.text = ""
        amountWarningLabel.text = ""
    }
    
    
    
}
















