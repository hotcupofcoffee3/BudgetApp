//
//  CategoryPickerViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/8/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

protocol ChooseCategory {
    
    func setCategory(category: String)
    
}

class CategoryPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // *****
    // MARK: - Variables
    // *****
    
    var delegate: ChooseCategory?
    
    var selectedCategory = String()
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var currentCategoryBalanceLabel: UILabel!
    
    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func done(_ sender: UIButton) {
        
        delegate?.setCategory(category: selectedCategory)
        
        dismiss(animated: true, completion: nil)
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
        
        selectedCategory = budget.sortedCategoryKeys[row]
        
        updateCurrentCategoryBalanceLabel(forCategory: selectedCategory)
        
    }
    
    
    
    // *****
    // MARK: - DatePickerView
    // *****
    
    
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    func updateCurrentCategoryBalanceLabel(forCategory categoryName: String) {
        
        if let selectedCategory = loadSpecificCategory(named: categoryName) {
            currentCategoryBalanceLabel.text = "\"\(categoryName)\" has \(convertedAmountToDollars(amount: selectedCategory.available)) left."
        }
        
    }
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateCurrentCategoryBalanceLabel(forCategory: selectedCategory)
        
        guard let sortedCategoryKeyIndex = budget.sortedCategoryKeys.index(of: selectedCategory) else { return }
        
        categoryPickerView.selectRow(sortedCategoryKeyIndex, inComponent: 0, animated: true)
        
    }


}