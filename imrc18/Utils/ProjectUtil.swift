//
//  soundUtil.swift
//  new-guessOmeter
//
//  Created by Abhishek Soni on 11/29/15.
//  Copyright © 2015 Tekqube. All rights reserved.
//

import Foundation
import UIKit

let projectUtil = ProjectUtil();

class ProjectUtil: NSObject {
    let scheduleDictKey = "scheduleDict";
    
    class func getInstance() -> ProjectUtil {
        return projectUtil;
    }
    
    func getLocalDateTime() -> NSDate {
        let date = Date();
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.timeZone = TimeZone.current;
        let localStringDate = formatter.string(from: date);
        let localDate = formatter.date(from: localStringDate)! as NSDate;
        return localDate;
    }
    
    func setLastUpdatedAsNil() {
        UserDefaults.standard.set(nil, forKey: "lastUpdated");
    }
    
    func setLastUpdated() {
        UserDefaults.standard.set(getLocalDateTime(), forKey: "lastUpdated");
    }
    
    func isKeyExists(key : String) -> Bool {
        return UserDefaults.standard.data(forKey: key) != nil;
    }
    
    func resetStoredCache() {
        saveSchedulesDict(dict: NSMutableDictionary());
    }
    
    func getFavorites() -> NSMutableDictionary {
        let userDefaults = UserDefaults.standard;
        if (isKeyExists(key: "favorites")) {
            let data : NSData = (userDefaults.data(forKey: "favorites") as NSData?)!;
            let favDict : NSMutableDictionary = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSMutableDictionary;
            return favDict;
        }
        
        return NSMutableDictionary();
    }
    
    func saveFavorite(schedule : Schedule) {
        let userDefaults = UserDefaults.standard;
        var favDict : NSMutableDictionary = NSMutableDictionary();
        
        if (isKeyExists(key: "favorites")) {
            let data : NSData = (userDefaults.data(forKey: "favorites") as? NSData)!;
            favDict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSMutableDictionary;
        }
        
        let key : String = String(format: "%@-%@-%d", schedule.session, schedule.targetGroup, schedule.day);
        favDict.setValue(schedule, forKey: key);
        let saveData = NSKeyedArchiver.archivedData(withRootObject: favDict);
        
        userDefaults.set(saveData, forKey: "favorites");
        userDefaults.synchronize();
    }
    
    func removeFavorite(schedule : Schedule) {
        let userDefaults = UserDefaults.standard;
        
        let data : NSData = (userDefaults.object(forKey: "favorites") as? NSData)!;
        var favDict : NSMutableDictionary = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSMutableDictionary;
        
        if (favDict.count == 0) {
            favDict = NSMutableDictionary();
        }
        
        let key : String = String(format: "%@-%@-%d", schedule.session, schedule.targetGroup, schedule.day);
        favDict.removeObject(forKey: key);
        let saveData = NSKeyedArchiver.archivedData(withRootObject: favDict);
        
        userDefaults.set(saveData, forKey: "favorites");
        userDefaults.synchronize();
    }
    
    func isSameDay(date1 : NSDate, date2 : NSDate) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents( [.day, .month, .year], from: date1 as Date)
        let components2 = calendar.dateComponents( [.day, .month, .year], from: date2 as Date)
        
