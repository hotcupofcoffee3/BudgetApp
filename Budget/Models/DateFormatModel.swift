//
//  DateFormatModel.swift
//  Budget
//
//  Created by Adam Moore on 4/16/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation

func convertDateToInts (dateToConvert: Date) -> [String: Int] {
    
    var dateToDisplay = [String: Int]()

    let calendar = Calendar.current
    
    let year = calendar.component(.year, from: dateToConvert)
    let month = calendar.component(.month, from: dateToConvert)
    let day = calendar.component(.day, from: dateToConvert)
    
    dateToDisplay = [monthKey: month, dayKey: day, yearKey: year]
    
    return dateToDisplay
    
}



