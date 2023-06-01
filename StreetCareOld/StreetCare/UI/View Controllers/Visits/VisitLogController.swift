//
//  LogsController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/4/22.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift



protocol LogsControllerProtocol {
    func dataRefreshed()
}



class VisitLogController {
    
    var visitLogs = [VisitLog]()
    var delegate: LogsControllerProtocol?
    var adapter = VisitLogDataAdapter()

    
    init() {
        adapter.delegate = self
    }
    var count: Int {
        return visitLogs.count
    }
    
    
    
    func logForRowAtIndex(_ index: Int) -> VisitLog {
        return visitLogs[index]
    }
    
    
    
    func refresh() {
        adapter.refresh()
    }
    
} // end class



extension VisitLogController: VisitLogDataAdapterProtocol {
    
    func visitLogDataRefreshed(_ logs: [VisitLog]) {
        self.visitLogs = logs
        
        delegate?.dataRefreshed()
    }
}
