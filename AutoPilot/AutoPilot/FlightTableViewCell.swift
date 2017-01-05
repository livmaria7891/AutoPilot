//
//  FlightTableViewCell.swift
//  AutoPilot
//
//  Created by Olivia Legge on 1/5/17.
//  Copyright © 2017 Olivia Legge. All rights reserved.
//

import UIKit

class FlightTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var flightName: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var favoriteImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
