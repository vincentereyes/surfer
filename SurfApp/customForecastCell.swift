//
//  customForecastCell.swift
//  SurfApp
//
//  Created by Vince Reyes on 7/31/18.
//  Copyright © 2018 VinceReyes. All rights reserved.
//

import UIKit

class customForecastCell: UITableViewCell {
    
    @IBOutlet weak var tempLbl1: UILabel!

    @IBOutlet weak var tempLbl2: UILabel!
    
    @IBOutlet weak var waveHeight1: UILabel!
    
    @IBOutlet weak var waveHeight2: UILabel!
    
    @IBOutlet weak var ratingLbl: UILabel!
    
    @IBOutlet weak var imageViewBoyyy: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(linkTapped(sender:)))
        imageViewBoyyy.addGestureRecognizer(tapGestureRecognizer)
        imageViewBoyyy.isUserInteractionEnabled = true
        // Initialization code
    }
    
    @objc func linkTapped(sender:UITapGestureRecognizer) {
        let url = URL(string: "http://magicseaweed.com")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
