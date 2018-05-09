//
//  MoveFundsViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/19/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class MoveFundsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, ChooseCategory {

    
    // *****
    // MARK: - Variables
    // *****
    
    
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    @IBOutlet weak var allocateRemoveOrShift: UISegmentedControl!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var fundsTextField: UITextField!
    
    @IBOutlet weak var fromCategoryPicker: UIPickerView!
    
    @IBOutlet weak var toCategoryPicker: UIPickerView!
    
    @IBOutlet weak var fromCategoryCurrentBalanceLabel: UILabel!
    
    @IBOutlet weak var toCategoryCurrentBalanceLabel: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var moveFundsButtonTitle: UIButton!
    
    @IBOutlet weak var toCategoryLabel: UILabel!
    
    @IBOutlet weak var toCategoryView: UIView!
    
    @IBOutlet weak var fromCategoryLabel: UILabel!
    
    @IBOutlet var fromCategoryView: UIView!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
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
    
    @IBAction func moveFundsButton(_ sender: UIButton) {
        
        submitAllOptionsForReview()
        
    }
    
    
    
    // *****
    // MARK: - TableView
    // *****
    
    
    
    
    
    // *****
    // MARK: - PickerView
    // *****
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return budget.sortedCategoryKeys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = NSAttributedString(string: budget.sortedCategoryKeys[row], attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
        return title
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
    
    
    
    // *****
    // MARK: - DatePickerView
    // *****
    
    
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    func updateCategoryBalanceLabel(for categoryName: String, atLabel: UILabel) {
        
        guard let selectedCategory = loadSpecificCategory(named: categoryName) else { return }
        
        atLabel.text = "Left: \(convertedAmountToDollars(amount: selectedCategory.available))"
        
    }
    
    func updateUIElementsBecauseOfSuccess(forFromCategory: String, forToCategory: String) {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Update Left label at top right & balance labels
        updateCategoryBalanceLabel(for: forFromCategory, atLabel: fromCategoryCurrentBalanceLabel)
        updateCategoryBalanceLabel(for: forToCategory, atLabel: toCategoryCurrentBalanceLabel)
        
        // Clear text field
        fundsTextField.text = nil
        
    }

    func updateUIForAllocate() {
        
        moveFundsButtonTitle.setTitle("Allocate Funds", for: .normal)
        
        // Disable picker 1 & enable picker 2
        
        toCategoryPicker.isUserInteractionEnabled = true
        toCategoryPicker.alpha = 1.0
        
        fromCategoryPicker.isUserInteractionEnabled = false
        fromCategoryPicker.alpha = 0.5
        
        
        // Set disabled 'from' picker to "Uncategorized"
        fromCategoryPicker.selectRow(0, inComponent: 0, animated: true)
        
        // Update 'from' balance label to 'Uncategorized'
        updateCategoryBalanceLabel(for: unallocatedKey, atLabel: fromCategoryCurrentBalanceLabel)
        
    }
    
    func updateUIForRemove() {
        
        moveFundsButtonTitle.setTitle("Remove Funds", for: .normal)
        
        // Disable picker 2 & enable picker 1
        fromCategoryPicker.isUserInteractionEnabled = true
        fromCategoryPicker.alpha = 1.0
        
        toCategoryPicker.isUserInteractionEnabled = false
        toCategoryPicker.alpha = 0.5
        
        
        
        // Set disabled 'to' picker to 'Uncategorized'
        toCategoryPicker.selectRow(0, inComponent: 0, animated: true)
        
        // Update 'to' balance label to 'Uncategorized'
        updateCategoryBalanceLabel(for: unallocatedKey, atLabel: toCategoryCurrentBalanceLabel)
        
    }
    
    func updateUIForShift() {
        
        moveFundsButtonTitle.setTitle("Shift Funds", for: .normal)
        
        // Enable both pickers
        fromCategoryPicker.isUserInteractionEnabled = true
        fromCategoryPicker.alpha = 1.0
        
        toCategoryPicker.isUserInteractionEnabled = true
        toCategoryPicker.alpha = 1.0
        
    }
    
    // *** Allocate Check
    
    // Error Check
    
    func submitAllocateForReview (amountFromTextField: String) {
        
        let toCategorySelectedIndex = toCategoryPicker.selectedRow(inComponent: 0)
        let toCategorySelectedName = budget.sortedCategoryKeys[toCategorySelectedIndex]
        
        // Allocation submitted, with the amount being the default set budgeted amount
        if amountFromTextField == "" {
            
            failureWithWarning(label: warningLabel, message: "You have to enter an amount.")
            
            
            // Allocation submitted, with the amount being specifically set
        } else if let amount = Double(amountFromTextField) {
            
            guard let unallocatedCategory = loadSpecificCategory(named: unallocatedKey) else { return }
            
            if (unallocatedCategory.available - amount) < 0 {
                
                failureWithWarning(label: warningLabel, message: "You don't have enough funds left that.")
                
            } else if amount <= 0 {
                
                failureWithWarning(label: warningLabel, message: "The amount can't be negative.")
                
            } else {
                
                showAlertToConfirmAllocate(amount: amount, toCategory: toCategorySelectedName)
                
            }
            
        } else {
            
            failureWithWarning(label: warningLabel, message: "You can't have letters for the amount.")
            
        }
        
    }
    
    
    // Alert Confirmation
    
    func showAlertToConfirmAllocate(amount: Double, toCategory: String) {
        
        let alert = UIAlertController(title: nil, message: "Allocate \(self.convertedAmountToDollars(amount: amount)) to \(toCategory)?", preferredStyle: .alert)
        
        // Success!!! Adds specified amount
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            budget.shiftFunds(withThisAmount: amount, from: unallocatedKey, to: toCategory)
            
            self.warningLabel.textColor = successColor
            self.warningLabel.text = "\(self.convertedAmountToDollars(amount: amount)) allocated to \(toCategory)"
            
            self.successHaptic()
            
            self.updateUIElementsBecauseOfSuccess(forFromCategory: unallocatedKey, forToCategory: toCategory)
            self.updateLeftLabelAtTopRight(barButton: self.leftLabelOnNavBar, unallocatedButton: self.leftAmountAtTopRight)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // *** Remove Check
    
    // Error Check
    
    func submitRemoveForReview (amountFromTextField: String) {
        
        let fromCategorySelectedIndex = fromCategoryPicker.selectedRow(inComponent: 0)
        let fromCategorySelectedName = budget.sortedCategoryKeys[fromCategorySelectedIndex]
        
        guard let selectedCategory = loadSpecificCategory(named: fromCategorySelectedName) else { return }
        
        // Removal submitted, with the amount being the default set budgeted amount
        if amountFromTextField == "" {
            
            failureWithWarning(label: warningLabel, message: "You have to enter an amount.")
            
            
            // Removal submitted, with the amount being specifically set
        } else if let amount = Double(amountFromTextField) {
            
            if (selectedCategory.available - amount) < 0 {
                
                failureWithWarning(label: warningLabel, message: "You don't have enough funds in there for that.")
                
            } else if amount <= 0 {
                
                failureWithWarning(label: warningLabel, message: "The amount has to be greater than 0.")
                
            } else {
                
                showAlertToConfirmRemove(amount: amount, fromCategory: fromCategorySelectedName)
                
            }
            
        } else {
            
            failureWithWarning(label: warningLabel, message: "You can't have letters for the amount.")
            
        }
        
    }
    
    
    // Alert Confirmation
    
    func showAlertToConfirmRemove(amount: Double, fromCategory: String) {
        
        let alert = UIAlertController(title: nil, message: "Remove \(self.convertedAmountToDollars(amount: amount)) from \(fromCategory)?", preferredStyle: .alert)
        
        // Success!!! Removes specified amount
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            budget.shiftFunds(withThisAmount: amount, from: fromCategory, to: unallocatedKey)
            
            self.warningLabel.textColor = successColor
            self.warningLabel.text = "\(self.convertedAmountToDollars(amount: amount)) removed from \(fromCategory)"
            
            self.successHaptic()
            
            self.updateUIElementsBecauseOfSuccess(forFromCategory: fromCategory, forToCategory: unallocatedKey)
            self.updateLeftLabelAtTopRight(barButton: self.leftLabelOnNavBar, unallocatedButton: self.leftAmountAtTopRight)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // *** Shift Check
    
    // Error Check
    
    func submitShiftForReview (amountFromTextField: String) {
        
        let fromCategoryIndexSelected = fromCategoryPicker.selectedRow(inComponent: 0)
        let fromCategorySelectedName = budget.sortedCategoryKeys[fromCategoryIndexSelected]
        
        let toCategoryIndexSelected = toCategoryPicker.selectedRow(inComponent: 0)
        let toCategorySelectedName = budget.sortedCategoryKeys[toCategoryIndexSelected]
        
        
        if fundsTextField.text == "" {
            
            failureWithWarning(label: warningLabel, message: "You have to enter an amount first.")
            
        } else {
            
            if let amount = Double(amountFromTextField) {
                
                guard let fromCategory = loadSpecificCategory(named: fromCategorySelectedName) else { return }
                
                if (fromCategory.available - amount) < 0 {
                    
                    failureWithWarning(label: warningLabel, message: "You don't enough to shift from this category.")
                    
                } else if amount <= 0 {
                    
                    failureWithWarning(label: warningLabel, message: "The amount has to be greater than 0.")
                    
                } else {
                    
                    showAlertToConfirmShift(amount: amount, fromCategory: fromCategorySelectedName, toCategory: toCategorySelectedName)
                    
                }
                
            } else {
                
                failureWithWarning(label: warningLabel, message: "You can't use letters for the amount.")
                
            }
            
        }
        
    }
    
    // Alert Confirmation
    
    func showAlertToConfirmShift(amount: Double, fromCategory: String, toCategory: String) {
        
        let alert = UIAlertController(title: nil, message: "Shift \(self.convertedAmountToDollars(amount: amount)) from \(fromCategory) to \(toCategory)?", preferredStyle: .alert)
        
        // Adds specified amount
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            budget.shiftFunds(withThisAmount: amount, from: fromCategory, to: toCategory)
            
            self.warningLabel.textColor = successColor
            self.warningLabel.text = "\(self.convertedAmountToDollars(amount: amount)) shifted from \(fromCategory) to \(toCategory)"
            
            self.successHaptic()
            
            self.updateUIElementsBecauseOfSuccess(forFromCategory: fromCategory, forToCategory: toCategory)
            self.updateLeftLabelAtTopRight(barButton: self.leftLabelOnNavBar, unallocatedButton: self.leftAmountAtTopRight)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // *** Consolidated function for when the "Move Funds" button is pressed or "Done" is pressed.
    
    func submitAllOptionsForReview() {
        
        fundsTextField.resignFirstResponder()
        
        guard let amountFromTextField = fundsTextField.text else { return }
        
        
        // *** Allocate
        if allocateRemoveOrShift.selectedSegmentIndex == 0 {
            
            submitAllocateForReview(amountFromTextField: amountFromTextField)
            
            
            // *** Remove
        } else if allocateRemoveOrShift.selectedSegmentIndex == 1 {
            
            submitRemoveForReview(amountFromTextField: amountFromTextField)
            
            
            // *** Shift
        } else if allocateRemoveOrShift.selectedSegmentIndex == 2 {
            
            submitShiftForReview(amountFromTextField: amountFromTextField)
            
            
        }
        
    }
    
    func setCategory(category: String) {
        
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // MARK: Add tap gesture to textfields and their labels
        
        let amountViewTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped))
        
        amountView.addGestureRecognizer(amountViewTap)
        
        
        // MARK: - Toolbar with 'Done' button
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor.black
        
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.dismissNumberKeyboard))
        doneButton.tintColor = UIColor.white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        fundsTextField.inputAccessoryView = toolbar
        
        
        
        // MARK: - Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
        
        
        budget.sortCategoriesByKey(withUnallocated: true)
        updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: fromCategoryCurrentBalanceLabel)
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: toCategoryCurrentBalanceLabel)
        
        addCircleAroundButton(named: moveFundsButtonTitle)
        
        updateUIForAllocate()
        
        self.fundsTextField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        budget.sortCategoriesByKey(withUnallocated: true)
        updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: fromCategoryCurrentBalanceLabel)
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: toCategoryCurrentBalanceLabel)
        
        updateUIForAllocate()
        
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    @objc func amountTapped() {
        
        fundsTextField.becomeFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // Test for submitability
    func submissionFromKeyboardReturnKey(specificTextField: UITextField) {
        
        if fundsTextField.text != "" {
            
            submitAllOptionsForReview()
            
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
        
        submissionFromKeyboardReturnKey(specificTextField: fundsTextField)
        
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

















