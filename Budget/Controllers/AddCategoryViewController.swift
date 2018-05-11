//
//  AddCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit
import Foundation

class AddCategoryViewController: UIViewController, UITextFieldDelegate, ChooseDate {
    
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var date = Date()
    
    var dateFormatYYYYMMDD = Int()
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var categoryAmountTextField: UITextField!
    
    @IBOutlet weak var categoryWarningLabel: UILabel!
    
    @IBOutlet weak var addCategoryButton: UIButton!
    
    @IBOutlet weak var currentRecurringStatus: UISwitch!
    
    @IBOutlet weak var currentAllocationStatus: UISwitch!
    
    @IBOutlet weak var recurringView: UIView!
    
    @IBOutlet weak var allocateView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dueDateSwitch: UISwitch!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dueDateToggleSwitch(_ sender: UISwitch) {
        
        if dueDateSwitch.isOn == true {
            
            performSegue(withIdentifier: addCategoryToDatePickerSegueKey, sender: self)
            
        } else {
            
            dateLabel.text = ""
            
        }
        
    }
    
    @IBAction func addCategory(_ sender: UIButton) {
        submitAddCategoryForReview()
    }
    

    
    // *****
    // MARK: - Functions
    // *****
    
    func updateUIElementsBecauseOfSuccess() {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Set text fields back to being empty
        categoryNameTextField.text = nil
        categoryAmountTextField.text = nil
        
    }
    
    
    // *** Add Category Check
    
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
                
                failureWithWarning(label: categoryWarningLabel, message: "You have to complete both fields.")
                
                
                // *** If "Unallocated" is the attempted name
            } else if categoryName == unallocatedKey {
                
                failureWithWarning(label: categoryWarningLabel, message: "You cannot create a category called \"Unallocated\"")
                
                
                // *** If the category name already exists.
            } else if isAlreadyCreated == true {
                
                failureWithWarning(label: categoryWarningLabel, message: "A category with this name has already been created.")
                
                
                // *** If both are filled out, but the amount is not a double
            } else if categoryName != "" && categoryAmount != "" && Double(categoryAmount) == nil {
                
                failureWithWarning(label: categoryWarningLabel, message: "You have to enter a number for the amount.")
                
                
            } else {
                
                if let categoryAmountAsDouble = Double(categoryAmount) {
                    
                    guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
                    
                    if categoryAmountAsDouble < 0.0 {
                        
                        failureWithWarning(label: categoryWarningLabel, message: "You have to enter a positive number")
                        
                        
                        // *** If 'Allocate' is switched on, is there enough in 'Unallocated'
                    } else if currentAllocationStatus.isOn && categoryAmountAsDouble > unallocated.available {
                    
                        failureWithWarning(label: categoryWarningLabel, message: "You don't have enough funds to allocate at this time.")
                        
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
            
            if self.currentRecurringStatus.isOn {
                newCategory.recurring = true
            }
            
            if self.currentAllocationStatus.isOn {
                budget.shiftFunds(withThisAmount: amount, from: unallocatedKey, to: newCategoryName)
            }
            
            if self.dueDateSwitch.isOn {
                
                let dateDict = convertDateToInts(dateToConvert: self.date)
                guard let day = dateDict[dayKey] else { return }
                
                newCategory.dueDay = Int64(day)
                
            }
            
            saveData()
            
            self.categoryWarningLabel.textColor = successColor
            self.categoryWarningLabel.text = "\"\(newCategoryName)\" with an amount of \(self.convertedAmountToDollars(amount: amount)) has been added."
            
            self.updateUIElementsBecauseOfSuccess()
            self.successHaptic()
            self.updateLeftLabelAtTopRight(barButton: self.leftLabelOnNavBar, unallocatedButton: self.leftAmountAtTopRight)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func nameTapped() {
        
        categoryNameTextField.becomeFirstResponder()
        
    }
    
    @objc func amountTapped() {
        
        categoryAmountTextField.becomeFirstResponder()
        
    }
    
    @objc func recurringTapped() {
        
        currentRecurringStatus.isOn = !currentRecurringStatus.isOn
        
    }
    
    @objc func allocateTapped() {
        
        currentAllocationStatus.isOn = !currentAllocationStatus.isOn
        
    }
    
    @objc func dateTapped() {
        
        if dueDateSwitch.isOn == true {
            
            performSegue(withIdentifier: addCategoryToDatePickerSegueKey, sender: self)
            
        }
        
    }
    
    func setDate(date: Date) {
        
        self.date = date
        
        var dateDict = convertDateToInts(dateToConvert: date)
        
        if let year = dateDict[yearKey], let month = dateDict[monthKey], let day = dateDict[dayKey] {
            
            dateFormatYYYYMMDD = convertDateInfoToYYYYMMDD(year: year, month: month, day: day)
            
            dateLabel.text = "\(month)/\(day)/\(year)"
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == addCategoryToDatePickerSegueKey {
            
            let datePickerVC = segue.destination as! DatePickerViewController
            
            datePickerVC.delegate = self
            
            datePickerVC.date = date
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // MARK: Add tap gesture to textfields and their labels
        
        let nameViewTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        let amountViewTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped))
        let recurringViewTap = UITapGestureRecognizer(target: self, action: #selector(recurringTapped))
        let allocateViewTap = UITapGestureRecognizer(target: self, action: #selector(allocateTapped))
        let datetap = UITapGestureRecognizer(target: self, action: #selector(dateTapped))
        
        nameView.addGestureRecognizer(nameViewTap)
        amountView.addGestureRecognizer(amountViewTap)
        recurringView.addGestureRecognizer(recurringViewTap)
        allocateView.addGestureRecognizer(allocateViewTap)
        dateLabel.addGestureRecognizer(datetap)
        
        
        
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
        
        
        updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        
        addCircleAroundButton(named: addCategoryButton)
        
        self.categoryNameTextField.delegate = self
        self.categoryAmountTextField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    
    
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














