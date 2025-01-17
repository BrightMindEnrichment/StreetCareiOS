//
//  LogsTableViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/4/22.
//

import UIKit
import FirebaseAuth



class VisitLogTableViewController: UITableViewController {

    let controller = VisitLogController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controller.delegate = self
    }
    


    override func viewWillAppear(_ animated: Bool) {
        controller.refresh()
        
        self.title = Language.locString("visitLog")
    }

        
    
    func updateUI() {
        tableView.reloadData()
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.count
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "visitLogCellView") as? VisitLogTableViewCell else {
            preconditionFailure("can't find cell view")
        }

        let log = controller.logForRowAtIndex(indexPath.row)
        
        cell.labelLocation.text = log.location
        cell.labelExperience.text = log.comments
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        cell.labelDate.text = formatter.string(from: log.date)

        return cell
    }



    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

} // end class



extension VisitLogTableViewController: LogsControllerProtocol {


    func dataRefreshed() {
        updateUI()
    }
} // end extension
