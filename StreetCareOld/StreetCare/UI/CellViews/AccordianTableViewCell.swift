//
//  AccordianTableViewCell.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/17/22.
//

import UIKit

class AccordianTableViewCell: UITableViewCell {

    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetails: UILabel!
    @IBOutlet weak var imageState: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

} // end class
