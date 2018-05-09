//
//  DatePickerViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/8/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

protocol ChooseDate {
    
    func setDate(date: Date)
    
}

class DatePickerViewController: UIViewController {

    // *****
    // MARK: - Variables
    // *****
    
    var delegate: ChooseDate?
    
    var date = Date()
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var chosenDate: UIDatePicker!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func done(_ sender: UIButton) {
        
        delegate?.setDate(date: chosenDate.date)
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // *****
    // MARK: - DatePickerView
    // *****
    
    
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chosenDate.setDate(date, animated: true)
        
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    
    


}








