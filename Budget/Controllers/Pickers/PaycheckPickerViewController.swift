//
//  PaycheckPickerViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/21/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

protocol ChoosePaycheck {
    
    func populateFromPaycheck(paycheck: Paycheck)
    
}

class PaycheckPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    

    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - Declared
    // *****
    
    var delegate: ChoosePaycheck?
    
    var selectedPaycheck: Paycheck?
    
    var loadedPaychecks = [Paycheck]()
    
    
    
    // *****
    // Mark: - IBOutlets
    // *****
    
    @IBOutlet weak var currentPaycheckAmountLabel: UILabel!
    
    @IBOutlet weak var paycheckPickerView: UIPickerView!
    
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    func updateCurrentPaycheckAmountLabel(forPaycheck: Paycheck) {
        
        currentPaycheckAmountLabel.text = "\"\(forPaycheck.name!)\":\n\(convertedAmountToDollars(amount: forPaycheck.amount))."
        
    }
    
    
    
    // *****
    // Mark: - IBActions
    // *****
    
    @IBAction func done(_ sender: UIButton) {
        
        guard let paycheck = selectedPaycheck else { return }
        
        delegate?.populateFromPaycheck(paycheck: paycheck)
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // *****
    // Mark: - Submissions
    // *****
    
    
    
    
    
    // *****
    // Mark: - Delegates
    // *****
    
    
    
    
    
    // *****
    // Mark: - Segues
    // *****
    
    
    
    
    
    // *****
    // Mark: - Tap Functions
    // *****
    
    
    
    
    
    // *****
    // Mark: - Keyboard functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSavedPaychecks()
        
        loadedPaychecks = budget.paychecks
        
        if let currentPaycheck = selectedPaycheck {
            
            updateCurrentPaycheckAmountLabel(forPaycheck: currentPaycheck)
            
            if let paycheckIndex = loadedPaychecks.index(of: currentPaycheck) {
                
                paycheckPickerView.selectRow(paycheckIndex, inComponent: 0, animated: true)
                
            }
            
        }
        
    }
    
    
    
    
    
    
    
}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension PaycheckPickerViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return loadedPaychecks.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = NSAttributedString(string: loadedPaychecks[row].name!, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedPaycheck = loadedPaychecks[row]
        
        guard let paycheck = selectedPaycheck else { return }
        
        updateCurrentPaycheckAmountLabel(forPaycheck: paycheck)
        
    }
    
    
    
}













