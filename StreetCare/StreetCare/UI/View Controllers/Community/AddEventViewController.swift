//
//  AddEventViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 6/23/22.
//

import UIKit
import FirebaseAuth

class AddEventViewController: UIViewController {

    
    
    @IBOutlet weak var textTitle: UITextField!
    
    @IBOutlet weak var textDescription: UITextView!
    @IBOutlet weak var dateEvent: UIDatePicker!
    @IBOutlet weak var buttonSave: UIButton!
    
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textDescription.layer.borderWidth = 1.0
        self.textDescription.layer.cornerRadius = 8.0
        self.textDescription.layer.borderColor = UIColor.systemGray4.cgColor
        
        if let event = self.event {
            self.textTitle.text = event.title
            self.textDescription.text = event.description
            self.dateEvent.date = event.date ?? Date()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        guard let _ = Auth.auth().currentUser else {
            self.presentInformationAlertWithTitle(Language.locString("loginButtonTitle"), message: "guestCantCommunityError") { alertAction in
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
    }

    @IBAction func buttonSave_touched(_ sender: UIButton) {
        
        let controller = EventsController()
        
        guard let title = textTitle.text, let description = textDescription.text else {
            self.presentInformationAlertWithTitle(Language.locString("errorTitle"), message: Language.locString("missingDataError"))
            return
        }
        
        let date = dateEvent.date
        
        controller.addEvent(title: title, description: description, date: date)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
} // end class
