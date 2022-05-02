//
//  InfoSheetViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/2/22.
//

import UIKit

class InfoSheetViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var textView: UITextView!

    public var featuredItem: FeaturedItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        if let featuredItem = featuredItem {
            image.image = UIImage(named: featuredItem.imageName)
            textView.text = Language.locString(featuredItem.description)
        }
    }
} // end class
