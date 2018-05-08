//
//  EditCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/22/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditCategoryViewController: UIViewController, UITextFieldDelegate {
    
    // *****
    // MARK: - Variables
    // *****
    
    var currentCategoryNameString = String()
    
    var currentCategoryBudgetedDouble = Double()
    
    var currentCategoryAvailableDouble = Double()
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    @IBOutlet weak var currentCategoryName: UILabel!
    
    @IBOutlet weak var currentCategoryBudgeted: UILabel!
    
    @IBOutlet weak var currentCategoryAvailable: UILabel!
    
    @IBOutlet weak var currentRecurringStatus: UISwitch!
    
    @IBOutlet weak var editNameButton: UIButton!
    
    @IBOutlet weak var editBudgetedButton: UIButton!
    
    @IBOutlet weak var editAvailableButton: UIButton!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func recurringToggleSwitch(_ sender: UISwitch) {
        guard let category = loadSpecificCategory(named: currentCategoryNameString) else { return }
        category.recurring = !category.recurring
        saveData()
    }
    
    
    @IBAction func editName(_ sender: UIButton) {
        
        performSegue(withIdentifier: editCategoryNameSegueKey, sender: self)
        
    }
    
    @IBAction func editBudgeted(_ sender: UIButton) {
        
        performSegue(withIdentifier: editCategoryBudgetedSegueKey, sender: self)
        
    }
    
    @IBAction func editAvailable(_ sender: UIButton) {
        
        performSegue(withIdentifier: editCategoryAvailableSegueKey, sender: self)
        
    }
    
    
    
    // *****
    // MARK: - TableView
    // *****
    
    
    
    
    
    // *****
    // MARK: - PickerView
    // *****
    
    
    
    
    
    // *****
    // MARK: - DatePickerView
    // *****
    
    
    
    
    
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
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCategoryNameString = editableCategoryName
        
        updateLabels()
        updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        
        self.addCircleAroundButton(named: self.editNameButton)
        self.addCircleAroundButton(named: self.editBudgetedButton)
        self.addCircleAroundButton(named: self.editAvailableButton)
        
        guard let category = loadSpecificCategory(named: currentCategoryNameString) else { return }
        
        if category.recurring {
            
            currentRecurringStatus.isOn = true
            
        } else {
            
            currentRecurringStatus.isOn = false
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        currentCategoryNameString = editableCategoryName
        
        self.updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        self.updateLabels()
        
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    
    
    
    
    
    
    
    
    
    
    
}
















