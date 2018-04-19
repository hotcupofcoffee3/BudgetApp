//
//  AddDepositViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/13/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddDepositViewController: UIViewController, UITextFieldDelegate {
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        depositNameTextField.resignFirstResponder()
        depositAmountTextField.resignFirstResponder()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    func updateLeftLabelAtTopRight() {
        if let uncategorized = budget.categories[uncategorizedKey] {
            leftAmountAtTopRight.text = "Left: $\(String(format: doubleFormatKey, uncategorized.available))"
        }
    }
    
    @IBOutlet weak var depositNameTextField: UITextField!
    
    @IBOutlet weak var depositAmountTextField: UITextField!
    
    @IBOutlet weak var depositeDatePicker: UIDatePicker!
    
    @IBAction func changeDateOnPicker(_ sender: UIDatePicker) {
        
        depositNameTextField.resignFirstResponder()
        depositAmountTextField.resignFirstResponder()
        
    }
    
    @IBOutlet weak var depositWarningLabel: UILabel!
    
    @IBAction func addDeposit(_ sender: UIButton) {
        
        depositNameTextField.resignFirstResponder()
        depositAmountTextField.resignFirstResponder()
        
        let date = depositeDatePicker.date
        
        if let name = depositNameTextField.text, let amount = depositAmountTextField.text {
            
            if name == "" || amount == "" {
                
                // Warning notification haptic
                let warningHaptic = UINotificationFeedbackGenerator()
                warningHaptic.notificationOccurred(.error)
                
                depositWarningLabel.textColor = UIColor.red
                depositWarningLabel.text = "You have to fill in all fields."
                
            } else {
                
                let convertedDates = convertDateToInts(dateToConvert: date)
                
                if let amount = Double(amount), let year = convertedDates[yearKey], let month = convertedDates[monthKey], let day = convertedDates[dayKey]{
                    
                    let alert = UIAlertController(title: nil, message: "Deposit \"\(name)\" in the amount of \(String(format: doubleFormatKey, amount))?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        
                        budget.depositTransaction(title: name, inTheAmountOf: amount, year: year, month: month, day: day)
                        
                        self.depositWarningLabel.textColor = successColor
                        self.depositWarningLabel.text = "$\(String(format: doubleFormatKey, amount)) was deposited."
                        
                        // Success notification haptic
                        let successHaptic = UINotificationFeedbackGenerator()
                        successHaptic.notificationOccurred(.success)
                        
                        // Update Left label at top right
                        self.updateLeftLabelAtTopRight()
                        
                        // Clearing text fields
                        self.depositNameTextField.text = nil
                        self.depositAmountTextField.text = nil
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    present(alert, animated: true, completion: nil)
                    
                    
                } else {
                    
                    // Warning notification haptic
                    let warningHaptic = UINotificationFeedbackGenerator()
                    warningHaptic.notificationOccurred(.error)
                    
                    depositWarningLabel.textColor = UIColor.red
                    depositWarningLabel.text = "You have to enter a number for the amount."
                    
                }
                
            }
            
        }
        
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLeftLabelAtTopRight()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateLeftLabelAtTopRight()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // Keyboard dismissals
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
