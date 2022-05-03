//
//  LogVisitController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/3/22.
//

import Foundation


class LogVisitController {
    
    private var fields = [DataCollectionDefinition]()
    
    var log = VisitLog()

    
    
    var count: Int {
        return fields.count
    }
    
    
    
    init() {
        fields.append(DataCollectionDefinition(type: .Text, prompt: "whereWillVisitPrompt", placeholder: "enterLocation", dataDisplay: "The hood"))
        fields.append(DataCollectionDefinition(type: .Date, prompt: "whenWasVisitPrompt", placeholder: nil, dataDisplay: ""))
        fields.append(DataCollectionDefinition(type: .Number, prompt: "hoursSpentPrompt", placeholder: nil, dataDisplay: ""))
        fields.append(DataCollectionDefinition(type: .Selection, prompt: "canOutreachAgainPrompt", placeholder: nil, dataDisplay: ""))
        fields.append(DataCollectionDefinition(type: .Number, prompt: "peopleCountPrompt", placeholder: nil, dataDisplay: ""))
        fields.append(DataCollectionDefinition(type: .Selection, prompt: "rateExperiencePrompt", placeholder: nil, dataDisplay: ""))
        fields.append(DataCollectionDefinition(type: .Number, prompt: "questionsOrComments", placeholder: nil, dataDisplay: ""))
    }
    
    

    init(log: VisitLog) {
        self.log = log
    }
    
    
    private func displayDataForIndex(_ index: Int) -> String? {
    
        switch index {
        case 0:
            return log.location
        case 1:
            if let date = log.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd, yyyy"
                return formatter.string(from: date)
            }
            else {
                return nil
            }
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
    
} // end class
