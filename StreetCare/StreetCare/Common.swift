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
    inputFormatter.locale =  isAppLanguageSpanish() ? Locale(identifier: "es_ES") : Locale(identifier: "en_US_POSIX")
    if let date = inputFormatter.date(from: dateString) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = format
        outputFormatter.locale =  isAppLanguageSpanish() ? Locale(identifier: "es_ES") : Locale(identifier: "en_US_POSIX")
        return outputFormatter.string(from: date)
    } else {
        return dateString // Return the original string if parsing fails
    }
}

func convertDate(from inputDate: String) -> Date? {
    let inputDateFormatter = DateFormatter()
    inputDateFormatter.dateFormat = "MMM/yyyy"
    inputDateFormatter.locale = isAppLanguageSpanish() ? Locale(identifier: "es_ES") : Locale(identifier: "en_US_POSIX")
    
    let outputDateFormatter = DateFormatter()
    outputDateFormatter.dateFormat = "MM/yyyy"
    outputDateFormatter.locale = isAppLanguageSpanish() ? Locale(identifier: "es_ES") : Locale(identifier: "en_US_POSIX")
    
    if let date = inputDateFormatter.date(from: inputDate) {
        return date
    } else {
        return nil
    }
}

func convertDateToEst(date : String) -> Date{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    formatter.timeZone = TimeZone(abbreviation: "EST")
    let estDate = formatter.date(from: date)
    print("\(estDate!)")
    return estDate!
}

func isAppLanguageSpanish() -> Bool {
    guard let languageCode = Locale.preferredLanguages.first else { return false }
    return languageCode.starts(with: "es")
}
