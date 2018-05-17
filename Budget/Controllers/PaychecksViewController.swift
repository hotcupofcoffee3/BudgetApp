//
//  PaychecksViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class PaychecksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - Declared
    // *****
    
    var editPaycheck = false

    var isNewPaycheck = true

    var editablePaycheck: Paycheck?

    var editablePaycheckName = String()
    
    
    
    // *****
    // Mark: - IBOutlets
    // *****
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    @IBOutlet weak var mainBalanceLabel: UILabel!
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - General Functions
    // *****
    
    func loadNecessaryInfo() {
        
        loadSavedPaychecks()
        
        refreshAvailableBalanceLabel(label: mainBalanceLabel)
        
        displayedDataTable.rowHeight = 90
        displayedDataTable.separatorStyle = .none
        
        displayedDataTable.reloadData()
        
    }
    
    
    
    // *****
    // Mark: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        editPaycheck = !editPaycheck
        
        editBarButton.title = editPaycheck ? "Done" : "Edit"
        
        displayedDataTable.reloadData()
        
    }
    
    @IBAction func addSomething(_ sender: UIButton) {
        isNewPaycheck = true
        performSegue(withIdentifier: paychecksToAddOrEditPaycheckSegueKey, sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == paychecksToAddOrEditPaycheckSegueKey {
            
            let destinationVC = segue.destination as! AddOrEditPaycheckViewController
            
            destinationVC.isNewPaycheck = isNewPaycheck
            
            if !isNewPaycheck {
                
                guard let paycheck = editablePaycheck else { return }
                
                destinationVC.editablePaycheck = paycheck
                
            }
            
        }
        
    }
    
    
    
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
        
        self.displayedDataTable.register(UINib(nibName: "PaycheckTableViewCell", bundle: nil), forCellReuseIdentifier: "PaycheckCell")
        
        self.loadNecessaryInfo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.loadNecessaryInfo()
        
    }
    
   
    
   

    
    
}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension PaychecksViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return budget.paychecks.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let paycheck = budget.paychecks[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaycheckCell", for: indexPath) as! PaycheckTableViewCell
        
        addBorderAroundLargerTableCellViews(cellView: cell.paycheckCellView)
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        
        cell.accessoryType = editPaycheck ? .detailButton : .disclosureIndicator
        
        cell.nameLabel?.text = "\(paycheck.name!)"
        cell.amountLabel?.text = "\(convertedAmountToDollars(amount: paycheck.amount))"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let paycheck = budget.paychecks[indexPath.row]
        
        // Same right now, as the 'Edit' button doesn't seem necessary, but I don't want to delete it fully yet; just in case.
        
        if editPaycheck == true {
            
            isNewPaycheck = false
            
            editablePaycheck = paycheck
            
            performSegue(withIdentifier: paychecksToAddOrEditPaycheckSegueKey, sender: self)
            
        } else {
            
            isNewPaycheck = false
            
            editablePaycheck = paycheck
            
            performSegue(withIdentifier: paychecksToAddOrEditPaycheckSegueKey, sender: self)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            
            let paycheckToDelete = budget.paychecks[indexPath.row]
            
            guard let name = paycheckToDelete.name else { return }
            
            let message = "Delete paycheck called \"\n\(name)\" with an amount of \(convertedAmountToDollars(amount: paycheckToDelete.amount))?"
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                
                // *** Additional check before deleting a Category, as this is a big deal.
                let additionalAlert = UIAlertController(title: nil, message: "Sure you're sure?", preferredStyle: .alert)
                
                additionalAlert.addAction(UIAlertAction(title: "Yes, I'm sure.", style: .destructive, handler: { (action) in
                    
                    budget.deletePaycheck(paycheck: paycheckToDelete)
                    
                    self.successHaptic()
                    
                    loadSavedPaychecks()
                    self.displayedDataTable.reloadData()
                    
                }))
                
                additionalAlert.addAction(UIAlertAction(title: "No, don't do it.", style: .cancel, handler: nil))
                
                self.present(additionalAlert, animated: true, completion: nil)
                
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    
    
    
}
















