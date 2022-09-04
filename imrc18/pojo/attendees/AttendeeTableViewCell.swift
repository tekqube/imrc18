//
//  AttendeeTableViewCell.swift
//  imrc
//
//  Created by Abhishek Soni on 5/13/16.
//  Copyright © 2016 Tekqube. All rights reserved.
//

import UIKit

class AttendeeTableViewCell : UITableViewCell {
    @IBOutlet weak var name : UILabel?;
    @IBOutlet weak var chapterName : UILabel?;
    @IBOutlet weak var lastName : UILabel?;
    @IBOutlet weak var location : UILabel?;
    @IBOutlet weak var phone : UIButton?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
