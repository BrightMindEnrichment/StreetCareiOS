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


    typealias SaveClosure = (Any) -> Void
    var onSave: SaveClosure?

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
                if let displayData = def.dataDisplay {
                    textInput.text = displayData
                }
                segment.removeFromSuperview()
                stackNumber.removeFromSuperview()
            case .Number:
                
                if let value = def.dataDisplay {
                    if let num = Double(value) {
                        stepper.value = num
                        labelStepper.text = value
                    }
                }
                segment.removeFromSuperview()
                textInput.removeFromSuperview()
            case .Selection:
                textInput.removeFromSuperview()
                stackNumber.removeFromSuperview()
                
                if let options = def.options {
                    
                    let font = UIFont.preferredFont(forTextStyle: .title2)
                    segment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
                    segment.removeAllSegments()
                    
                    var index = 0
                    for option in options {
                        segment.insertSegment(withTitle: option, at: index, animated: false)
                        index += 1
                    }
                    
                    if let dataDisplay = def.dataDisplay, let i = Int(dataDisplay) {
                        segment.selectedSegmentIndex = i
                    }
                    
                }
                else {
                    segment.removeFromSuperview()
                }
            }
        }
                
    }
    
    
    @IBAction func stepper_valueChanged(_ sender: UIStepper) {
        labelStepper.text = Int(stepper.value).description
    }
    
    
    
    @IBAction func buttonSave_touched(_ sender: UIButton) {
    
        if let def = def {
            switch def.type {
            case .Date:
                return
            case .Text:
                if let text = textInput.text {
                    onSave?(text)
                }
            case .Number:
                onSave?(Int(stepper.value))
            case .Selection:
                onSave?(segment.selectedSegmentIndex.description)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
} // end class
