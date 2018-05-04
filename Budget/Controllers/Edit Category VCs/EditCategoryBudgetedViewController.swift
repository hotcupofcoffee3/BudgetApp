//
//  EditCategoryBudgetedViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/4/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditCategoryBudgetedViewController: UIViewController, UITextFieldDelegate {
    
    var currentCategoryNameString = String()
    var currentCategoryBudgetedDouble = Double()
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Update Amounts At Top
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    func updateLeftLabelAtTopRight() {
        
        budget.updateBalance()
        leftLabelOnNavBar.title = "\(convertedAmountToDollars(amount: budget.balance))"
        
        guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
        leftAmountAtTopRight.text = "Unallocated: \(convertedAmountToDollars(amount: unallocated.available))"
    }
    
    
    
    // MARK: Failure message
    
    func failureWithWarning(label: UILabel, message: String) {
        
        // Warning notification haptic
        let warning = UINotificationFeedbackGenerator()
        warning.notificationOccurred(.error)
        
        label.textColor = UIColor.red
        label.text = message
        
    }
    
    @IBOutlet weak var warningLabel: UILabel!
    
    
    
    
    @IBOutlet weak var currentCategoryName: UILabel!
    
    @IBOutlet weak var currentCategoryBudgeted: UILabel!
    
    
    @IBOutlet weak var editAmountView: UIView!
    
    @IBOutlet weak var newCategoryBudgeted: UITextField!
    
    
    // MARK: - Edit Category Budgeted Check
    
    
    // Amount Error Check
    
    func submitEditCategoryBudgetedForReview() {
        
        newCategoryBudgeted.resignFirstResponder()
        
        if let newCategoryBudgetedStringFromTextField = newCategoryBudgeted.text {
            
            var newCategoryBudgeted = Double()
            
            guard let oldCategory = loadSpecificCategory(named: currentCategoryNameString) else { return }
            
            
            // *** Is the field empty?
            if newCategoryBudgetedStringFromTextField == ""  {
                
                failureWithWarning(label: warningLabel, message: "There is nothing to update.")
                
                
                // *** Was the amount not convertible to a Double?
            } else if Double(newCategoryBudgetedStringFromTextField) == nil {
                
                failureWithWarning(label: warningLabel, message: "You have to enter a number.")
                
                
                // *** All impossible entries are taken care of.
            } else {
                
                // Sets 'newCategoryBudgeted' to the number entered.
                if let newCategoryBudgetedDouble = Double(newCategoryBudgetedStringFromTextField) {
                    
                    newCategoryBudgeted = newCategoryBudgetedDouble
                    
                }
                
                // *** Was the amount entered less than 0?
                if newCategoryBudgeted < 0.0 {
                    
                    failureWithWarning(label: warningLabel, message: "You have to enter a positive amount")
                    
                    
                    // ***** SUCCESS!
                } else {
                    
                    // ***** Alert message to pop up to confirmation
                    
                    showAlertToConfirmEditCategoryBudgeted(newCategoryBudgeted: newCategoryBudgeted, oldCategoryName: currentCategoryNameString, oldCategory: oldCategory)
                    
                }
                
            }
            
        }
        
    }
    
    // Amount Alert Confirmation
    
    func showAlertToConfirmEditCategoryBudgeted(newCategoryBudgeted: Double, oldCategoryName: String, oldCategory: Category) {
        
        let alert = UIAlertController(title: nil, message: "Change budgeted amount to \(convertedAmountToDollars(amount: newCategoryBudgeted)) for '\(oldCategoryName)'?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            // Update Category function called & local variables for labels set
            
            print(newCategoryBudgeted)
            
            budget.updateCategory(named: oldCategoryName, updatedNewName: oldCategoryName, andNewAmountAdded: newCategoryBudgeted)
            
            
            // Update the UI element with the new info
            self.currentCategoryBudgetedDouble = newCategoryBudgeted
            
            self.updateLeftLabelAtTopRight()
            
            self.currentCategoryBudgeted.text = "\(self.convertedAmountToDollars(amount: newCategoryBudgeted))"
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    // MARK: - Update Amount Button
    
    @IBOutlet weak var updateItemButton: UIButton!
    @IBAction func updateItem(_ sender: UIButton) {
        
        submitEditCategoryBudgetedForReview()
        
    }
    

    
    // MARK: - Button Formatter
    func addCircleAroundButton(named button: UIButton) {
        
        button.layer.cornerRadius = 27
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = lightGreenColor.cgColor
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCategoryNameString = editableCategoryName
        
        if let currentCategory = loadSpecificCategory(named: currentCategoryNameString) {
            
            currentCategoryBudgetedDouble = currentCategory.budgeted
            
        }
        
        
        // MARK: Add tap gesture to textfields and their labels
        
        let nameViewTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        
        editAmountView.addGestureRecognizer(nameViewTap)
        
        
        
        // MARK: - Add done button
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor.black
        
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.dismissNumberKeyboard))
        doneButton.tintColor = UIColor.white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        newCategoryBudgeted.inputAccessoryView = toolbar
        
        
        
        self.updateLeftLabelAtTopRight()
        
        self.currentCategoryName.text = "~ \(currentCategoryNameString) ~"
        self.currentCategoryBudgeted.text = "\(convertedAmountToDollars(amount: currentCategoryBudgetedDouble))"
        self.addCircleAroundButton(named: self.updateItemButton)
        
        self.newCategoryBudgeted.delegate = self
        
        
        // MARK: - Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.updateLeftLabelAtTopRight()
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    @objc func nameTapped() {
        
        newCategoryBudgeted.becomeFirstResponder()
        
    }
    
    // 'Done' button on number pad to submit for review of final submitability
    @objc func dismissNumberKeyboard() {
        
        submitEditCategoryBudgetedForReview()
        newCategoryBudgeted.resignFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newCategoryBudgeted.resignFirstResponder()
        submitEditCategoryBudgetedForReview()
        return true
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
}
