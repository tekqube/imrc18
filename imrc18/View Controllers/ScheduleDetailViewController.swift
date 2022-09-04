//
//  ScheduleDetailViewController.swift
//  imrc
//
//  Created by Abhishek Soni on 5/21/16.
//  Copyright © 2016 Tekqube. All rights reserved.
//

import Foundation

class ScheduleDetailViewController: UIViewController, UIScrollViewDelegate {
    var schedule : Schedule = Schedule();
    @IBOutlet weak var eventName : UILabel?;
    @IBOutlet weak var date : UILabel?;
    @IBOutlet weak var venue : UILabel?;
    @IBOutlet weak var desc : UITextView?;
    @IBOutlet weak var fav : UIButton?;
    @IBOutlet weak var volunteerName: UILabel?;
    @IBOutlet weak var volunteerPhone: UIButton?;
    @IBOutlet weak var speakerView: UIView?;
    @IBOutlet weak var speakerNameButton: UIButton?;
    @IBOutlet weak var eventImage: UIImageView?;
    @IBOutlet weak var scrollImg: UIScrollView!;
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.eventImage;
    }
    
    var segueName : String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad();
        var dy = "";
        if (schedule.day == 1) {
            dy = "Saturday";
        } else if (schedule.day == 2) {
            dy = "Sunday";
        } else if (schedule.day == 3) {
            dy = "Monday";
        } else {
            dy = "Tuesday";
        }
        
        eventName?.text = String(format: "%@",schedule.session as String);
        date?.text = String(format: "%@, %@", dy, schedule.time as String);
        venue?.text = String(format: "%@", schedule.room as String);
        if (schedule.desc.length > 0) {
            desc?.text = schedule.desc as String;
//            desc?.sizeToFit();
//            self.view?.layoutIfNeeded()
        } else {
            desc?.isHidden = true;
//            self.view?.layoutIfNeeded()
        }
        
        scrollImg.minimumZoomScale = 1.0
        scrollImg.maximumZoomScale = 10.0
        
        volunteerName?.text = schedule.volunteerName as String;
        let speakerNameText = schedule.speakerName as String;
        
        eventImage?.image = UIImage(named: schedule.eventImage as String)
        
        if (!(speakerNameText).isEmpty) {
            speakerNameButton?.setTitle(speakerNameText.split(separator: "\n").joined(separator: ", "), for: .normal);
        } else {
            speakerView?.isHidden = true;
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
        }
        
        let key : String = String(format: "%@-%@-%d", schedule.session, schedule.targetGroup, schedule.day);
        
        if (projectUtil.getFavorites().object(forKey: key) != nil) {
            fav?.setImage(UIImage(named: "selectedFavorite"), for: UIControlState.normal);
        }
    }
    
    @IBAction func callVolunteer(sender : AnyObject?) {
        let phone = schedule.volunteerPhone as String;
        if !(phone).isEmpty {
            if let phoneCallURL:URL = URL.init(string: "tel://\(schedule.volunteerPhone)") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    application.open(phoneCallURL, options: [:]);
                }
            }
        } else {
            let title = "Call Volunteer";
            let message = "Phone number not available for this volunteer.";
            
            let alertController = UIAlertController(title: title, message:
                message, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil));
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func goToSchedule(sender : AnyObject?) {
        self.performSegue(withIdentifier: segueName, sender: sender);
    }
    
    func favorite(){
        let key : String = String(format: "%@-%@-%d", schedule.session, schedule.targetGroup, schedule.day);
        
        if (projectUtil.getFavorites().object(forKey: key) != nil) {
            fav?.setImage(UIImage(named: "unSelectedFavorite"), for: UIControlState.normal);
            projectUtil.removeFavorite(schedule: schedule);
        } else {
            fav?.setImage(UIImage(named: "selectedFavorite"), for: UIControlState.normal);
            projectUtil.saveFavorite(schedule: schedule);
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scheduleDetailView" {
            if let scheduleDetailViewController = segue.destination as? ScheduleViewController {
                scheduleDetailViewController.day = schedule.day;
            }
        } else if segue.identifier == "myScheduleDetailView" {
            if let myScheduleDetailViewController = segue.destination as? MyScheduleViewController {
                myScheduleDetailViewController.day = schedule.day;
            }
        } else if segue.identifier == "speakerDetailView" {
            if let speakerInfoViewController = segue.destination as? SpeakerInfoViewController {
                speakerInfoViewController.bios = schedule.speakerBio as String;
            }
        }
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func favSession(sender : UIButton!) {
        favorite();
    }
    
}
