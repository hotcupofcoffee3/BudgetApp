//
//  ExtensionFunctionsViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/4/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class ExtensionFunctionsViewController: UIViewController {

    

}

extension UIViewController {
    
    // MARK: - Convert Amount to Dollars
        
    func convertedAmountToDollars(amount: Double) -> String {
        
        var convertedAmount = ""
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        if let convertedAmountOptional = numberFormatter.string(from: NSNumber(value: amount)) {
            
            convertedAmount = convertedAmountOptional
            
        }
        
        return convertedAmount
        
    }
    
}
