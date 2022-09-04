//
//  MyScheduleViewController.swift
//  imrc
//
//  Created by Abhishek Soni on 4/10/16.
//  Copyright © 2016 Tekqube. All rights reserved.
//

import UIKit

class MyScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView : UITableView?;
    @IBOutlet weak var bottomFilter : UIView?;
    @IBOutlet weak var label : UILabel?;
    var day = 1;
    var schedules : NSMutableArray = [];
    let textCellIdentifier = "TextCell"
    
    var scheduleInfos: NSArray = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduleInfos = projectUtil.getFavorites().allValues as NSArray;
        
        let subview = view.viewWithTag(day)
        if subview is UIButton {
            let button = subview as! UIButton;
            button.backgroundColor = UIColor(hexString: "a00000")
            button.setTitleColor(UIColor.white, for: .normal)
        }
        
        filterSchedules(day: day);
    }
    
    func filterSchedules(day : Int) {
        schedules.removeAllObjects();
        
        var rowNum = 0;
        for i in 0 ..< scheduleInfos.count {
            let schedule = scheduleInfos[i] as! Schedule;
            if (schedule.day == day) {
                let schedule : Schedule = (scheduleInfos[i] as? Schedule)!;
                schedule.identifier = rowNum;
                rowNum += 1;
                schedules.add(schedule);
            }
        }
        
        let testSchedules : NSArray = schedules.sortedArray {
            (p1, p2) -> ComparisonResult in
                if (p1 as! Schedule).start24Time.floatValue > (p2 as! Schedule).start24Time.floatValue {
                    return ComparisonResult.orderedDescending
                }
            
                if (p1 as! Schedule).start24Time.floatValue > (p2 as! Schedule).start24Time.floatValue {
                    return ComparisonResult.orderedAscending
                }
            return ComparisonResult.orderedAscending
            } as NSArray
        
        schedules = NSMutableArray(array: testSchedules);
        
        if (schedules.count == 0) {
            label?.isHidden = false;
        } else {
            label?.isHidden = true;
        }
        
        self.tableView?.reloadData();
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let schedule = schedules[indexPath.row] as! Schedule;
        let cell = projectUtil.getScheduleCell(tableView: tableView, indexPath: indexPath as NSIndexPath, schedule: schedule, isFavoriteIncluded : true, isMySchedule:  true, isMainView: false);
        return cell;
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
        filterSchedules(day: (sender?.tag)!);
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
        
        filterSchedules(day: schedule.day);
        self.tableView?.reloadData();
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "myScheduleDetailView", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myScheduleDetailView" {
            if let scheduleDetailViewController = segue.destination as? ScheduleDetailViewController {
                
                let indexPath : NSIndexPath = sender as! NSIndexPath
                let schedule : Schedule = self.schedules[indexPath.row] as! Schedule;
                scheduleDetailViewController.schedule = schedule;
            }
        }
    }
    
}
