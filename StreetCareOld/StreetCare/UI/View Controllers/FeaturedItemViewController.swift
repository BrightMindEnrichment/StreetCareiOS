//
//  FeaturedItemViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/2/22.
//

import UIKit

class FeaturedItemViewController: UIViewController {

    private let controller = FeaturedItemController.shared
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let indexPath = tableView.indexPathForSelectedRow {
            
            guard let item = controller.featuredItemAtIndex(indexPath.row) else {
                // noting selected, abort
                return
            }

            if let vc = segue.destination as? InfoSheetViewController {
                vc.featuredItem = item
            }
        }
    }
} // end class



extension FeaturedItemViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "howToHelpCell") as? HowToHelpTableViewCell else {
            preconditionFailure("Missing cell - check tag in storyboard")
        }
        
        if let item = controller.featuredItemAtIndex(indexPath.row) {
            cell.textTitle.text = Language.locString(item.title)
            cell.imageIcon.image = UIImage(named: item.imageName)
        }
        
        return cell
    }
    
    
} // end extension
