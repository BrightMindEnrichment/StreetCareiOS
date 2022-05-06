//
//  PlaylistsViewController.swift
//  Gym
//
//  Created by Michael Thornton on 5/26/20.
//  Copyright © 2020 Michael Thornton. All rights reserved.
//

import UIKit

class PlaylistsViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let controller = InformationCategoryController.shared

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    
    override public var shouldAutorotate: Bool {
      return false
    }
    
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        return .portrait
    }
    
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let indexPath = tableView.indexPathForSelectedRow {
            
            guard let category = controller.informationCategoryAtIndex(indexPath.row) else {
                // noting selected, abort
                return
            }

            if let vc = segue.destination as? YouTubeViewController {
                vc.playlistId = category.playlistId
                vc.title = category.title
            }
        }
    }
    

} // end class



extension PlaylistsViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCellView") else {
            preconditionFailure("Can't find cell view.  Check storyboard")
        }

        if let category = controller.informationCategoryAtIndex(indexPath.row) {
            cell.textLabel?.text = category.title
        }
        
        return cell
    }
    
} // end extension
