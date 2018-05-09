//
//  AddTransactionViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/20/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddTransactionViewController: UIViewController, UITextFieldDelegate, ChooseDate, ChooseCategory {
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var transactionSelection = TransactionType.withdrawal
    
    var date = Date()
    
    var dateFormatYYYYMMDD = Int()
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    @IBOutlet weak var transactionSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var transactionNameTextField: UITextField!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var transactionAmountTextField: UITextField!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dateView: UIView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categoryView: UIView!
    
    @IBOutlet weak var holdToggle: UISwitch!
    
    @IBOutlet weak var holdView: UIView!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var addTransactionButtonTitle: UIButton!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        transactionNameTextField.resignFirstResponder()
        transactionAmountTextField.resignFirstResponder()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func transactionSelected(_ sender: UISegmentedControl) {
        
        if transactionSegmentedControl.selectedSegmentIndex == 0 {
            
            transactionSelection = .withdrawal
            
            updateAddTransactionButtonBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
            
        } else if transactionSegmentedControl.selectedSegmentIndex == 1 {
            
            transactionSelection = .deposit
            
            updateAddTransactionButtonBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
            
        }
        
    }
    
    @IBAction func addTransaction(_ sender: UIButton) {
        
        submitAddTransactionForReview()
        
    }
    
    
    
    // *****
    // MARK: - Functions
    // *****
   
    
    // Update elements because of success
    
    func updateUIElementsBecauseOfSuccess(forCategory category: String) {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Clearing text fields
        transactionNameTextField.text = nil
        transactionAmountTextField.text = nil
        
    }
    
    func updateAddTransactionButtonBasedOnTransactionChoice(typeOfTransaction: TransactionType) {
        
        if typeOfTransaction == .withdrawal {
            
            addTransactionButtonTitle.setTitle("Add Withdrawal", for: .normal)
            categoryLabel.isEnabled = true
            
        } else if typeOfTransaction == .deposit {
            
            addTransactionButtonTitle.setTitle("Add Deposit", for: .normal)
            
            categoryLabel.text = unallocatedKey
            categoryLabel.isEnabled = false
            
        }
        
    }
    
    // *** Add Transaction Check
    
    // Error Check
    
    func submitAddTransactionForReview() {
        
        guard let title = transactionNameTextField.text else { return }
        guard let amount = transactionAmountTextField.text else { return }
           
            guard let category = categoryLabel.text else { return }
            
            let convertedDates = convertDateToInts(dateToConvert: date)
            
        if title == "" || amount == "" {
            
            failureWithWarning(label: warningLabel, message: "You have to fill in all fields.")
            
        } else {
            
            if let amount = Double(amount), let year = convertedDates[yearKey], let month = convertedDates[monthKey], let day = convertedDates[dayKey] {
                
                // MARK: Withdrawal
                
                if transactionSelection == .withdrawal {
                    
                    guard let categoryBeingWithdrawnFrom = loadSpecificCategory(named: category) else { return }
                    
                    if (categoryBeingWithdrawnFrom.available - amount) < 0 {
                        
                        failureWithWarning(label: warningLabel, message: "You don't have enough funds in this category.")
                        
                    } else if amount <= 0 {
                        
                        failureWithWarning(label: warningLabel, message: "You have to enter a number greater than 0.")
                        
                    } else {
                        
                        showAlertToConfirmTransaction(fullDate: date, type: .withdrawal, title: title, amount: amount, categoryName: category, year: year, month: month, day: day)
                        
                    }
                    
                    
                    // MARK: Deposit - Only can deposit into 'Uncategorized' category
                } else if transactionSelection == .deposit {
                    
                    if amount <= 0 {
                        
                        failureWithWarning(label: warningLabel, message: "You have to enter a number greater than 0.")
                        
                    } else {
                        
                        showAlertToConfirmTransaction(fullDate: date, type: .deposit, title: title, amount: amount, categoryName: unallocatedKey, year: year, month: month, day: day)
                        
                    }
                    
                }
                
            } else {
                
                failureWithWarning(label: warningLabel, message: "You have to enter a number for the amount.")
                
            }
            
        }
        
    }
    
    
    // Alert Confirmation
    
    func showAlertToConfirmTransaction(fullDate: Date, type: TransactionType, title: String, amount: Double, categoryName: String, year: Int, month: Int, day: Int) {
        
        transactionNameTextField.resignFirstResponder()
        transactionAmountTextField.resignFirstResponder()
        
        if type == .withdrawal {
            
            let alert = UIAlertController(title: nil, message: "Make a withdrawal called \"\(title)\" in the amount of \(self.convertedAmountToDollars(amount: amount))?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                var onHold = false
                
                if self.holdToggle.isOn {
                    
                    onHold = true
                    
                }
                
                budget.addTransaction(onHold: onHold, type: TransactionType.withdrawal, title: title, forCategory: categoryName, inTheAmountOf: amount, year: year, month: month, day: day)
                
                self.warningLabel.textColor = successColor
                self.warningLabel.text = "\(self.convertedAmountToDollars(amount: amount)) withdrawn from \(categoryName)"
                
                self.successHaptic()
                
                self.updateUIElementsBecauseOfSuccess(forCategory: categoryName)
                self.updateLeftLabelAtTopRight(barButton: self.leftLabelOnNavBar, unallocatedButton: self.leftAmountAtTopRight)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        } else if type == .deposit {
            
            let alert = UIAlertController(title: nil, message: "Deposit \"\(title)\" in the amount of \(self.convertedAmountToDollars(amount: amount))?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                var onHold = false
                
                if self.holdToggle.isOn {
                    
                    onHold = true
                    
                }
                
                budget.addTransaction(onHold: onHold, type: TransactionType.deposit, title: title, forCategory: unallocatedKey, inTheAmountOf: amount, year: year, month: month, day: day)
                
                self.warningLabel.textColor = successColor
                self.warningLabel.text = "\(self.convertedAmountToDollars(amount: amount)) was deposited."
                
                self.successHaptic()
                
                self.updateUIElementsBecauseOfSuccess(forCategory: unallocatedKey)
                self.updateLeftLabelAtTopRight(barButton: self.leftLabelOnNavBar, unallocatedButton: self.leftAmountAtTopRight)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
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
    
    func setCategory(category: String) {
        categoryLabel.text = category
    }
    
    @objc func nameTapped() {
        
        transactionNameTextField.becomeFirstResponder()
        
    }
    
    @objc func amountTapped() {
        
        transactionAmountTextField.becomeFirstResponder()
        
    }
    
    @objc func dateTapped() {
        
        performSegue(withIdentifier: addTransactionToDatePickerSegueKey, sender: self)
        
    }
    
    @objc func categoryTapped() {
        
        if transactionSelection == .withdrawal {
            
            performSegue(withIdentifier: addTransactionToCategoryPickerSegueKey, sender: self)
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == addTransactionToDatePickerSegueKey {
            
            let datePickerVC = segue.destination as! DatePickerViewController
            
            datePickerVC.delegate = self
            
            datePickerVC.date = date
            
        } else if segue.identifier == addTransactionToCategoryPickerSegueKey {
            
            let categoryPickerVC = segue.destination as! CategoryPickerViewController
            
            categoryPickerVC.delegate = self
            
            guard let currentCategory = categoryLabel.text else { return }
            
            categoryPickerVC.selectedCategory = currentCategory
            
        }
        
    }
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .short
    
        dateLabel.text = dateFormat.string(from: Date())
        
        if let category = selectedCategory {
            
            categoryLabel.text = category
            
        }

        
        // MARK: Add tap gesture to textfields and their labels
        
        let nameViewTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        let amountViewTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped))
        let dateViewTap = UITapGestureRecognizer(target: self, action: #selector(dateTapped))
        let categoryViewTap = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        
        nameView.addGestureRecognizer(nameViewTap)
        amountView.addGestureRecognizer(amountViewTap)
        dateView.addGestureRecognizer(dateViewTap)
        categoryView.addGestureRecognizer(categoryViewTap)
        
        
        // MARK: Add done button
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor.black
        
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.dismissNumberKeyboard))
        doneButton.tintColor = UIColor.white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        transactionAmountTextField.inputAccessoryView = toolbar
        
        
        
        // MARK: Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        

        budget.sortCategoriesByKey(withUnallocated: true)
        
        addCircleAroundButton(named: addTransactionButtonTitle)
        
        updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        updateAddTransactionButtonBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
        
        self.transactionNameTextField.delegate = self
        self.transactionAmountTextField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        budget.sortCategoriesByKey(withUnallocated: true)
        
        updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        updateAddTransactionButtonBasedOnTransactionChoice(typeOfTransaction: transactionSelection)
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func submissionFromKeyboardReturnKey(specificTextField: UITextField) {
        
        if transactionNameTextField.text != "" && transactionAmountTextField.text != "" {
            
            submitAddTransactionForReview()
            
        } else {
            specificTextField.resignFirstResponder()
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        submissionFromKeyboardReturnKey(specificTextField: textField)
        
        return true
    }
    
    @objc func dismissNumberKeyboard() {
        
        submissionFromKeyboardReturnKey(specificTextField: transactionAmountTextField)
        
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
    
    
  
    
   
    
}


















