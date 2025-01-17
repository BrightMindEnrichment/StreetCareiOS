//
//  StartNowViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/16/22.
//

import UIKit

class StartNowViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var options = ["before", "onTheStreet", "after"]
    


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    


    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectAll()
    }

} // end class



extension StartNowViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "startNowCell") else {
            preconditionFailure("can't find cell view")
        }
        
        var content = cell.defaultContentConfiguration()
        content.text = Language.locString(options[indexPath.row])
        cell.contentConfiguration = content
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "AccordianViewController") as? AccordianViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 1:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "PlaylistsViewController") as? PlaylistsViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 2:
            self.tabBarController?.selectedIndex = 1
        default:
            print("should never happen:")
        }
    }
    
} // end extension
