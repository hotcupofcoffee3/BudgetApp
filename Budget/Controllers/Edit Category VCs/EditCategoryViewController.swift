//
//  EditCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/22/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditCategoryViewController: UIViewController, UITextFieldDelegate {
    
    var currentCategoryNameString = String()
    var currentCategoryBudgetedDouble = Double()
    var currentCategoryAvailableDouble = Double()
    
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
    
    func updateLabels() {
        
        if let currentCategory = loadSpecificCategory(named: currentCategoryNameString) {
            
            currentCategoryName.text = currentCategoryNameString
            currentCategoryBudgeted.text = "\(convertedAmountToDollars(amount: currentCategory.budgeted))"
            currentCategoryAvailable.text = "\(convertedAmountToDollars(amount: currentCategory.available))"
            
        }
    
    }
    
    @IBOutlet weak var currentCategoryName: UILabel!
    
    @IBOutlet weak var currentCategoryBudgeted: UILabel!
    
    @IBOutlet weak var currentCategoryAvailable: UILabel!
    
    
    
    
    // MARK: - Buttons
    
    @IBOutlet weak var editNameButton: UIButton!
    @IBAction func editName(_ sender: UIButton) {
        
        performSegue(withIdentifier: editCategoryNameSegueKey, sender: self)
        
    }
    
    @IBOutlet weak var editBudgetedButton: UIButton!
    @IBAction func editBudgeted(_ sender: UIButton) {
        
        performSegue(withIdentifier: editCategoryBudgetedSegueKey, sender: self)
        
    }
    
    @IBOutlet weak var editAvailableButton: UIButton!
    @IBAction func editAvailable(_ sender: UIButton) {
        
        performSegue(withIdentifier: editCategoryAvailableSegueKey, sender: self)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCategoryNameString = editableCategoryName
        
        
        
        updateLabels()
        updateLeftLabelAtTopRight()
        
        self.addCircleAroundButton(named: self.editNameButton)
        self.addCircleAroundButton(named: self.editBudgetedButton)
        self.addCircleAroundButton(named: self.editAvailableButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Button Formatter
    func addCircleAroundButton(named button: UIButton) {
        
        button.layer.cornerRadius = 27
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = lightGreenColor.cgColor
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        currentCategoryNameString = editableCategoryName
        
        self.updateLeftLabelAtTopRight()
        self.updateLabels()
        
    }
    
}
















