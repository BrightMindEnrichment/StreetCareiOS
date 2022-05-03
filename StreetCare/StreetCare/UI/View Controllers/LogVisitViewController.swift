//
//  LogVisitViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/3/22.
//

import UIKit

class LogVisitViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var controller = LogVisitController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            
            let definition = controller.definitionForIndex(indexPath.row)

            if let vc = segue.destination as? DataCollectionViewController {
                vc.def = definition
            }
        }
    }
    

} // end class



extension LogVisitViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "logVisitCellView") else {
            preconditionFailure()
        }

        let def = controller.definitionForIndex(indexPath.row)
        
        var content = cell.defaultContentConfiguration()
        
        content.text = Language.locString(def.prompt)
        content.secondaryText = def.dataDisplay
        
        cell.contentConfiguration = content

        return cell
    }
    
    
} // end extension
