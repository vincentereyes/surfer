//
//  messageCell.swift
//  SurfApp
//
//  Created by Vince Reyes on 7/17/18.
//  Copyright © 2018 VinceReyes. All rights reserved.
//

import UIKit

class messageCell: UITableViewCell {
    
    @IBOutlet weak var msgLbl: UILabel!
    
    @IBOutlet weak var iconLbl: UILabel!

    @IBOutlet weak var timeLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
