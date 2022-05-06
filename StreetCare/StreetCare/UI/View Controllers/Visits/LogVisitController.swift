//
//  LogVisitController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/3/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth


class LogVisitController {
    
    private var fields = [DataCollectionDefinition]()
    
    var adapter = VisitLogDataAdapter()
    
    var log = VisitLog()

    
    
    var count: Int {
        return fields.count
    }
    
    
    
    init() {
        fields.append(DataCollectionDefinition(type: .Text, prompt: "whereWillVisitPrompt", placeholder: "enterLocation", options: nil, dataDisplay: "The hood"))
        fields.append(DataCollectionDefinition(type: .Date, prompt: "whenWasVisitPrompt", placeholder: nil, options: nil, dataDisplay: ""))
        fields.append(DataCollectionDefinition(type: .Number, prompt: "hoursSpentPrompt", placeholder: nil, options: nil, dataDisplay: ""))
        fields.append(DataCollectionDefinition(type: .Selection, prompt: "canOutreachAgainPrompt", placeholder: nil, options: ["Yes", "No", "Undecided"], dataDisplay: ""))
        fields.append(DataCollectionDefinition(type: .Number, prompt: "peopleCountPrompt", placeholder: nil, options: nil, dataDisplay: ""))
        fields.append(DataCollectionDefinition(type: .Selection, prompt: "rateExperiencePrompt", placeholder: nil, options: ["😃", "😐", "☹️"], dataDisplay: ""))
        fields.append(DataCollectionDefinition(type: .Text, prompt: "questionsOrComments", placeholder: nil, options: nil, dataDisplay: ""))
    }
    
    

    init(log: VisitLog) {
        self.log = log
    }
    
    
    private func displayDataForIndex(_ index: Int) -> String? {
    
        switch index {
        case 0:
            return log.location
        case 1:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy"
            return formatter.string(from: log.date)
        case 2:
            return log.hours?.description
        case 3:
            return log.visitAgain
        case 4:
            return log.peopleCount?.description
        case 5:
            return log.experience?.description
        case 6:
            return log.comments
        default:
            return nil
        }
    }
    
    
    
    func definitionForIndex(_ index: Int) -> DataCollectionDefinition {

        // update the display data
        let def = fields[index]
        def.dataDisplay = displayDataForIndex(index)
        
        return def
    }
    
    
    
    func save() {
    
        guard let _ = Auth.auth().currentUser else {
            print("no user?")
            return
        }
        
        adapter.addVisitLog(log)
    }
    
    
    
    func saveClosureForIndex(_ index: Int) -> (Any) -> Void {
        
        switch index {
        case 0:
            return updateLocation
        case 1:
            return updateDate
        case 2:
            return updateHours
        case 3:
            return updateVisitAgain
        case 4:
            return updatePeopleCount
        case 5:
            return updateExperience
        case 6:
            return updateComments
        default:
            return updateComments
        }
    }
    
    
    
    func updateLocation(_ location : Any) -> Void {
        if let location = location as? String {
            log.location = location
        }
    }
    
    

    func updateDate(_ date: Any) -> Void {
        if let date = date as? Date {
            log.date = date
        }
    }

    

    func updateHours(_ hours: Any) -> Void {
        if let hours = hours as? Int {
            log.hours = hours
        }
    }



    func updateVisitAgain(_ visitAgain: Any) -> Void {
        if let visitAgain = visitAgain as? String {
            log.visitAgain = visitAgain
        }
    }

    
    func updatePeopleCount(_ peopleCount: Any) -> Void {
        if let peopleCount = peopleCount as? Int {
            log.peopleCount = peopleCount
        }
    }

    
    func updateExperience(_ experience: Any) -> Void {
        if let experience = experience as? String {
            log.experience = experience
        }
    }

    
    func updateComments(_ comments: Any) -> Void {
        if let comments = comments as? String {
            log.comments = comments
        }
    }
} // end class
