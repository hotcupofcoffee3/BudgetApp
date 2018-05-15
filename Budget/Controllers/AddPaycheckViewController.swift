//
//  AddPaycheckViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddPaycheckViewController: UIViewController {
    
    // *****
    // MARK: - Variables
    // *****
    
    
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var addPaycheckButton: UIButton!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPaycheck(_ sender: UIButton) {
        submitAddPaycheckForReview()
    }
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    func updateUIElementsBecauseOfSuccess() {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Set text fields back to being empty
        nameTextField.text = nil
        amountTextField.text = nil
        
    }
    
    // *** Add Category Check
    
    // Error Check
    
    func submitAddPaycheckForReview() {
        
        if let name = nameTextField.text, let amount = amountTextField.text {
            
            // *** Checks if it's already created.
            var isAlreadyCreated = false
            
            for category in budget.categories {
                
                if category.name! == name {
                    
                    isAlreadyCreated = true
                    
                }
                
            }
            
            // *** If everything is blank
            if name == "" || amount == "" {
                
                failureWithWarning(label: warningLabel, message: "You have to complete both fields.")
                
                
                // *** If "Unallocated" is the attempted name
            } else if name == unallocatedKey {
                
                failureWithWarning(label: warningLabel, message: "You cannot create a category called \"Unallocated\"")
                
                
                // *** If the category name already exists.
            } else if isAlreadyCreated == true {
                
                failureWithWarning(label: warningLabel, message: "A category with this name has already been created.")
                
                
                // *** If both are filled out, but the amount is not a double
            } else if name != "" && amount != "" && Double(amount) == nil {
                
                failureWithWarning(label: warningLabel, message: "You have to enter a number for the amount.")
                
                
            } else {
                
                if let amountAsDouble = Double(amount) {
                    
                    guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
                    
                    if amountAsDouble < 0.0 {
                        
                        failureWithWarning(label: warningLabel, message: "You have to enter a positive number")
                        
                        
                        // *** If 'Allocate' is switched on, is there enough in 'Unallocated'
                    } else if currentAllocationStatus.isOn && amountAsDouble > unallocated.available {
                        
                        failureWithWarning(label: warningLabel, message: "You don't have enough funds to allocate at this time.")
                        
                    } else {
                        
                        showAlertToConfirmAddCategory(newCategoryName: name, with: amountAsDouble)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    // Alert Confirmation
    
    func showAlertToConfirmAddCategory(newCategoryName: String, with amount: Double) {
        
        nameTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        
        let alert = UIAlertController(title: nil, message: "Create category named \"\(newCategoryName)\" with an amount of \(convertedAmountToDollars(amount: amount))?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            budget.addCategory(named: newCategoryName, withBudgeted: amount)
            
            guard let newCategory = loadSpecificCategory(named: newCategoryName) else { return }
            
            if self.currentAllocationStatus.isOn {
                budget.shiftFunds(withThisAmount: amount, from: unallocatedKey, to: newCategoryName)
            }
            
            if self.dueDateSwitch.isOn {
                
                let dateDict = convertDateToInts(dateToConvert: self.date)
                guard let day = dateDict[dayKey] else { return }
                
                newCategory.dueDay = Int64(day)
                
            }
            
            saveData()
            
            self.warningLabel.textColor = successColor
            self.warningLabel.text = "\"\(newCategoryName)\" with an amount of \(self.convertedAmountToDollars(amount: amount)) has been added."
            
            self.updateUIElementsBecauseOfSuccess()
            self.successHaptic()
            self.updateLeftLabelAtTopRight(barButton: self.leftLabelOnNavBar, unallocatedButton: self.leftAmountAtTopRight)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func nameTapped() {
        
        nameTextField.becomeFirstResponder()
        
    }
    
    @objc func amountTapped() {
        
        amountTextField.becomeFirstResponder()
        
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        amountTextField.inputAccessoryView = toolbar
        
        
        // MARK: - Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
        
        updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        
        addCircleAroundButton(named: addPaycheckButton)
        
        self.nameTextField.delegate = self
        self.amountTextField.delegate = self
        
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    

    

    

}





















