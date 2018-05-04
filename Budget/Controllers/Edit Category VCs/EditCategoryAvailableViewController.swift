//
//  EditCategoryAvailableViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/4/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditCategoryAvailableViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var currentCategoryNameString = String()
    var currentCategoryAvailableDouble = Double()
    
    var selectedCategoryName = String()
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Update Amounts At Top
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var leftInCategoryLabel: UILabel!
    
    
    
    @IBOutlet weak var currentCategoryName: UILabel!
    
    @IBOutlet weak var currentCategoryAvailable: UILabel!
    
    
    @IBOutlet weak var editAmountView: UIView!
    
    @IBOutlet weak var newCategoryAvailable: UITextField!
    
    
    
    
    // MARK: - Edit Category Available Check
    
    
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
            
            
            // Update the UI element with the new info
            self.currentCategoryAvailableDouble = newCategoryAvailable
            
            self.updateLeftLabelAtTopRight(barButton: self.leftLabelOnNavBar, unallocatedButton: self.leftAmountAtTopRight)
            
            self.currentCategoryAvailable.text = "\(self.convertedAmountToDollars(amount: newCategoryAvailable))"
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    // MARK: - Picker
    
    @IBOutlet weak var newAvailablePicker: UIPickerView!
    
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
        
        selectedCategoryName = budget.sortedCategoryKeys[row]
        
        guard let currentCategory = loadSpecificCategory(named: budget.sortedCategoryKeys[row]) else { return }
        
        leftInCategoryLabel.text = "~ Left in \(selectedCategoryName): \(convertedAmountToDollars(amount: currentCategory.available)) ~"
        
        warningLabel.text = ""
    }
    
    
    
    
    
    
    // MARK: - Update Amount Button
    
    @IBOutlet weak var updateItemButton: UIButton!
    @IBAction func updateItem(_ sender: UIButton) {
        
        submitEditCategoryAvailableForReview()
        
    }
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCategoryNameString = editableCategoryName
        guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
        
        if let currentCategory = loadSpecificCategory(named: currentCategoryNameString) {
            
            currentCategoryAvailableDouble = currentCategory.budgeted
            
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
        
        newCategoryAvailable.inputAccessoryView = toolbar
        
        
        
        self.updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        
        self.currentCategoryName.text = "~ \(currentCategoryNameString) ~"
        self.currentCategoryAvailable.text = "\(convertedAmountToDollars(amount: currentCategoryAvailableDouble))"
        self.leftInCategoryLabel.text = "\(convertedAmountToDollars(amount: unallocated.available))"
        
        self.selectedCategoryName = unallocatedKey
        
        self.addCircleAroundButton(named: self.updateItemButton)
        
        self.newCategoryAvailable.delegate = self
        
        
        // MARK: - Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    @objc func nameTapped() {
        
        newCategoryAvailable.becomeFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newCategoryAvailable.resignFirstResponder()
        submitEditCategoryAvailableForReview()
        return true
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
    
    // 'Done' button on number pad to submit for review of final submitability
    @objc func dismissNumberKeyboard() {
        
        submitEditCategoryAvailableForReview()
        newCategoryAvailable.resignFirstResponder()
        
    }
    
    
    

    

}








