//
//  PublicVisitLogViewModel.swift
//  StreetCare
//
//  Created by Aishwarya S on 21/05/25.
//

import Foundation
import Combine

class PublicVisitLogViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var sectionsAndItems = [[String: [PublicVisitLogData]]]()
    @Published var tempSectionsAndItems = [[String: [PublicVisitLogData]]]()
    @Published var visitLogs = [VisitLog]()
    @Published var filteredLogs = [VisitLog]()
    
    var filteredData: [[String: [PublicVisitLogData]]] {
        if searchText.isEmpty {
            return tempSectionsAndItems
        } else {
            return self.sectionsAndItems.map { dict in
                dict.mapValues { logs in
                    logs.filter { ($0.log?.user.userName ?? "").localizedCaseInsensitiveContains(searchText) ||
                        ($0.log?.city ?? "").localizedCaseInsensitiveContains(searchText)
                    || ($0.log?.stateAbbv ?? "").localizedCaseInsensitiveContains(searchText)}
                }.filter { !$0.value.isEmpty }
            }.filter { !$0.isEmpty }
        }
    }
    
    func filterByDate(filterType: FilterType) {
        let now = Date()
        filteredLogs = visitLogs
        
        switch filterType {
        case .last7Days:
            filteredLogs = visitLogs.filter { log in
                let date = log.whenVisit
                return date >= now.addingTimeInterval(-7 * 24 * 60 * 60) && date <= now
            }
        case .last30Days:
            filteredLogs = visitLogs.filter { log in
                let date = log.whenVisit
                return date >= now.addingTimeInterval(-30 * 24 * 60 * 60) && date <= now
            }
        case .last60Days:
            filteredLogs = visitLogs.filter { log in
                let date = log.whenVisit
                return date >= now.addingTimeInterval(-60 * 24 * 60 * 60) && date <= now
            }
        case .last90Days:
            filteredLogs = visitLogs.filter { log in
                let date = log.whenVisit
                return date >= now.addingTimeInterval(-90 * 24 * 60 * 60) && date <= now
            }
        case .otherPast:
            filteredLogs = visitLogs.filter { log in
                let date = log.whenVisit
                return date < now.addingTimeInterval(-90 * 24 * 60 * 60)
            }
            
        case .reset:
            filteredLogs = visitLogs
        case .none, .next30Days, .next60Days, .next7Days, .next90Days, .otherUpcoming:
            break
        }
        
        // Sort and store response
        let sortedLogs = sort(logs: filteredLogs)
        sectionsAndItems.removeAll()
        for (month, logs) in sortedLogs {
            sectionsAndItems.append(["\(month)": logs])
        }
        tempSectionsAndItems = sectionsAndItems
    }
    
    
    private func sort(logs: [VisitLog]) -> [(String, [PublicVisitLogData])] {
        var result = [PublicVisitLogData]()
        
        // sort based on date
        let sortedArr = logs.sorted {
            $0.whenVisit < $1.whenVisit
        }
        
        for log in sortedArr {
            let data = PublicVisitLogData()
            data.monthYear = formatDateString("\( log.whenVisit)")
            data.date.0 = formatDateString("\( log.whenVisit)", format: "dd")
            data.date.1 = formatDateString("\( log.whenVisit)", format: "EEE").uppercased()
            data.date.2 = formatDateString("\( log.whenVisit)", format: "hh:mm a")
            data.log = log
            result.append(data)
        }
        
        // group logs
        let groupedLogs = result.group(by: { $0.monthYear })
        let sortedByMonth = groupedLogs.sorted {
            convertDate(from: $0.key)! > convertDate(from: $1.key)!
        }
        
        let sortedLogs = sortedByMonth.map {
            (key, logs) -> (String, [PublicVisitLogData]) in
            let values = logs.sorted {
                first, second in
                guard let day1 = first.date.0, let day2 = second.date.0 else {
                    return false
                }
                
                guard let day1 = Int(day1), let day2 = Int(day2) else {
                    return false
                }
                
                return day1 > day2
            }
            return (key, values)
        }
        return sortedLogs
    }
}
