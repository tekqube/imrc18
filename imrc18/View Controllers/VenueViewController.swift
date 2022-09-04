//
//  VenueViewController.swift
//  imrc18
//
//  Created by Shruti Bihani on 6/11/18.
//  Copyright © 2018 Erica Millado. All rights reserved.
//

import Foundation

class VenueViewController : UIViewController {

    @IBAction func openInMap(sender : AnyObject?) {
        let url = "http://maps.apple.com/maps?saddr=37.390217,-121.974281"
        UIApplication.shared.open(URL(string:url)!, options: [:])
    }

    @IBAction func openWebsite(sender: AnyObject?) {
        if let url = URL(string: "https://www.marriott.com/hotels/hotel-photos/sjcga-santa-clara-marriott/") {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
