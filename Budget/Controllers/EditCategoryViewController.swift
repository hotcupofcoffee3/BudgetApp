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
    
    
    
    // MARK: - Update Buttons
    
    @IBAction func changeName(_ sender: UIButton) {
        
        if let oldCategoryTitle = currentCategoryName.text, let newCategoryTitleFromTextField = newCategoryName.text {
            
            let newCategoryTitle = newCategoryTitleFromTextField
            
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
                
                var alertMessage = String()
                var successMessage = String()
                
                alertMessage = "Change '\(oldCategoryTitle)' to '\(newCategoryTitle)'?"
                
                successMessage = "'\(oldCategoryTitle)' successfully changed to '\(newCategoryTitle)'!"
                

                // *** Alert message to pop up to confirmation
                
                let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    
                    budget.updateCategory(named: oldCategoryTitle, updatedNewName: newCategoryTitle, andNewAmountAdded: 0.0)
                    
                    
                    // Update the UI elements with the new info
                    self.currentCategoryNameString = newCategoryTitle
                    
                    self.updateUIElementsBecauseOfSuccess(label: self.nameWarningLabel, textFieldUsed: self.newCategoryName, successMessage: successMessage)
                    
                    self.updateLabelsAtTop()
                    self.updateLeftLabelAtTopRight()
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)

            }
            
        }
        
    }
    
    
    
    @IBAction func addFunds(_ sender: UIButton) {
        
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
                    
                    newCategoryName.resignFirstResponder()
                    
                    var alertMessage = String()
                    var successMessage = String()
                    
                    alertMessage = "Add $\(String(format: doubleFormatKey, newCategoryAmount)) to '\(oldCategoryTitle)'?"
                    
                    successMessage = "$\(String(format: doubleFormatKey, newCategoryAmount)) successfully added to '\(oldCategoryTitle)'! \nNew '\(oldCategoryTitle)' balance: $\(String(format: doubleFormatKey, (oldCategory.available + newCategoryAmount)))"
                    
                    
                    // ***** Alert message to pop up to confirmation
                    
                    let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        
                        // Update Category function called & local variables for labels set
                        
                        print(newCategoryAmount)
                        
                        budget.updateCategory(named: oldCategoryTitle, updatedNewName: oldCategoryTitle, andNewAmountAdded: newCategoryAmount)
                        
                        
                        // Update the UI element with the new info
                        self.currentCategoryAmountDouble = newCategoryAmount
                        
                        self.updateUIElementsBecauseOfSuccess(label: self.amountWarningLabel, textFieldUsed: self.newCategoryAmount, successMessage: successMessage)
                        
                        self.updateLabelsAtTop()
                        self.updateLeftLabelAtTopRight()
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    present(alert, animated: true, completion: nil)
                    
                }
            
            }
            
        }
        
    }
    
    @IBOutlet weak var addFundsButton: UIButton!
    
    @IBOutlet weak var changeNameButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newCategoryName.resignFirstResponder()
        newCategoryAmount.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameWarningLabel.text = ""
        amountWarningLabel.text = ""
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        nameWarningLabel.text = ""
        amountWarningLabel.text = ""
    }
    

}
















