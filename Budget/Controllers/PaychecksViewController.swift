//
//  PaychecksViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class PaychecksViewController: UIViewController {
    
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var editPaycheck = false
    
    var isNewPaycheck = true
    
    var editablePaycheck: Paycheck?
    
    
    
    // *****
    // MARK: - Header for Main Views
    // *****
    
    // *** IBOutlets
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    @IBOutlet weak var mainBalanceLabel: UILabel!
    
    
    
    // *** IBActions
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        editPaycheck = !editPaycheck
        
        editBarButton.title = editPaycheck ? "Done" : "Edit"
        
        displayedDataTable.reloadData()
        
    }
    
    @IBAction func addSomething(_ sender: UIButton) {
        performSegue(withIdentifier: budgetToAddOrEditBudgetSegueKey, sender: self)
    }
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    
    
    
    
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
    
    
    
    
    
    // *****
    // MARK: - Prepare For Segue
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == categoriesToAddOrEditTransactionSegueKey {
            
            let destinationVC = segue.destination as! AddOrEditTransactionViewController
            
            destinationVC.isNewTransaction = true
            
        } else if segue.identifier == categoriesToAddOrEditCategorySegueKey {
            
            let destinationVC = segue.destination as! AddOrEditCategoryViewController
            
            destinationVC.isNewCategory = isNewCategory
            
            if !isNewCategory {
                
                guard let editableCategory = loadSpecificCategory(named: editableCategoryName) else { return }
                
                destinationVC.editableCategory = editableCategory
                
                
            }
            
        }
        
    }
    
    
    
    


}




















