//
//  ScheduleTableCell.swift
//  imrc
//
//  Created by Abhishek Soni on 4/10/16.
//  Copyright © 2016 Tekqube. All rights reserved.
//

import UIKit

class WeatherTableCell : UITableViewCell {
    @IBOutlet weak var temp : UILabel?;
    @IBOutlet weak var date : UILabel?;
    @IBOutlet weak var skyType : UIImageView?;
    @IBOutlet weak var desc: UILabel?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}