        return (components1.day == components2.day)
            && (components1.month == components1.month)
            && (components1.year == components2.year);
    }
    
    
    func returnDy(stringDate : String) -> Int {
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";
        formatter.timeZone = TimeZone.current;
        
        let date = formatter.date(from: stringDate)! as NSDate;
        var day : Int = 0;
        print("[GET Return Date] : %@", formatter.date(from: Constants.eventDate2)!);
        
        if (isSameDay(date1: date, date2: formatter.date(from: Constants.eventDate2)! as NSDate)) {
            day = 2;
        } else if (isSameDay(date1: date, date2: formatter.date(from: Constants.eventDate3)! as NSDate)) {
            day = 3;
        } else if (isSameDay(date1: date, date2: formatter.date(from: Constants.eventDate4)! as NSDate)) {
            day = 4;
        } else if (isSameDay(date1: date, date2: formatter.date(from: Constants.eventDate1)! as NSDate)) {
            day = 1;
        } else {
            day = 5;
        }
        
        return day;
    }
    
    func getOfficeDocumentPackage(fileName : String) -> BRAOfficeDocumentPackage {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        let documentsDirectory = documentPath[0];
        let path = String(format: "%@/%@.xlsx", documentsDirectory, fileName);
        
        var spreadsheet: BRAOfficeDocumentPackage? = nil
        do {
            spreadsheet = BRAOfficeDocumentPackage.open(path)
        } catch {
            // TODO: if file is not available copy from other location.
            print("nil")
        }
        
        return spreadsheet!;
    }

    func getSchedulesDict() -> NSMutableDictionary {
        let userDefaults = UserDefaults.standard;
        if (isKeyExists(key: scheduleDictKey)) {
            let data : NSData = userDefaults.data(forKey: scheduleDictKey)! as NSData;
            let favDict : NSMutableDictionary = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSMutableDictionary;
            return favDict;
        } else {
            saveSchedulesDict(dict: NSMutableDictionary());
        }
        
        return NSMutableDictionary();
    }
    
    func saveSchedulesDict(dict : NSMutableDictionary) {
        let userDefaults = UserDefaults.standard;
        let saveData = NSKeyedArchiver.archivedData(withRootObject: dict);
        
        userDefaults.set(saveData, forKey: scheduleDictKey);
        userDefaults.synchronize();
    }
    
    func processSessions(day: Int) -> NSMutableArray {
        let spreadsheet: BRAOfficeDocumentPackage = projectUtil.getOfficeDocumentPackage(fileName: String(format: "%@",Constants.scheduleFileName));
        
        if (spreadsheet.workbook != nil && spreadsheet.workbook.worksheets.count > 0) {
            let firstWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
            
            var schedules = NSMutableArray();
            
            let scheduleDict = NSMutableDictionary();
            
            var isLoopCompleted : Bool = true;
            let dayCol = "A";
            let time = "B";
            let startTime = "C";
            let endTime = "D";
            let eventName = "E";
            let location = "F";
            let description = "G"
            let teamResponsibility = "H";
            let volunteerName = "I";
            let volunteerPhone = "J";
            let speakerNames = "K";
            let speakerBios = "P";
            let targetGroup = "L";
            let eventStatus = "M";
            let eventImage = "O";

            var i = 4;
            var emptyLines = 0;
            var rowNum = 0;
            var prevDay = 0;
            
            while(isLoopCompleted) {
                if (firstWorksheet.cell(forCellReference: dayCol + "\(i)") != nil) {
                let dayDt = firstWorksheet.cell(forCellReference: dayCol + "\(i)").integerValue();
                
                let timeData = firstWorksheet.cell(forCellReference: time+"\(i)").stringValue();
                let startTimeData: String = firstWorksheet.cell(forCellReference: startTime+"\(i)").stringValue();
                let endTimeData: String = firstWorksheet.cell(forCellReference: endTime + "\(i)").stringValue();
                let eventNameData: String = firstWorksheet.cell(forCellReference: eventName + "\(i)").stringValue();
                let locationData: String = firstWorksheet.cell(forCellReference: location + "\(i)").stringValue();
                let descriptionData: String = firstWorksheet.cell(forCellReference: description + "\(i)").stringValue();
                let teamResponsibilityData: String = firstWorksheet.cell(forCellReference: teamResponsibility + "\(i)").stringValue();
                let volunteerNameData: String = firstWorksheet.cell(forCellReference: volunteerName + "\(i)").stringValue();
                    
                var volunteerPhoneData: String = "";
                    
                if (firstWorksheet.cell(forCellReference: volunteerPhone + "\(i)") != nil) {
                    volunteerPhoneData = (firstWorksheet.cell(forCellReference: volunteerPhone + "\(i)")?.stringValue())!;
                }
                
                    var speakerNameData: String = "";
                    
                if (firstWorksheet.cell(forCellReference: speakerNames + "\(i)") != nil) {
                     speakerNameData = firstWorksheet.cell(forCellReference: speakerNames + "\(i)").stringValue();
                }
                    
                var speakerBiosData: String = "";
                    
                if (firstWorksheet.cell(forCellReference: speakerBios + "\(i)") != nil) {
                    speakerBiosData = firstWorksheet.cell(forCellReference: speakerBios + "\(i)").stringValue();
                }
                    
                let targetGroupData: String = firstWorksheet.cell(forCellReference: targetGroup + "\(i)").stringValue();
                    
                    
                var eventImageData: String = "hotelmap";
                if (firstWorksheet.cell(forCellReference: eventImage + "\(i)") != nil) {
                     eventImageData = firstWorksheet.cell(forCellReference: eventImage + "\(i)").stringValue();
                    
                    if (eventImageData == "") {
                        eventImageData = "hotelmap";
                    }
                }
                    
                var eventStatusData: String = "SCHEDULE";
                if (firstWorksheet.cell(forCellReference: eventStatus + "\(i)") != nil) {
                    eventStatusData = firstWorksheet.cell(forCellReference: eventStatus + "\(i)").stringValue();
                        
                    if (eventStatusData == "") {
                        eventStatusData = "SCHEDULE";
                    }
                }
                
                if ((eventNameData != "") && dayDt != 0) {
                    prevDay = dayDt;
  
                    let schedule : Schedule = Schedule();
                    schedule.time = timeData! as NSString;
                    schedule.start24Time = startTimeData as NSString;
                    schedule.end24Time = endTimeData as! NSString;
                    
                    var timings = time.components(separatedBy: " - ");
                    if (timings.count > 1) {
                        schedule.startTime = timings[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString;
                        schedule.endTime = timings[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString;
                    } else {
                        timings = time.components(separatedBy: " ");
                        schedule.startTime = timings[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString;
                        schedule.endTime = "";
                    }
                    
                    schedule.room = ((locationData != nil && locationData != "") ? locationData : "") as NSString;
                    schedule.teamResponsibility = ((teamResponsibilityData != nil && teamResponsibilityData != "") ? teamResponsibilityData : "") as NSString;
                    schedule.session = ((eventNameData != nil && eventNameData != "") ? eventNameData : "") as NSString;
                    schedule.day = dayDt;
                    schedule.targetGroup = ((targetGroupData != nil && targetGroupData != "") ? targetGroupData : "") as NSString;
                    schedule.desc = ((descriptionData != nil && descriptionData != "") ? descriptionData : "") as NSString;
                    schedule.volunteerName = volunteerNameData as NSString;
                    schedule.volunteerPhone = volunteerPhoneData as NSString as NSString;
                    schedule.speakerName = speakerNameData as NSString;
                    schedule.speakerBio = speakerBiosData as NSString;
                    schedule.identifier = rowNum;
                    schedule.eventImage = eventImageData as NSString;
                    schedule.eventStatus = eventStatusData as NSString;

                    schedules.add(schedule);
                    rowNum += 1;
                    emptyLines = 0;
                } else {
                    if (dayDt == 0) {
                        rowNum = 0;
                        emptyLines += 1;
                    }
                    
                    if (prevDay != 0) {
                        scheduleDict.setValue(NSMutableArray(array: schedules), forKey: String(format: "%d",prevDay));
                        schedules = NSMutableArray();
                        rowNum = 0;
                        prevDay = 0;
                    }
                    
                    if (emptyLines > 6) {
                        isLoopCompleted = false;
                        break;
                    }
                }
                
                    i = i + 1;
                } else {
                    emptyLines += 1;
                    
                    if (emptyLines > 6) {
                        isLoopCompleted = false;
                        break;
                    }
                }
            }
            
            saveSchedulesDict(dict: scheduleDict);
            return (scheduleDict.object(forKey: String(format: "%d", day)) as? NSMutableArray)!;
        }
        
        return NSMutableArray();
    }
    
    func getSchedules(day : Int, type: String) -> NSMutableArray {
        var schedules = NSMutableArray();
        var updatedSchedules = NSMutableArray();
        
        if (!isKeyExists(key: scheduleDictKey)) {
            schedules = processSessions(day: day);
        } else {
            let scheduleDict = getSchedulesDict();
            let key = String(format: "%d", day);
            
            if (scheduleDict.value(forKey: key) != nil) {
                print(" [getSchedules] Values found for schedule.. ");
                schedules = scheduleDict.value(forKey: String(format:"%d",day)) as! NSMutableArray;
            } else {
                print (" [getSchedules] Values Not found for schedule.. ");
            }
            
            if (schedules.count == 0) {
                schedules = processSessions(day: day);
            }
        }
        
        for i in 0 ..< schedules.count {
            let schedule = schedules.object(at: i) as! Schedule;
            
            if (type == "SCHEDULE" && schedule.eventStatus == "SCHEDULE") {
                updatedSchedules.add(schedules.object(at: i));
            } else if (type == "HAPPENING_NOW") {
                updatedSchedules.add(schedules.object(at: i));
            }
        }
        
        return updatedSchedules;
    }
    
    func getEvents(day: Int, type: String) -> NSMutableArray {
        var schedules = NSMutableArray();
        
        schedules = getSchedules(day: day, type: type);
        
        return schedules;
    }
    
    func getEventsHappeningNow(day: Int, date: NSDate) -> NSMutableArray {
        let currentSessions = NSMutableArray();
        let schedules  = getEvents(day: day, type: "BOTH");
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current;
        let hourComp = calendar.dateComponents([.day , .hour , .minute , .second], from: date as Date)
        
        let hour : Float = Float(hourComp.hour!) + Float(hourComp.minute!) / 100;
        
        for i in 0 ..< schedules.count {
            let sched : Schedule = schedules[i] as! Schedule;
            if (sched.end24Time == "" || sched.end24Time == "0.00" || sched.end24Time == "0.0") {
                sched.end24Time = "23.59";
            }
            
            if (sched.start24Time.floatValue <= hour && sched.end24Time.floatValue >= hour) {
                currentSessions.add(schedules[i]);
            }
        }
        
        return currentSessions;
    }
    
    func getScheduleCell(tableView: UITableView, indexPath : NSIndexPath, schedule : Schedule, isFavoriteIncluded:Bool, isMySchedule: Bool, isMainView: Bool) -> ScheduleTableCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleTableViewCell", for: indexPath as IndexPath) as! ScheduleTableCell
        
        cell.title?.text = schedule.session as String
        cell.timing?.text = String(format: "%@, %@", schedule.time as String, schedule.room as String);
        
        if (isFavoriteIncluded) {
            if (isMainView) {
                let button: FavButton  = cell.fav as! FavButton;
                button.buttonId = String(format: "%d---%d", indexPath.section, indexPath.row);
            }
            else if (isMySchedule) {
                cell.fav!.tag = indexPath.row;
            } else {
                cell.fav!.tag = schedule.identifier;
            }
            
            let key : String = String(format: "%@-%@-%d", schedule.session, schedule.targetGroup, schedule.day);
            if (projectUtil.getFavorites().object(forKey: key) != nil) {
                cell.fav?.setImage(UIImage(named: "selectedFavorite"), for: UIControlState.normal);
            } else {
                cell.fav?.setImage(UIImage(named: "unSelectedFavorite"), for: UIControlState.normal);
            }
        }
        
        if (schedule.targetGroup.lowercased.range(of: "session") != nil) {
            cell.icon?.image = UIImage(named: "sessions");
        } else if (schedule.targetGroup.lowercased.range(of: "kids") != nil || schedule.targetGroup.lowercased.range(of: "rays") != nil) {
            cell.icon?.image = UIImage(named: "rays");
        } else if (schedule.targetGroup.lowercased.range(of: "sakhi") != nil) {
            cell.icon?.image = UIImage(named: "sakhi");
        } else if (schedule.targetGroup.lowercased.range(of: "seniors") != nil) {
            cell.icon?.image = UIImage(named: "seniors");
        } else if (schedule.targetGroup.lowercased.range(of: "entertainment") != nil) {
            cell.icon?.image = UIImage(named: "entertainment");
        } else if (schedule.targetGroup.lowercased.range(of: "food") != nil) {
            cell.icon?.image = UIImage(named: "eventFood");
        } else if (schedule.targetGroup.lowercased.range(of: "prayer") != nil) {
            cell.icon?.image = UIImage(named: "prayer");
        } else if (schedule.targetGroup.lowercased.range(of: "fitness") != nil) {
            cell.icon?.image = UIImage(named: "fitness");
        } else {
            cell.icon?.image = UIImage(named: "general");
        }
        
        return cell;
    }
    
    func resetDownloadFiles() {
        NSLog(" Reset Download files... ");
        
        var key = Constants.downloadScheduleFileKey;
        UserDefaults.standard.set(nil, forKey: key);
        
        print(">>> Value : %@", UserDefaults.standard.value(forKey: key) as? String as Any);
        
        key = Constants.downloadOtherFileKey;
        UserDefaults.standard.set(nil, forKey: key);
        
        print(">>> Value : %@", UserDefaults.standard.value(forKey: key) as? String as Any);
    }
    
    func canDownloadScheduleFile() -> Bool {
        print("[canDownloadScheduleFile] Can download the Schedule File ?");
        let key = Constants.downloadScheduleFileKey;
        print (" Is key Exists: %@", key);
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        let documentsDirectory = documentPath[0];
        let path = String(format: "%@/%@.xlsx", documentsDirectory, Constants.scheduleFileName);
        
        if (!FileManager.default.fileExists(atPath: URL(fileURLWithPath: path).path)) {
            NSLog(" File Does Not Exists.. Download file Now...");
            let app = UserDefaults.standard
            let date = getLocalDateTime();
            app.set(date, forKey: key)
            app.synchronize();
            return true;
        }
        
        if ((UserDefaults.standard.object(forKey: key) as? Date) != nil) {
            NSLog( "Key Exists in the System... ");
            let savedDate = UserDefaults.standard.object(forKey: key)
            let dateFormatter : DateFormatter = DateFormatter();
            dateFormatter.timeZone = TimeZone.current;
            dateFormatter.dateFormat = "H";
            
            let hour = dateFormatter.string(from: (savedDate! as! NSDate) as Date);
            print("Schedule.. Date Hour : %d", hour);
            
            // Check if the hour is same or not
            let saveDate = dateFormatter.string(from: Date() as Date );
            print("Schedule.. Saved Hour : %@", saveDate);
            if (saveDate != hour) {
                UserDefaults.standard.set(getLocalDateTime(), forKey: key);
                UserDefaults.standard.synchronize();
                return true;
            }
            
            return false;
        }
        
        print(" Key Does Not Exists..");
        let app = UserDefaults.standard
        let date = getLocalDateTime()
        app.set(date, forKey: key);
        UserDefaults.standard.synchronize();
        return true;
    }
    
    func getDay(today:String)->Int? {
        
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current;
        if let todayDate = formatter.date(from: today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let myComponents = myCalendar.components(.day, from: todayDate)
            let weekDay = myComponents.day
            return weekDay
        } else {
            return nil
        }
    }

    func canDownloadOtherFiles() -> Bool {
        let key = Constants.downloadOtherFileKey;
        let formatter  = DateFormatter()
        formatter.timeZone = TimeZone.current;
        formatter.dateFormat = "yyyy-MM-dd";
        
        let prev = UserDefaults.standard.object(forKey: key) as? Date;

        if (prev != nil) {
            NSLog( "Key Exists in the System... ");
            let dateFormatter : DateFormatter = DateFormatter();
            dateFormatter.dateFormat = "d";
            
            let prevDate  = dateFormatter.string(from: prev!);
            let todaysDate = dateFormatter.string(from: getLocalDateTime() as Date);
            
            // Check if the hour is same or not
            if (todaysDate != prevDate) {
                UserDefaults.standard.set(getLocalDateTime(), forKey: key);
                UserDefaults.standard.synchronize();
                return true;
            }
            
            return false;
        }
        
        print(" Key Does Not Exists..");

        // TODO Change this logic...
        let app = UserDefaults.standard
        let date = getLocalDateTime()
        app.set(date, forKey: key);
        UserDefaults.standard.synchronize();
        return true;
    }
}
