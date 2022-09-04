//
//  TeamTableViewCell.swift
//  imrc
//
//  Created by Abhishek Soni on 5/14/16.
//  Copyright © 2016 Tekqube. All rights reserved.
//

import Foundation

class TeamsTableViewCell : UITableViewCell {
    @IBOutlet weak var teamName : UILabel?;
    @IBOutlet weak var contactName : UILabel?;
    @IBOutlet weak var phone : UIButton?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
