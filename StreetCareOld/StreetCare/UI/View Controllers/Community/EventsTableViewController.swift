//
//  EventsTableViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/5/22.
//

import UIKit
import FirebaseAuth

class EventsTableViewController: UITableViewController {

    
    let controller = EventsController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        controller.delegate = self
        
        self.title = Language.locString("community")
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let _ = Auth.auth().currentUser else {
            controller.addErrorEvent()
            updateUI()
            return
        }
        
        controller.refresh()
    }
    
    
    
    func updateUI() {
        tableView.reloadData()
    }
    
    
    
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.count
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as? EventTableViewCell else {
            preconditionFailure("can't find cell in storyboard")
        }

        // clear out old data
        cell.labelTitle.text = ""
        cell.labelDescription.text = ""
        cell.labelSmallDate.text = ""
        cell.labelFullDate.text = ""
        cell.labelInterest.text = ""

        
        
        // get new data
        if let event = controller.eventForIndex(indexPath.row) {
            cell.labelTitle.text = event.title
            cell.labelDescription.text = event.description

            
            if event.liked {
                let img = UIImageView(image: UIImage(named: "fullHeart")!)
                cell.accessoryView = img
            }
            else {
                let img = UIImageView(image: UIImage(named: "emptyHeart")!)
                cell.accessoryView = img
            }
            
            if let interest = event.interest {
                if interest == 1 {
                    cell.labelInterest.text = "\(interest) person interested"
                }
                else {
                    cell.labelInterest.text = "\(interest) people interested"
                }
            }
            
            if let date = event.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                cell.labelSmallDate.text = formatter.string(from: date)
                
                formatter.dateFormat = "E, MMM dd at 'T'HH a"
                cell.labelFullDate.text = formatter.string(from: date)
            }
        }


        return cell
    }

    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if controller.canEditEventAtIndex(indexPath.row) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "AddEventViewController") as? AddEventViewController {
                if let row = tableView.indexPathForSelectedRow?.row {
                    vc.event = controller.eventForIndex(row)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        else {
            controller.likeEventForIndex(indexPath.row)
        }
    }
    
    

} // end class



extension EventsTableViewController: EventsControllerProtocol {

    func eventDataRefreshed() {
        self.updateUI()
    }
        
} // end extension
