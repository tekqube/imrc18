//
//  ScheduleViewController.swift
//  imrc
//
//  Created by Abhishek Soni on 4/10/16.
//  Copyright © 2016 Tekqube. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView : UITableView?;
    @IBOutlet weak var bottomFilter : UIView?;
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView?;
    
    var schedules : NSMutableArray = [];
    var scheduleInfos : NSMutableArray = [];
    let textCellIdentifier = "TextCell";
    var day = 1;
    var firstWorksheet: BRAWorksheet = BRAWorksheet();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator?.isHidden = false;
        bottomFilter?.isUserInteractionEnabled = false;
        
//        let date = Date();
//        let formatter = DateFormatter();
//        formatter.dateFormat = "yyyy-MM-dd";
//        formatter.timeZone = TimeZone.current;
//        let dateString = formatter.string(from: date)
//        self.day = projectUtil.returnDy(stringDate: dateString);
//        if (self.day == 5) {
//            self.day = 1;
//        }
        
        NSLog(" Schedule View Controller Page...");
        
        let subview = view.viewWithTag(self.day)
        if subview is UIButton {
            let button = subview as! UIButton;
            button.backgroundColor = UIColor(hexString: "a00000")
            button.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NSLog(" View Did Appear... ");

        DispatchQueue.main.async {
            self.getSheetData(day: self.day);
        };
    }
    
    func getSheetData(day : Int) {
        NSLog(" Get Sheet Data ...");
        
        self.schedules = projectUtil.getSchedules(day: day, type: "SCHEDULE");
        self.tableView?.reloadData();
        activityIndicator?.isHidden = true;
        bottomFilter?.isUserInteractionEnabled = true;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog( "Table number of Rows :",schedules.count);
        return schedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let schedule = schedules[indexPath.row] as! Schedule;
        let cell = projectUtil.getScheduleCell(tableView: tableView, indexPath: indexPath as NSIndexPath, schedule: schedule, isFavoriteIncluded : true, isMySchedule: true, isMainView: false);
        return cell;
    }
    
    @IBAction func favSession(sender : UIButton!) {
        let schedule : Schedule = self.schedules [sender.tag] as! Schedule;
        let key : String = String(format: "%@-%@-%d", schedule.session, schedule.targetGroup, schedule.day);

        if (projectUtil.getFavorites().object(forKey: key) != nil) {
            sender?.setImage(UIImage(named: "unSelectedFavorite"), for: UIControlState.normal);
            projectUtil.removeFavorite(schedule: schedule);
        } else {
            sender?.setImage(UIImage(named: "selectedFavorite"), for: UIControlState.normal);
            projectUtil.saveFavorite(schedule: schedule);
        }
        
        getSheetData(day: schedule.day);
        self.tableView?.reloadData();
    }
    
    @IBAction func selectedDate(sender : UIButton!) {
        
        for subview in (self.bottomFilter?.subviews)! {
            if let button = subview as? UIButton {
                // this is a button
                if (button.tag >= 1 && button.tag <= 5){
                    button.backgroundColor = UIColor.white
                    button.setTitleColor(UIColor(hexString: "a00000"), for: .normal)
                } else {
                    NSLog("Tag  is not configured right")
                }
            }
        }
        
        self.day = (sender?.tag)!;
        sender.backgroundColor = UIColor(hexString: "a00000")
        sender.setTitleColor(UIColor.white, for: .normal)
        sender.titleLabel?.textColor = UIColor.white;
        self.getSheetData(day: (sender?.tag)!);
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "scheduleDetailView", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scheduleDetailView" {
            if let scheduleDetailViewController = segue.destination as? ScheduleDetailViewController {

                let indexPath : NSIndexPath = sender as! NSIndexPath
                let schedule : Schedule = self.schedules[indexPath.row] as! Schedule;
                scheduleDetailViewController.schedule = schedule;
                //scheduleDetailViewController.segueName = "goToScheduleViewController";
            }
        }
    }
}
