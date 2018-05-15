//
//  BudgetItemsViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

var timeFrameStartID = Int()

class BudgetItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var editItem = false
    
    
    
    // *****
    // MARK: - Header for Main Views
    // *****
    
    // *** IBOutlets
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    @IBOutlet weak var mainBalanceLabel: UILabel!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    
    
    // *** IBActions
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        editItem = !editItem
        
        editBarButton.title = editItem ? "Done" : "Edit"
        
        displayedDataTable.reloadData()
        
    }
    
    @IBAction func addSomething(_ sender: UIButton) {
        
        performSegue(withIdentifier: budgetItemsToAddItemSegueKey, sender: self)
        
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayedDataTable.register(UINib(nibName: "BudgetItemTableViewCell", bundle: nil), forCellReuseIdentifier: "BudgetItemCell")
        
        self.loadNecessaryInfo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.loadNecessaryInfo()
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return budget.budgetItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let item = budget.budgetItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetItemCell", for: indexPath) as! BudgetItemTableViewCell
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        
        if editItem == true {
            
            cell.accessoryType = .detailButton
            
        } else {
            
            cell.accessoryType = item.checked ? .checkmark : .none
            
        }
        
        cell.nameLabel?.text = "\(item.name!)"
        cell.dueDayLabel?.text = item.day > 0 ? "Due: \(item.day)" : ""
        cell.amountLabel?.text = "\(convertedAmountToDollars(amount: item.amount))"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = budget.budgetItems[indexPath.row]
        
        if editItem == true {
            
            
            
        } else {
            
            tableView.cellForRow(at: indexPath)?.accessoryType = item.checked ? .none : .checkmark
            
            item.checked = !item.checked
            
            tableView.deselectRow(at: indexPath, animated: false)
            
            saveData()
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    func loadNecessaryInfo() {
        
        loadSpecificBudgetItems(startID: timeFrameStartID)
        refreshAvailableBalanceLabel(label: mainBalanceLabel)
        
        displayedDataTable.rowHeight = 60
        displayedDataTable.separatorStyle = .none
        
        guard let period = loadSpecificBudgetedTimeFrame(startID: timeFrameStartID) else { return }
        
        navBar.topItem?.title = "\(period.startMonth)/\(period.startDay)/\(period.startYear)"
        
        displayedDataTable.reloadData()
        
    }
    
    
    
    
    
    
    
    
   
    
    
    
}














