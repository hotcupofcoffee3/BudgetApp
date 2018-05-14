//
//  DateFormatModel.swift
//  Budget
//
//  Created by Adam Moore on 4/16/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation



// *** Convert Date() Object to Individual Components in Dictionary

func convertDateToInts (dateToConvert: Date) -> [String: Int] {
    
    var dateToDisplay = [String: Int]()

    let calendar = Calendar.current
    
    let year = calendar.component(.year, from: dateToConvert)
    let month = calendar.component(.month, from: dateToConvert)
    let day = calendar.component(.day, from: dateToConvert)
    
    dateToDisplay = [monthKey: month, dayKey: day, yearKey: year]
    
    return dateToDisplay
    
}


// *** Convert Date into YYYYMMDD

func convertDateInfoToYYYYMMDD(year: Int, month: Int, day: Int) -> Int {
    
    var convertedDateString = String()
    var convertedDateInt = Int()
    
    let yearAsString = "\(year)"
    var monthAsString = ""
    var dayAsString = ""
    
    if month < 10 {
        monthAsString = "0\(month)"
    } else {
        monthAsString = "\(month)"
    }
    
    if day < 10 {
        dayAsString = "0\(day)"
    } else {
        dayAsString = "\(day)"
    }
    
    convertedDateString = yearAsString + monthAsString + dayAsString
    
    if let convertedDate = Int(convertedDateString) {
        
        convertedDateInt = convertedDate
        
    }
    
    return convertedDateInt
    
}


// *** Convert Date Components into ID

func convertedDateComponentsToTransactionID(year: Int, month: Int, day: Int) -> Int {
    
    var formattedID = Int()
    
    var convertedID = convertDateInfoToYYYYMMDD(year: year, month: month, day: day)
    
    // Multiplied by 100000, then 1 added, to make it have the same format as the other IDs
    convertedID *= 100000
    convertedID += 1
    
    // Sorts them in ascending order to run through correctly.
    budget.sortTransactionsAscending()
    
    for transaction in budget.transactions {
        if convertedID == transaction.id {
            convertedID += 1
        }
    }
    
    formattedID = convertedID
    
    // Sorts them with most recent first.
    budget.sortTransactionsDescending()
    
    return formattedID
    
}


// *** Convert Date Components into Budgeted Time Frame

func convertedDateToBudgetedTimeFrameID(timeFrame: Date, isEnd: Bool) -> Int {
    
    var formattedDate = Int()
    
    let dateDict = convertDateToInts(dateToConvert: timeFrame)
    
    if let year = dateDict[yearKey], let month = dateDict[monthKey], let day = dateDict[dayKey] {
        
        var convertedDate = convertDateInfoToYYYYMMDD(year: year, month: month, day: day)
        
        // Multiplied by 100000
        convertedDate *= 100000
        
        // The start will have a value of 0 completely, to make it before all IDs.
        // The end will have a value of 10000 more than the IDs, to make it the end.
        if isEnd {
            
            convertedDate += 10000
            
        }
        
        formattedDate = convertedDate
        
    }
    
    return formattedDate
    
}



