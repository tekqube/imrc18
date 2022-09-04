//
//  ScheduleTableCell.swift
//  imrc
//
//  Created by Abhishek Soni on 4/10/16.
//  Copyright © 2016 Tekqube. All rights reserved.
//

import UIKit

class ScheduleTableCell : UITableViewCell {
    @IBOutlet weak var icon : UIImageView?;
    @IBOutlet weak var timing : UILabel?;
    @IBOutlet weak var title : UILabel?;
    @IBOutlet weak var fav : UIButton?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
