//
//  HotelMapViewController.swift
//  imrc18
//
//  Created by Shruti Bihani on 6/23/18.
//  Copyright © 2018 Erica Millado. All rights reserved.
//
//

import Foundation

class HotelMapViewController : UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var imageView: UIImageView!;
    @IBOutlet weak var scrollImg: UIScrollView!;
    @IBOutlet weak var defaultView: UIView!;
    
    override func viewDidLoad() {
        scrollImg.minimumZoomScale = 1.0
        scrollImg.maximumZoomScale = 10.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView;
    }
}
