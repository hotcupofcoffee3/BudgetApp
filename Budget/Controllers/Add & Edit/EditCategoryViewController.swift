//
//  EditCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/22/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditCategoryViewController: UIViewController, UITextFieldDelegate, ChooseDate {
    
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var currentCategoryNameString = String()
    
    var currentCategoryBudgetedDouble = Double()
    
    var currentCategoryAvailableDouble = Double()
    
    var date = Date()
    
    
    
    // *****
    // MARK: - Header for Add & Main Edit Views
    // *****
    
    // *** IBOutlets
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    
    // *** IBActions
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCategoryNameString = editableCategoryName
        
        updateLabels()
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        
        self.addCircleAroundButton(named: self.editNameButton)
        self.addCircleAroundButton(named: self.editBudgetedButton)
        self.addCircleAroundButton(named: self.editAvailableButton)
        
        let dateTap = UITapGestureRecognizer(target: self, action: #selector(dateTapped))
        
        dueDateView.addGestureRecognizer(dateTap)
        
        guard let category = loadSpecificCategory(named: currentCategoryNameString) else { return }
        
        if category.dueDay >= 1 && category.dueDay <= 31 {
            
            dateLabel.alpha = 1.0
            dateLabel.text = "Due: \(convertDayToOrdinal(day: Int(category.dueDay)))"
            dueDateSwitch.isOn = true
            
        } else {
            
            dateLabel.alpha = 0.5
            dateLabel.text = "Due: N/A"
            dueDateSwitch.isOn = false
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        currentCategoryNameString = editableCategoryName
        
        self.updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        self.updateLabels()
        
    }
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var currentCategoryName: UILabel!
    
    @IBOutlet weak var currentCategoryBudgeted: UILabel!
    
    @IBOutlet weak var currentCategoryAvailable: UILabel!
    
    @IBOutlet weak var editNameButton: UIButton!
    
    @IBOutlet weak var editBudgetedButton: UIButton!
    
    @IBOutlet weak var editAvailableButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dueDateSwitch: UISwitch!
    
    @IBOutlet weak var dueDateView: UIView!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func editName(_ sender: UIButton) {
        
        performSegue(withIdentifier: editCategoryNameSegueKey, sender: self)
        
    }
    
    @IBAction func editBudgeted(_ sender: UIButton) {
        
        performSegue(withIdentifier: editCategoryBudgetedSegueKey, sender: self)
        
    }
    
    @IBAction func editAvailable(_ sender: UIButton) {
        
        performSegue(withIdentifier: editCategoryAvailableSegueKey, sender: self)
        
    }
 
    @IBAction func editDueDateSwitch(_ sender: UISwitch) {
        
        dueDateToggle()
        
    }
    
    
    // *****
    // MARK: - Functions
    // *****
    
    func updateLabels() {
        
        if let currentCategory = loadSpecificCategory(named: currentCategoryNameString) {
            
            currentCategoryName.text = currentCategoryNameString
            currentCategoryBudgeted.text = "\(convertedAmountToDollars(amount: currentCategory.budgeted))"
            currentCategoryAvailable.text = "\(convertedAmountToDollars(amount: currentCategory.available))"
            
        }
        
    }
    
    func dueDateToggle() {
        
        if dueDateSwitch.isOn == true {
            
            dateLabel.alpha = 1.0
            performSegue(withIdentifier: editCategoryToDatePickerSegueKey, sender: self)
            
            
        } else {
            
            dateLabel.text = "Due: N/A"
            dateLabel.alpha = 0.5
            
            guard let category = loadSpecificCategory(named: currentCategoryNameString) else { return }
            
            category.dueDay = Int64()
            
            saveData()
            
        }
        
    }
    
    @objc func dateTapped() {
        
        dueDateSwitch.isOn = !dueDateSwitch.isOn
        
        dueDateToggle()
        
    }
    
    func setDate(date: Date) {
        
        self.date = date
        
        var dateDict = convertDateToInts(dateToConvert: date)
        
        if let day = dateDict[dayKey] {
            
            guard let category = loadSpecificCategory(named: currentCategoryNameString) else { return }
            
            category.dueDay = Int64(day)
            
            dateLabel.text = "Due: \(convertDayToOrdinal(day: day))"
            
            saveData()
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == editCategoryToDatePickerSegueKey {
            
            let datePickerVC = segue.destination as! DatePickerViewController
            
            datePickerVC.delegate = self
            
            datePickerVC.date = date
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
















