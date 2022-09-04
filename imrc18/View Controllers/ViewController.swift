//
//  ViewController.swift
//  HamburgerMenuBlog
//
//  Created by Erica Millado on 7/15/17.
//  Copyright © 2017 Erica Millado. All rights reserved.
//

import UIKit

let reuseIdentifier = "categoryType";

class FavButton: UIButton {
    var buttonId : String?
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView : UITableView!;
    @IBOutlet weak var scheduleButton : UIButton?;
    @IBOutlet weak var loadingView : UIView!;
    @IBOutlet weak var instructionsView : UIView!;
    
    var scheduleDownloadInProgress : Bool = false;
    var teamContactDownloadInProgress : Bool = false;
    var sponsorsInformationDownloadInProgress : Bool = false;
    var speakerDataDownloadInProgress: Bool = false;
    var foodMenuDownloadInProgress : Bool = false;
    var attendeeListDownloadInProgress : Bool = false;
    
    let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0);
    let items : NSMutableArray = ["schedule", "myschedule", "meetpeople", "venue", "food", "weather",  "gallery", "videos", "social"];
    
    var sections : NSMutableArray = [];
    var schedules : NSMutableArray = [];

    var screenSize : CGSize = CGSize();
    var day = 0;
    var currentSessions : NSMutableArray = NSMutableArray();
    var totalHeight = UIScreen.main.nativeBounds.height - 44;
    
    @IBOutlet var leadingC: NSLayoutConstraint!
    @IBOutlet var trailingC: NSLayoutConstraint!
    
    @IBOutlet var ubeView: UIView!
    
    var hamburgerMenuIsVisible = false
    
    func copyBackupOrBundlePath(fileName: String) {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        let documentsDirectory = documentPath[0];
        let copyTopath = String(format: "%@/%@.xlsx", documentsDirectory, fileName);
        let backupPath = String(format: "%@/%@backup.xlsx", documentsDirectory, fileName);
        
        if (FileManager.default.fileExists(atPath: URL(fileURLWithPath: backupPath).path)) {
            do {
                try FileManager.default.copyItem(at: URL(fileURLWithPath: backupPath), to: URL(fileURLWithPath: copyTopath));
                self.updateFileDownload(fileName: fileName);
            } catch {
                self.updateFileDownload(fileName: fileName);
                // TODO Copy the file from Bundle path to this location...
                print (" Unable to Make the Backup the file ");
            }
        } else {
            let bundlePath = Bundle.main.path(forResource: fileName, ofType: "xlsx")
            do {
                try FileManager.default.copyItem(at: URL(fileURLWithPath: bundlePath!), to: URL(fileURLWithPath: copyTopath));
                self.updateFileDownload(fileName: fileName);
            } catch {
                // TODO Copy the file from Bundle path to this location...
                self.updateFileDownload(fileName: fileName);
                print (" Unable to Copy the bundle to Copy to path ");
            }
        }
    }
    
    func downloadFile(fileUrl: String, fileName : String, extensionFile: String) {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        let documentsDirectory = documentPath[0];
        let path = String(format: "%@/%@.xlsx", documentsDirectory, fileName);
        
        let requestURL = URL.init(string: fileUrl);
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = try! URLRequest(url: requestURL!);
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if (error == nil) {
                // Make sure data is available..
                if (tempLocalUrl != nil) {
                    do {
                        if (FileManager.default.fileExists(atPath: URL(fileURLWithPath: path).path)) {
                            let backupPath = String(format: "%@/%@backup.xlsx", documentsDirectory, fileName);
                            
                            if (!FileManager.default.fileExists(atPath: URL(fileURLWithPath: backupPath).path)) {
                                do {
                                    try FileManager.default.copyItem(at: URL(fileURLWithPath: path), to: URL(fileURLWithPath: backupPath));
                                } catch {
                                    // TODO Copy the file from Bundle path to this location...
                                    print (" Unable to copy the file ");
                                }
                            }
                        
                            do {
                                try FileManager.default.removeItem(at: URL(fileURLWithPath: path))
                            } catch {
                                self.copyBackupOrBundlePath(fileName: fileName);
                                // TODO Copy the file from Bundle path to this location...
                                print (" Unable to Make the Backup the file ");
                            }
                        }
                        
                        do {
                            try FileManager.default.copyItem(at: tempLocalUrl!, to: URL(fileURLWithPath: path));
                        } catch {
                            self.copyBackupOrBundlePath(fileName: fileName);
                            // TODO Copy the file from Bundle path to this location...
                            print (" Unable to copy the file ");
                        }
                        
                        // If local Path is not available then use the local file..
                        //print("Downloaded file to %@", tempLocalUrl?)
                    
                        // Reset Session..
                        if (fileName.contains(Constants.scheduleFileName)) {
                            NSLog("Schedule file Download Done..");
                            projectUtil.saveSchedulesDict(dict: NSMutableDictionary());
                        } else if (fileName.contains(Constants.teamFileName)) {
                            NSLog("Team file Download Done..");
                            self.teamContactDownloadInProgress = false;
                        } else if (fileName.contains(Constants.sponsorListFileName)) {
                            NSLog("Sponsor file Download Done..");
                            self.sponsorsInformationDownloadInProgress = false;
                        } else if (fileName.contains(Constants.foodMenuFileName)) {
                            NSLog("FoodMenu file Download Done..");
                            self.foodMenuDownloadInProgress = false;
                        } else if (fileName.contains(Constants.attendeeListFileName)) {
                            NSLog("Attendee file Download Done..");
                            self.attendeeListDownloadInProgress = false;
                        }
                        
                        self.updateFileDownload(fileName: (response?.suggestedFilename)!);
                    } catch (let writeError) {
                        // TODO Copy:
                        self.copyBackupOrBundlePath(fileName: fileName);
                        print("error writing file \(tempLocalUrl) : \(writeError)")
                    }
                } else {
                    print(" File Path Not Found...");
                    self.copyBackupOrBundlePath(fileName: fileName);
                }
            } else {
                print(" Error Description : %@", error!);
                self.copyBackupOrBundlePath(fileName: fileName);
            }
        };
        task.resume();
    }
    
    func downloadScheduleFile() {
        print(" [DownloadSchedule] can Download Schedule..");
        
        if (projectUtil.canDownloadScheduleFile()) {
            print(" [DownloadSchedule] Download Schedule Files...");
            loadingView.isHidden = false;
            scheduleDownloadInProgress = true;
            
            downloadFile(fileUrl: Constants.scheduleFile, fileName: Constants.scheduleFileName, extensionFile: Constants.extensionName);
            projectUtil.resetStoredCache();
        } else {
            print(" [DownloadSchedule] Don't Download Schedule Files...");
            updateFileDownload(fileName: Constants.scheduleFileName);
        }
    }
    
    func downloadOtherFiles() {
        NSLog(" [DownloadOtherFiles] can Download Other Files..");
        
        if (projectUtil.canDownloadOtherFiles()) {
            NSLog(" [DownloadOtherFiles] download Other Files..");
            
            loadingView.isHidden = false;
            teamContactDownloadInProgress = true;
            
            downloadFile(fileUrl: Constants.teamPointOfContactList, fileName: Constants.teamFileName, extensionFile: Constants.extensionName);
            
            sponsorsInformationDownloadInProgress = true;
            
            downloadFile(fileUrl: Constants.sponsorInformationFile, fileName: Constants.sponsorListFileName, extensionFile: Constants.extensionName);
            
            foodMenuDownloadInProgress = true;
            downloadFile(fileUrl: Constants.foodMenuFile, fileName: Constants.foodMenuFileName, extensionFile: Constants.extensionName);
            
            attendeeListDownloadInProgress = true;
            downloadFile(fileUrl: Constants.attendeeListFile, fileName:  Constants.attendeeListFileName, extensionFile: Constants.extensionName);
            
        } else {
            NSLog(" [DownloadOtherFiles] Don't download Other Files..");
            updateFileDownload(fileName: Constants.teamFileName);
        }
    }
    
    func updateFileDownload(fileName : String) {
        NSLog(" [UpdateFileDownload] >>>>>>>>>> FILE :", fileName);
        
        if (fileName.contains(Constants.scheduleFileName)) {
            NSLog("Schedule file Download Done..");
            scheduleDownloadInProgress = false;
        } else if (fileName.contains(Constants.teamFileName)) {
            NSLog("Team file Download Done..");
            teamContactDownloadInProgress = false;
        } else if (fileName.contains(Constants.sponsorListFileName)) {
            NSLog("Sponsor file Download Done..");
            sponsorsInformationDownloadInProgress = false;
        } else if (fileName.contains(Constants.speakerListFileName)) {
            NSLog("Speaker file Download Done..");
            speakerDataDownloadInProgress = false;
        } else if (fileName.contains(Constants.foodMenuFileName)) {
            NSLog("FoodMenu file Download Done..");
            foodMenuDownloadInProgress = false;
        } else if (fileName.contains(Constants.attendeeListFileName)) {
            NSLog("Attendee file Download Done..");
            attendeeListDownloadInProgress = false;
        }
        
        // when none of the download is in progress stop the the activity Monitor..
        if (!scheduleDownloadInProgress && !teamContactDownloadInProgress && !sponsorsInformationDownloadInProgress &&
            !speakerDataDownloadInProgress && !foodMenuDownloadInProgress && !attendeeListDownloadInProgress) {
            
            DispatchQueue.main.async {
                self.loadingView.isHidden = true;
                // Check if data available & store it..
                if (self.day == 5) {
                    self.day = 1;
                }
                
                let updatedSchedules = projectUtil.getEvents(day: self.day, type: "HAPPENING_NOW");
                
                var calendar = Calendar.current
                calendar.timeZone = TimeZone.current;
                let hourComp = calendar.dateComponents([.day , .hour , .minute , .second], from: NSDate() as Date)
                let hour : Float = Float(hourComp.hour!) + Float(hourComp.minute!) / 100;
                
                let currentSessions : NSMutableArray = [];
                let kidsEvent : NSMutableArray = [];
                let raysEvent : NSMutableArray = [];
                let generalEvent : NSMutableArray = [];
                let entertainmentEvent : NSMutableArray = [];
                let sessionEvent : NSMutableArray = [];
                
                for i in 0 ..< updatedSchedules.count {
                    let sched = updatedSchedules.object(at: i) as! Schedule;
                    
                    if (sched.end24Time == "" || sched.end24Time == "0.00" || sched.end24Time == "0.0") {
                        
                        if (sched.start24Time == "0.00" || sched.start24Time == "0.0") {
                            // skip;
                        } else {
                            sched.end24Time = "23.59";
                        }
                    }
                    
                    if (sched.start24Time.floatValue <= hour && sched.end24Time.floatValue >= hour) {
                        currentSessions.add(sched);
                    }
                    
                    if (sched.start24Time.floatValue <= hour) {
                        continue;
                    }
                    
                    if (sched.targetGroup.lowercased == "rays") {
                        raysEvent.add(sched);
                    }
                    
                    if (sched.targetGroup.lowercased == "kids") {
                        kidsEvent.add(sched);
                    }
                    
                    if (sched.targetGroup.lowercased == "general") {
                        generalEvent.add(sched);
                    }
                    
                    if (sched.targetGroup.lowercased == "entertainment") {
                        entertainmentEvent.add(sched);
                    }
                    
                    if (sched.targetGroup.lowercased == "session") {
                        sessionEvent.add(sched);
                    }
                }
                
                self.loadingView.isHidden = true;
                if (self.day == 5) {
                    self.tableView.isHidden = true;
                } else {
                    self.scheduleButton?.isHidden = true;
                    
                    self.sections = ["What's Happening Now", "Rays", "General", "Session", "Entertainment", "Kids"];
                    self.schedules.add(currentSessions);
                    self.schedules.add(raysEvent);
                    self.schedules.add(sessionEvent);
                    self.schedules.add(entertainmentEvent);
                    self.schedules.add(generalEvent)
                    self.schedules.add(kidsEvent);

                    self.tableView.reloadData();
                    print(" End DATE: %@", Date());
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ubeView.layer.cornerRadius = 10.0
        ubeView.isHidden = true;
        
        self.screenSize = CGSize(width: 100, height: 100);
    }
    
    @objc func updateUIView() {
        
        self.sections = [];
        self.schedules = [];
        
        // This returns sets the Day based on the call
        let date = Date();
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";
        formatter.timeZone = TimeZone.current;
        let dateString = formatter.string(from: date)
        
        self.day = projectUtil.returnDy(stringDate: dateString);
        
        if (self.day != 5) {
            instructionsView.isHidden = true;
        }
        
        //Download Schedule file...
        downloadScheduleFile();
        
        //Download All Other Files..
        downloadOtherFiles();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(" Start DATE: %@", Date());
        print(">>> VIEW Will Appear ");
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUIView), name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadingView.isHidden = true;
        self.updateUIView();
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(" Number of rows in Section: ", section, self.sections[section], (self.sections.count > 0 ? (self.schedules[section] as AnyObject).count : 0));
        return self.sections.count > 0 ? ((self.schedules[section]) as AnyObject).count : 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if ((self.schedules[indexPath.section] as AnyObject).count > 0) {
            let schedule = (self.schedules.object(at: indexPath.section) as AnyObject).object(at: indexPath.row)  as! Schedule;
            let cell = projectUtil.getScheduleCell(tableView: tableView, indexPath: indexPath as NSIndexPath, schedule: schedule, isFavoriteIncluded : true, isMySchedule: false, isMainView: true);
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            cell.textLabel?.text = "-- No Events Available --";
            return cell
        }
    }
    
    // Section Header...
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "foodSectionViewCell") as! FoodSectionHeaderCell
        
        if (self.sections.count > 0) {
            let strs  = self.sections[section];
            headerCell.sectionName?.text = strs as? String;
            return headerCell;
        }
        
        return nil;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }

    @IBAction func hamburgerBtnTapped(_ sender: Any) {
        //if the hamburger menu is NOT visible, then move the ubeView back to where it used to be
        if !hamburgerMenuIsVisible {
            //1
            hamburgerMenuIsVisible = true
            ubeView.isHidden = false;
        } else {
        //if the hamburger menu IS visible, then move the ubeView back to its original position
            //2
            hamburgerMenuIsVisible = false
            ubeView.isHidden = true;
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) { (animationComplete) in
            print("The animation is complete!")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "scheduleDetailView", sender: indexPath)
    }
    
    @IBAction func favSession(sender : FavButton!) {
        let tagValue = sender.buttonId?.components(separatedBy: "---");
        
        let int1: Int = Int(tagValue![0])!;
        let int2: Int = Int(tagValue![1])!;
        
        let schedule = (self.schedules.object(at: int1) as AnyObject).object(at: int2)  as! Schedule;

        let key : String = String(format: "%@-%@-%d", schedule.session, schedule.targetGroup, schedule.day);
        
        if (projectUtil.getFavorites().object(forKey: key) != nil) {
            sender?.setImage(UIImage(named: "unSelectedFavorite"), for: UIControlState.normal);
            projectUtil.removeFavorite(schedule: schedule);
        } else {
            sender?.setImage(UIImage(named: "selectedFavorite"), for: UIControlState.normal);
            projectUtil.saveFavorite(schedule: schedule);
        }
    
        self.tableView?.reloadData();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scheduleDetailView" {
            if let scheduleDetailViewController = segue.destination as? ScheduleDetailViewController {
                
                let indexPath : NSIndexPath = sender as! NSIndexPath
                let schedule : Schedule = (self.schedules.object(at: indexPath.section) as AnyObject).object(at: indexPath.row) as! Schedule;
                scheduleDetailViewController.schedule = schedule;
                //scheduleDetailViewController.segueName = "goToScheduleViewController";
            }
        }
    }
}
