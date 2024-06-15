//
//  Common.swift
//  StreetCare
//
//  Created by SID on 6/14/24.
//

import Foundation

func formatDateString(_ dateString: String, format : String = "MMM yyyy") -> String {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    
    if let date = inputFormatter.date(from: dateString) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = format
        return outputFormatter.string(from: date)
    } else {
        return dateString // Return the original string if parsing fails
    }
}

func convertDate(from inputDate: String) -> Date? {
    let inputDateFormatter = DateFormatter()
    inputDateFormatter.dateFormat = "MMM/yyyy"
    inputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    let outputDateFormatter = DateFormatter()
    outputDateFormatter.dateFormat = "MM/yyyy"
    outputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    if let date = inputDateFormatter.date(from: inputDate) {
        return date
    } else {
        return nil
    }
}
