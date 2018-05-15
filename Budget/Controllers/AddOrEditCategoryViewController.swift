//
//  AddOrEditCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit
import Foundation

class AddOrEditCategoryViewController: UIViewController, UITextFieldDelegate, ChooseDate {
    
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var isAddingNewItem = true
    
    var date = Date()
    
    var dateFormatYYYYMMDD = Int()
    
    
    
    // *****
    // MARK: - Header for Add & Main Edit Views
    // *****
    
    // *** IBOutlets
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var addCategoryButton: UIButton!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    
    // *** IBActions
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addCategory(_ sender: UIButton) {
        submitAddCategoryForReview()
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // *** Tap gesture to textfields and their labels
        let nameViewTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        let amountViewTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped))
        let allocateViewTap = UITapGestureRecognizer(target: self, action: #selector(allocateTapped))
        let datetap = UITapGestureRecognizer(target: self, action: #selector(dateTapped))
        
        nameView.addGestureRecognizer(nameViewTap)
        amountView.addGestureRecognizer(amountViewTap)
        allocateView.addGestureRecognizer(allocateViewTap)
        dateLabel.addGestureRecognizer(datetap)
        
        
        // *** Toolbar with 'Done' on Number Pad
        addToolBarToNumberPad(textField: categoryAmountTextField)
        
        
        // *** Swipe gesture to close keyboard
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
        
        // *** Update labels
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        
        
        // *** Circle around button
        addCircleAroundButton(named: addCategoryButton)
        
        
        // *** Textfield Delegates
        self.categoryNameTextField.delegate = self
        self.categoryAmountTextField.delegate = self
        
        
        
        // *** Checks the status of Adding or Editing
        
        if isAddingNewItem {
            
            self.backButton.title = "Back"
            self.navBar.topItem?.title = "Add Category"
            self.addCategoryButton.setTitle("Add Category", for: .normal)
            
        } else {
            
            self.backButton.title = "Done"
            self.navBar.topItem?.title = "Edit Category"
            self.addCategoryButton.setTitle("Save Changes", for: .normal)
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
    }
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var categoryAmountTextField: UITextField!
    
    @IBOutlet weak var currentAllocationStatus: UISwitch!

    @IBOutlet weak var allocateView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dueDateSwitch: UISwitch!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func dueDateToggleSwitch(_ sender: UISwitch) {
        
        if dueDateSwitch.isOn == true {
            
            performSegue(withIdentifier: addCategoryToDatePickerSegueKey, sender: self)
            
        } else {
            
            dateLabel.text = ""
            
        }
        
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
                
                failureWithWarning(label: warningLabel, message: "You have to complete both fields.")
                
                
                // *** If "Unallocated" is the attempted name
            } else if categoryName == unallocatedKey {
                
                failureWithWarning(label: warningLabel, message: "You cannot create a category called \"Unallocated\"")
                
                
                // *** If the category name already exists.
            } else if isAlreadyCreated == true {
                
                failureWithWarning(label: warningLabel, message: "A category with this name has already been created.")
                
                
                // *** If both are filled out, but the amount is not a double
            } else if categoryName != "" && categoryAmount != "" && Double(categoryAmount) == nil {
                
                failureWithWarning(label: warningLabel, message: "You have to enter a number for the amount.")
                
                
            } else {
                
                if let categoryAmountAsDouble = Double(categoryAmount) {
                    
                    guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
                    
                    if categoryAmountAsDouble < 0.0 {
                        
                        failureWithWarning(label: warningLabel, message: "You have to enter a positive number")
                        
                        
                        // *** If 'Allocate' is switched on, is there enough in 'Unallocated'
                    } else if currentAllocationStatus.isOn && categoryAmountAsDouble > unallocated.available {
                    
                        failureWithWarning(label: warningLabel, message: "You don't have enough funds to allocate at this time.")
                        
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
            self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    
    // ****************************************************************************************
    
    
    
    
    
    
    
    
    
    
    
    // *** Edit Category Name Check
    
    // Name Error Check
    
    func submitEditCategoryNameForReview() {
        
        if let oldCategoryName = currentCategoryName.text, let newCategoryNameFromTextField = newCategoryName.text {
            
            // *** Is the field empty?
            if newCategoryNameFromTextField == "" {
                
                failureWithWarning(label: warningLabel, message: "There is nothing to update.")
                
                
                // *** Is the new category name equal to "Unallocated"?
            } else if newCategoryNameFromTextField == unallocatedKey {
                
                failureWithWarning(label: warningLabel, message: "You cannot rename a category to \"Unallocated\"")
                
                
                // *** Was the new category entered the same as the one already set?
            } else if oldCategoryName == newCategoryNameFromTextField {
                
                failureWithWarning(label: warningLabel, message: "The category is already named '\(currentCategoryNameString)'")
                
                
                // *** All impossible entries are taken care of.
            } else {
                
                for categoryName in budget.sortedCategoryKeys {
                    
                    if categoryName == newCategoryNameFromTextField {
                        
                        failureWithWarning(label: warningLabel, message: "There is already a category named '\(categoryName)'")
                        
                        return
                        
                    }
                    
                }
                
                // *** Alert message to pop up to confirmation
                
                showAlertToConfirmEditCategoryName(oldCategoryName: oldCategoryName, newCategoryName: newCategoryNameFromTextField)
                
            }
            
        }
        
    }
    
    // Name Alert Confirmation
    
    func showAlertToConfirmEditCategoryName(oldCategoryName: String, newCategoryName: String) {
        
        let alert = UIAlertController(title: nil, message: "Change '\(oldCategoryName)' to '\(newCategoryName)'?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            var oldAmount = Double()
            
            if let oldCategory = loadSpecificCategory(named: oldCategoryName) {
                
                oldAmount = oldCategory.budgeted
                
            }
            
            budget.updateCategory(named: oldCategoryName, updatedNewName: newCategoryName, andNewAmountAdded: oldAmount)
            
            
            // Update the UI elements with the new info
            self.currentCategoryNameString = newCategoryName
            
            self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
            
            self.currentCategoryName.text = newCategoryName
            
            self.successHaptic()
            
            editableCategoryName = newCategoryName
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    // ****************************************************************************************
    
    
    
    
    
    
    
    
    
    // *** Edit Budgeted Error Check
    
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
            
            self.successHaptic()
            
            // Update the UI element with the new info
            self.currentCategoryBudgetedDouble = newCategoryBudgeted
            
            self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
            
            self.currentCategoryBudgeted.text = "\(self.convertedAmountToDollars(amount: newCategoryBudgeted))"
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    // ****************************************************************************************
    
    
    
    
    
    
    
    
    
    // *** Edit Category Available Check
    
    // Amount Error Check
    
    func submitEditCategoryAvailableForReview() {
        
        newCategoryAvailable.resignFirstResponder()
        
        if let newCategoryAvailableStringFromTextField = newCategoryAvailable.text {
            
            var newCategoryAvailable = Double()
            
            guard let currentCategory = loadSpecificCategory(named: currentCategoryNameString) else { return }
            guard let selectedCategory = loadSpecificCategory(named: selectedCategoryName) else { return }
            
            
            // *** Is the field empty?
            if newCategoryAvailableStringFromTextField == ""  {
                
                failureWithWarning(label: warningLabel, message: "There is no amount to add.")
                
                
                // *** Was the amount not convertible to a Double?
            } else if Double(newCategoryAvailableStringFromTextField) == nil {
                
                failureWithWarning(label: warningLabel, message: "You have to enter a number.")
                
                
            } else {
                
                // Sets 'newCategoryAvailable' to the number entered.
                if let newCategoryAvailableDouble = Double(newCategoryAvailableStringFromTextField) {
                    
                    newCategoryAvailable = newCategoryAvailableDouble
                    
                }
                
                // *** Was the amount entered less than 0?
                if newCategoryAvailable < 0.0 {
                    
                    failureWithWarning(label: warningLabel, message: "You have to enter a positive amount")
                    
                    
                    // *** Is the selected Category the same as the current one?
                } else if selectedCategoryName == currentCategory.name! {
                    
                    failureWithWarning(label: warningLabel, message: "This is the same category. There is no point in putting money from your left hand to your right hand.")
                    
                    
                    // *** Were there enough funds available in the 'From' Category?
                } else if newCategoryAvailable > selectedCategory.available {
                    
                    failureWithWarning(label: warningLabel, message: "There are not enough funds in the \"From\" Category.")
                    
                    
                    // ***** SUCCESS!
                } else {
                    
                    // ***** Alert message to pop up to confirmation
                    
                    guard let currentCategoryName = currentCategory.name else { return }
                    guard let selectedCategoryName = selectedCategory.name else { return }
                    
                    showAlertToConfirmEditCategoryAvailable(amount: newCategoryAvailable, from: selectedCategoryName, to: currentCategoryName)
                    
                }
                
            }
            
        }
        
    }
    
    // Amount Alert Confirmation
    
    func showAlertToConfirmEditCategoryAvailable(amount newCategoryAvailable: Double, from selectedCategoryName: String, to currentCategoryName: String) {
        
        let alert = UIAlertController(title: nil, message: "Add \(convertedAmountToDollars(amount: newCategoryAvailable)) to '\(currentCategoryNameString)' from '\(selectedCategoryName)'?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            // Update Category function called & local variables for labels set
            
            print(newCategoryAvailable)
            
            budget.shiftFunds(withThisAmount: newCategoryAvailable, from: selectedCategoryName, to: currentCategoryName)
            
            self.successHaptic()
            
            // Update the UI element with the new info
            self.currentCategoryAvailableDouble = newCategoryAvailable
            
            self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
            
            self.currentCategoryAvailable.text = "\(self.convertedAmountToDollars(amount: newCategoryAvailable))"
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    
    // ****************************************************************************************
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @objc func nameTapped() {
        
        categoryNameTextField.becomeFirstResponder()
        
    }
    
    @objc func amountTapped() {
        
        categoryAmountTextField.becomeFirstResponder()
        
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
    // MARK: - Keyboard functions
    // *****
    
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
    @objc override func dismissNumberKeyboard() {
        
        categoryAmountTextField.resignFirstResponder()
        submissionFromKeyboardReturnKey(specificTextField: categoryAmountTextField)
        
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
    
    // Remove warning label text
    func textFieldDidBeginEditing(_ textField: UITextField) {
        warningLabel.text = ""
    }
    
    
    


    
    
    
}














