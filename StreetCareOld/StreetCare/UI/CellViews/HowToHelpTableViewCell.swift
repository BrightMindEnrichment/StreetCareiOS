//
//  HowToHelpTableViewCell.swift
//  StreetCare
//
//  Created by Michael Thornton on 4/29/22.
//

import UIKit

class HowToHelpTableViewCell: UITableViewCell {

    @IBOutlet weak var imageIcon: UIImageView!    
    @IBOutlet weak var textTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
