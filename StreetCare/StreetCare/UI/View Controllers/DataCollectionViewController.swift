//
//  DataCollectionViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/3/22.
//

import UIKit

class DataCollectionViewController: UIViewController {

    var def: DataCollectionDefinition?
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var labelPrompt: UILabel!
    
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var stackNumber: UIStackView!
    @IBOutlet weak var labelStepper: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let def = self.def {
            labelPrompt.text =  Language.locString(def.prompt)
            
            switch def.type {
            case .Date:
                segment.removeFromSuperview()
                textInput.removeFromSuperview()
                stackNumber.removeFromSuperview()
            case .Text:
                segment.removeFromSuperview()
                stackNumber.removeFromSuperview()
            case .Number:
                segment.removeFromSuperview()
                textInput.removeFromSuperview()
            case .Selection:
                textInput.removeFromSuperview()
                stackNumber.removeFromSuperview()
            }
        }
                
    }
    
    
    @IBAction func stepper_valueChanged(_ sender: UIStepper) {
        labelStepper.text = Int(stepper.value).description
    }
    
    
} // end class
