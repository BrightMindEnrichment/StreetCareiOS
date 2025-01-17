//
//  LogVisitViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/3/22.
//

import UIKit
import FirebaseAuth


class LogVisitViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var controller = LogVisitController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
//        guard let _ = Auth.auth().currentUser else {
//            self.presentInformationAlertWithTitle(Language.locString("loginButtonTitle"), message: Language.locString("guestCantLogVisitError")) { alertAction in
//                self.navigationController?.popViewController(animated: true)
//            }
//            return
//        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            
            let definition = controller.definitionForIndex(indexPath.row)

            if let vc = segue.destination as? DataCollectionViewController {
                vc.def = definition
                vc.onSave = controller.saveClosureForIndex(indexPath.row)
            }
        }
    }
    
    
    
    @IBAction func buttonSave_touched(_ sender: Any) {
    
        if let _ = Auth.auth().currentUser {
            controller.save()
            self.navigationController?.popViewController(animated: true)
        }
        else {
            let alert = UIAlertController(title: "Anonymous", message: "Logging a visit with out logging in may result in you being unable to view your visit history.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                self.controller.save()
                self.navigationController?.popToRootViewController(animated: true)
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            
            self.present(alert, animated: true, completion: {})
        }
        
    }
    
    
} // end class



extension LogVisitViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let def = controller.definitionForIndex(indexPath.row)
        

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "visitLogDataCollectionCell") else {
            preconditionFailure()
        }
        
        var content = cell.defaultContentConfiguration()
        
        content.text = Language.locString(def.prompt)
        content.secondaryText = def.dataDisplay
        
        cell.contentConfiguration = content

        return cell
    }


    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("clicked row")
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let background = UIView()
        background.backgroundColor = UIColor(named: "Color-Accent1")
        
        let lbl = UILabel()
        lbl.text = Language.locString("afterOutreachIntro")
        lbl.numberOfLines = 3
        
        lbl.translatesAutoresizingMaskIntoConstraints = false

        background.addSubview(lbl)

        let viewsDict = [
            "lbl" : lbl,
            ] as [String : Any]
        
        
        background.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[lbl]-8-|", options: [], metrics: nil, views: viewsDict))
        background.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[lbl]-8-|", options: [], metrics: nil, views: viewsDict))
        
        return background
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 88.0
    }
    
} // end extension
