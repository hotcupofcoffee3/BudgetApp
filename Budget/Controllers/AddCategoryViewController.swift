//
//  AddCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit
import Foundation

class AddCategoryViewController: UIViewController, UITextFieldDelegate {
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    func updateLeftLabelAtTopRight() {
        
        budget.updateBalance()
        leftLabelOnNavBar.title = "\(convertedAmountToDollars(amount: budget.balance))"
        
        guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
        leftAmountAtTopRight.text = "Unallocated: \(convertedAmountToDollars(amount: unallocated.available))"
    }
    
    // MARK: Update elements because of success
    
    func updateUIElementsBecauseOfSuccess() {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Update Left label at top right
        updateLeftLabelAtTopRight()
        
        // Set text fields back to being empty
        categoryNameTextField.text = nil
        categoryAmountTextField.text = nil
        
    }
    
    // MARK: Failure message
    
    func failureWithWarning(message: String) {
        
        // Warning notification haptic
        let warningHaptic = UINotificationFeedbackGenerator()
        warningHaptic.notificationOccurred(.error)
        
        categoryWarningLabel.textColor = UIColor.red
        categoryWarningLabel.text = message
        
    }
    
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var categoryAmountTextField: UITextField!
    
    @IBOutlet weak var categoryWarningLabel: UILabel!
    
    @IBOutlet weak var addCategoryButton: UIButton!
    
    
    
    
    // MARK: - Add Category Check
    
    
    // Error Check
    
    func submitAddCategoryForReview() {
        
        if let categoryName = categoryNameTextField.text, let categoryAmount = categoryAmountTextField.text {
            
            // *** Checks if it's already created.
            var isAlreadyCreated = false
            
            for category in budget.categories {
                
                if category.name! == categoryName {
                    
                    isAlreadyCreated = true
                    
                }
            
            }
            
            // *** If everything is blank
            if categoryName == "" || categoryAmount == "" {
                
                failureWithWarning(message: "You have to complete both fields.")
                
                
                // *** If "Unallocated" is the attempted name
            } else if categoryName == unallocatedKey {
                
                failureWithWarning(message: "You cannot create a category called \"Unallocated\"")
                
                
                // *** If the category name already exists.
            } else if isAlreadyCreated == true {
                
                failureWithWarning(message: "A category with this name has already been created.")
                
                
                // *** If both are filled out, but the amount is not a double
            } else if categoryName != "" && categoryAmount != "" && Double(categoryAmount) == nil {
                
                failureWithWarning(message: "You have to enter a number for the amount.")
                
                
            } else {
                
                if let categoryAmountAsDouble = Double(categoryAmount) {
                    
                    if categoryAmountAsDouble < 0.0 {
                        
                        failureWithWarning(message: "You have to enter a positive number")
                        
                    } else {
                        
                        showAlertToConfirmAddCategory(newCategoryName: categoryName, with: categoryAmountAsDouble)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    // Alert Confirmation
    
    func showAlertToConfirmAddCategory(newCategoryName: String, with amount: Double) {
        
        categoryNameTextField.resignFirstResponder()
        categoryAmountTextField.resignFirstResponder()
            
        let alert = UIAlertController(title: nil, message: "Create category named \"\(newCategoryName)\" with an amount of \(convertedAmountToDollars(amount: amount))?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            budget.addCategory(named: newCategoryName, withBudgeted: amount)
            guard let newCategory = loadSpecificCategory(named: newCategoryName) else { return }
            newCategory.budgeted = amount
            
            self.categoryWarningLabel.textColor = successColor
            self.categoryWarningLabel.text = "\"\(newCategoryName)\" with an amount of \(self.convertedAmountToDollars(amount: amount)) has been added."
            
            self.updateUIElementsBecauseOfSuccess()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    
    }
    
    
    @IBAction func addCategory(_ sender: UIButton) {
        
        submitAddCategoryForReview()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        // MARK: Add tap gesture to textfields and their labels
        
        let nameViewTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        let amountViewTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped))
        
        nameView.addGestureRecognizer(nameViewTap)
        amountView.addGestureRecognizer(amountViewTap)
        
        
        
        
        // MARK: - Toolbar with 'Done' button
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor.black
        
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.dismissNumberKeyboard))
        doneButton.tintColor = UIColor.white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        categoryAmountTextField.inputAccessoryView = toolbar
        
        
        
        // MARK: - Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
        
        
        
        
        updateLeftLabelAtTopRight()
        
        addCategoryButton.layer.cornerRadius = 27
        addCategoryButton.layer.masksToBounds = true
        addCategoryButton.layer.borderWidth = 1
        addCategoryButton.layer.borderColor = lightGreenColor.cgColor
        
        self.categoryNameTextField.delegate = self
        self.categoryAmountTextField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateLeftLabelAtTopRight()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    @objc func nameTapped() {
        
        categoryNameTextField.becomeFirstResponder()
        
    }
    
    @objc func amountTapped() {
        
        categoryAmountTextField.becomeFirstResponder()
        
    }
    
    
    // MARK: - Keyboard dismissals
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // Test for submitability
    func submissionFromKeyboardReturnKey(specificTextField: UITextField) {
        
        if categoryNameTextField.text != "" {
            
            submitAddCategoryForReview()
            
        } else {
            specificTextField.resignFirstResponder()
        }
        
    }
    
    // Submit for review of final submitability
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        submissionFromKeyboardReturnKey(specificTextField: textField)
        
        return true
    }
    
    // 'Done' button on number pad to submit for review of final submitability
    @objc func dismissNumberKeyboard() {
        
        submissionFromKeyboardReturnKey(specificTextField: categoryAmountTextField)
        
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
    
    // Remove warning label text
    func textFieldDidBeginEditing(_ textField: UITextField) {
        categoryWarningLabel.text = ""
    }
    
}
