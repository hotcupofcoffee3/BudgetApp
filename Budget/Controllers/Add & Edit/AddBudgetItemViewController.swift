//
//  AddBudgetItemViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/15/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddBudgetItemViewController: UIViewController {

    // *****
    // MARK: - Header for Add & Main Edit Views
    // *****
    
    // *** IBOutlets
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    @IBOutlet weak var addOrEditButton: UIButton!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    
    // *** IBActions
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addOrEdit(_ sender: UIButton) {
//        submitAddOrEditForReview()
    }
    
    
    
    
    
    
    
    

}













