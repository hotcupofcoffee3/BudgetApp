//
//  AddOrEditBudgetedTimeFrameViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddOrEditBudgetedTimeFrameViewController: UIViewController, ChooseDate {
    
    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - Declared
    // *****
    
    var isNewBudgetTimeFrame = true
    
    var editableBudgetTimeFrame: Period?
    
    var startDateFormatYYYYMMDD = Int()
    
    var endDateFormatYYYYMMDD = Int()
    
    var isStart = true
    
    var startDate = Date()
    
    var endDate = Date()
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var submitTimeFrameButton: UIButton!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var startDateView: UIView!
    
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var endDateView: UIView!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - General Functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitTimeFrame(_ sender: UIButton) {
        submitTimeFrameForReview()
    }
    
    
    
    // *****
    // MARK: - Submissions
    // *****
    
    // ************************************************************************************************
    // ************************************************************************************************
    /*
     
     Add Or Edit Section
     
     */
    // ************************************************************************************************
    // ************************************************************************************************
    
    
    
    // **************************************
    // ***** Add Budgeted Time Frame
    // **************************************
    
    
    func submitTimeFrameForReview () {
        
        let startDateDict = convertDateToInts(dateToConvert: startDate)
        guard let startMonth = startDateDict[monthKey] else { return }
        guard let startDay = startDateDict[dayKey] else { return }
        guard let startYear = startDateDict[yearKey] else { return }
        
        let endDateDict = convertDateToInts(dateToConvert: endDate)
        guard let endMonth = endDateDict[monthKey] else { return }
        guard let endDay = endDateDict[dayKey] else { return }
        guard let endYear = endDateDict[yearKey] else { return }
        
        let startDateYYYYMMDD = convertDateInfoToYYYYMMDD(year: startYear, month: startMonth, day: startDay)
        let endDateYYYYMMDD = convertDateInfoToYYYYMMDD(year: endYear, month: endMonth, day: endDay)
        
        let startID = convertedDateToBudgetedTimeFrameID(timeFrame: startDate, isEnd: false)
        let endID = convertedDateToBudgetedTimeFrameID(timeFrame: endDate, isEnd: true)
        
        
        if startDateYYYYMMDD > endDateYYYYMMDD {
            
            failureWithWarning(label: warningLabel, message: "The start date cannot be later than the end date.")
            
        } else {
            
            for period in budget.budgetedTimeFrames {
                
                let periodStartID = Int(period.startDateID)
                let periodEndID = Int(period.endDateID)
                
                if startID >= periodStartID && startID <= periodEndID {
                    
                    failureWithWarning(label: warningLabel, message: "The start date is in the range of another budgeted time frame.\nThe time frames cannot overlap.")
                    return
                    
                } else if endID >= periodStartID && endID <= periodEndID {
                    
                    failureWithWarning(label: warningLabel, message: "The end date is in the range of another budgeted time frame.\nThe time frames cannot overlap.")
                    return
                    
                }
                
            }
            
            if isNewBudgetTimeFrame {
                
                addBudgetedTimeFrameSubmission(startID: startID, startYear: startYear, startMonth: startMonth, startDay: startDay, endYear: endYear, endMonth: endMonth, endDay: endDay)
                
            } else {
                
                editSubmission()
                
            }
            
        }
        
    }
    
    // *** A Budgeted Time Frame Submission.
    
    func addBudgetedTimeFrameSubmission(startID: Int, startYear: Int, startMonth: Int, startDay: Int, endYear: Int, endMonth: Int, endDay: Int) {
        
        budget.addTimeFrame(start: startDate, end: endDate)
        
        successHaptic()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    // **************************************
    // ***** Edit Budgeted Time Frame
    // **************************************
    
    // *** Only the Confirmation for edits shows, as the check for review is the same for adding or editing the budgeted time frames.
    
    func editSubmission() {
        
        // *** Add in all checks to see if something has been changed or not, then pop up alert message with specific items to update.
        // *** Alert only shows actual changes being made.
        
        guard let currentBudgetTimeFrame = editableBudgetTimeFrame else { return }
        
        
        // Start Date
        let newStartDate = startDate
        var changeStartDate = false
        
        let currentStartDate = convertComponentsToDate(year: Int(currentBudgetTimeFrame.startYear), month: Int(currentBudgetTimeFrame.startMonth), day: Int(currentBudgetTimeFrame.startDay))
       
        if newStartDate != currentStartDate {
            changeStartDate = true
        }
        
        
        // End Date
        let newEndDate = startDate
        var changeEndDate = false
        
        let currentEndDate = convertComponentsToDate(year: Int(currentBudgetTimeFrame.endYear), month: Int(currentBudgetTimeFrame.endMonth), day: Int(currentBudgetTimeFrame.endDay))
        
        if newEndDate != currentEndDate {
            changeEndDate = true
        }
        
        
        // Final check to see if there is anything to change.
        if !changeStartDate && !changeEndDate {
            
            failureWithWarning(label: warningLabel, message: "There is nothing to update.")
            
        } else {
            
            if changeStartDate {
                budget.updateStartDate(currentStartID: Int(currentBudgetTimeFrame.startDateID), newStartDate: newStartDate)
            }
            
            if changeEndDate {
                budget.updateEndDate(currentStartID: Int(currentBudgetTimeFrame.startDateID), newEndDate: newEndDate)
            }
            
            successHaptic()
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Delegates
    // *****
    
    func setDate(date: Date) {
        
        startDate = isStart ? date : startDate
        
        endDate = isStart ? endDate : date
        
        var dateDict = convertDateToInts(dateToConvert: date)
        
        if let year = dateDict[yearKey], let month = dateDict[monthKey], let day = dateDict[dayKey] {
            
            if isStart {
                
                startDateLabel.text = "\(month)/\(day)/\(year)"
                
            } else {
                
                endDateLabel.text = "\(month)/\(day)/\(year)"
                
            }
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Segues
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == addOrEditBudgetToDatePickerSegueKey {
            
            let datePickerVC = segue.destination as! DatePickerViewController
            
            datePickerVC.delegate = self
            
            datePickerVC.date = isStart ? startDate : endDate
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Tap Functions
    // *****
    
    @objc func startDateTapped() {
        
        isStart = true
        
        performSegue(withIdentifier: addOrEditBudgetToDatePickerSegueKey, sender: self)
        
    }
    
    @objc func endDateTapped() {
        
        isStart = false
        
        performSegue(withIdentifier: addOrEditBudgetToDatePickerSegueKey, sender: self)
        
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if isNewBudgetTimeFrame {
            
            startDate = Date()
            endDate = Date()
            
            backButton.title = "Back"
            
            navBar.topItem?.title = "Add New Time Frame"
            
            submitTimeFrameButton.setTitle("Add Time Frame", for: .normal)
            
        } else {
            
            backButton.title = "Cancel"
            
            navBar.topItem?.title = "Edit Time Frame"
            
            guard let currentBudgetTimeFrame = editableBudgetTimeFrame else { return }
            
            startDate = convertComponentsToDate(year: Int(currentBudgetTimeFrame.startYear), month: Int(currentBudgetTimeFrame.startMonth), day: Int(currentBudgetTimeFrame.startDay))
            
            endDate = convertComponentsToDate(year: Int(currentBudgetTimeFrame.endYear), month: Int(currentBudgetTimeFrame.endMonth), day: Int(currentBudgetTimeFrame.endDay))
            
            submitTimeFrameButton.setTitle("Save Changes", for: .normal)
            
        }
        
        
        
        loadSavedBudgetedTimeFrames()
        
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .short
        
        startDateLabel.text = dateFormat.string(from: startDate)
        endDateLabel.text = dateFormat.string(from: endDate)
        
        let startDateViewTap = UITapGestureRecognizer(target: self, action: #selector(startDateTapped))
        let endDateViewTap = UITapGestureRecognizer(target: self, action: #selector(endDateTapped))
        
        startDateView.addGestureRecognizer(startDateViewTap)
        endDateView.addGestureRecognizer(endDateViewTap)
        
        addCircleAroundButton(named: submitTimeFrameButton)
        
        
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .short
        
        startDateLabel.text = dateFormat.string(from: startDate)
        endDateLabel.text = dateFormat.string(from: endDate)
        
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        
    }
    
  
    
    


}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension AddOrEditBudgetedTimeFrameViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    
    
    
}

















