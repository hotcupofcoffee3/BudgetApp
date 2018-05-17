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

    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - Declared
    // *****
    
    var delegate: ChooseDate?
    
    var date = Date()
    
    
    
    // *****
    // Mark: - IBOutlets
    // *****
    
    @IBOutlet weak var chosenDate: UIDatePicker!
    
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - General Functions
    // *****
    
    
    
    
    
    // *****
    // Mark: - IBActions
    // *****
    
    @IBAction func done(_ sender: UIButton) {
        
        delegate?.setDate(date: chosenDate.date)
        
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
        
        chosenDate.setDate(date, animated: true)
        
    }
    
    
  
    
    


}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension DatePickerViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    
    
    
}












