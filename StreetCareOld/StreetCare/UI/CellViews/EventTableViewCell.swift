//
//  EventTableViewCell.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/5/22.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    
    @IBOutlet weak var labelSmallDate: UILabel!
    
    @IBOutlet weak var labelFullDate: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelInterest: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
