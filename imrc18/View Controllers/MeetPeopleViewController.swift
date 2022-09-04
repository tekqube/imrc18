//
//  ScheduleDetailViewController.swift
//  imrc
//
//  Created by Abhishek Soni on 5/21/16.
//  Copyright © 2016 Tekqube. All rights reserved.
//

import Foundation

class MeetPeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!;
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!;
    @IBOutlet weak var bottomFilter : UIView?;
    @IBOutlet weak var searchBar: UISearchBar!;
    
    // Attendees
    var attendees : [Attendee] = [];
    var filteredAttendees : [Attendee] = [];
    
    // Teams
    var teams : [Team] = [];
    var filteredTeams : [Team] = [];
    
    var selectedOptionType = 1;
    
    // Sponsors
    var sponsors : NSMutableArray = [];
    var sponsorSections : NSMutableArray = [];
    var sponsorDict : NSMutableDictionary = [:];
    
    var firstWorksheet: BRAWorksheet = BRAWorksheet();

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = false;
        
        let subview = view.viewWithTag(1)
        if subview is UIButton {
            let button = subview as! UIButton;
            button.backgroundColor = UIColor(hexString: "a00000")
            button.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    func getFileName() -> String {
        var fileName = String(format: "%@",Constants.attendeeListFileName);
        
        if (selectedOptionType == 2) {
            fileName = String(format: "%@",Constants.sponsorListFileName);
        } else if (selectedOptionType == 3) {
            fileName = String(format: "%@",Constants.teamFileName);
        }
        
        return fileName;
    }
    
    func loadScripts() {
        let spreadsheet: BRAOfficeDocumentPackage = projectUtil.getOfficeDocumentPackage(fileName: getFileName());
        
        if (spreadsheet.workbook != nil && spreadsheet.workbook.worksheets.count > 0) {
            firstWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
            DispatchQueue.main.async {
                self.getSheetData(data: 0);
            };
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadScripts();
    }
    
    func getSheetData(data: Int) {
        var isLoopAllowed = true;
        var emptyLines = 0;
        var i = 2;
        if (selectedOptionType == 3) {
            var i = 3;
        }

        let start = NSDate() // <<<<<<<<<< Start time

        while (isLoopAllowed) {
            if (selectedOptionType == 1) {
                let lastName = firstWorksheet.cell(forCellReference: "B\(i)")?.stringValue();
                let firstName = firstWorksheet.cell(forCellReference: "C\(i)")?.stringValue();
                let city = firstWorksheet.cell(forCellReference: "E\(i)")?.stringValue();
                let state = firstWorksheet.cell(forCellReference: "F\(i)")?.stringValue();
                let country = firstWorksheet.cell(forCellReference: "G\(i)")?.stringValue();
                let phone = firstWorksheet.cell(forCellReference: "H\(i)")?.stringValue();
                let chapterName = firstWorksheet.cell(forCellReference: "J\(i)")?.stringValue();
                
                if ((firstName?.count != 0 && lastName?.count != 0)) {
                    let attendee : Attendee = Attendee();
                    attendee.lastName = (lastName != nil ? lastName : "")! as NSString;
                    attendee.firstName = (firstName != nil  ? firstName : "")! as NSString;
                    attendee.city = (city != nil ? city: "")! as NSString;
                    attendee.state = (state != nil ? state : "")! as NSString;
                    attendee.country = (country != nil ? country : "")! as NSString;
                    attendee.phone = (phone != nil ? phone : "")! as NSString;
                    attendee.chapterName = (chapterName != nil ? chapterName : "")! as NSString;
                    attendees.append(attendee);
                } else {
                    isLoopAllowed = false;
                    break;
                }
            } else if (selectedOptionType == 2) {
                let sponsorName = firstWorksheet.cell(forCellReference:"A\(i)")?.stringValue();
                var category = firstWorksheet.cell(forCellReference:"B\(i)")?.stringValue();
                
                if ((sponsorName != nil) && (category != nil)) {
                    if (sponsorName?.count != 0) {
                        let sponsor : Sponsor = Sponsor();
                        sponsor.sponsorName = sponsorName! as NSString;
                        sponsor.category = category! as NSString;
                        
                        category = category?.trimmingCharacters(in: .whitespaces).lowercased();
                        
                        if ((sponsorDict.value(forKey: category!)) == nil) {
                            let arr : NSMutableArray = [];
                            arr.add(sponsor);
                            sponsorDict.setValue(arr, forKey: category!);
                            sponsorSections.add(category!);
                        } else {
                            let arr : NSMutableArray = (sponsorDict.value(forKey: category!) as? NSMutableArray)!;
                            arr.add(sponsor);
                            sponsorDict.setValue(arr, forKey: category!);
                        }
                    }
                } else {
                    emptyLines += 1;
                }
                
                if (emptyLines > 4) {
                    isLoopAllowed = false;
                    break;
                }
            } else if (selectedOptionType == 3) {
                let teamName = firstWorksheet.cell(forCellReference:"B\(i)")?.stringValue();
                let contact = firstWorksheet.cell(forCellReference: "C\(i)")?.stringValue();
                let phone = firstWorksheet.cell(forCellReference: "D\(i)")?.stringValue();
                
                if ((teamName != nil && teamName != "") &&
                    (contact != nil && contact != "")) {
                    
                    emptyLines = 0;
                    
                    let team : Team = Team();
                    
                    team.teamName = ((teamName != nil && teamName != "") ? teamName : "")! as NSString;
                    team.phone = ((phone != nil && phone != "") ? phone : "")! as NSString;
                    team.contactName = ((contact != nil && contact != "") ? contact : "")! as NSString;
                    teams.append(team);
                } else {
                    emptyLines = emptyLines+1;
                    
                    if (emptyLines > 5) {
                        isLoopAllowed = false;
                        break;
                    }
                }
            }
            
            print(" Row: %d", i);
            i=i+1;
        }
        
        let end = NSDate()   // <<<<<<<<<<   end time
        let timeInterval: Double = end.timeIntervalSince(start as Date) // <<<<< Difference in seconds (double)
        print("Time to evaluate problem \(timeInterval) seconds")
        
    
        // Sort Atttendees by last name
        if (selectedOptionType == 1) {
            self.attendees = self.attendees.sorted( by: {(attendee1, attendee2) -> Bool in
                return attendee1.firstName.caseInsensitiveCompare(attendee2.firstName as String) == ComparisonResult.orderedAscending
            });
            filteredAttendees = self.attendees;
        }
        // Sort by team Name...
        else if (selectedOptionType == 3) {
            self.teams = self.teams.sorted( by: {(team1, team2) -> Bool in
                return team1.teamName.caseInsensitiveCompare(team2.teamName as String) == ComparisonResult.orderedAscending
            });
            filteredTeams = self.teams;
        }
        
        self.tableView.reloadData();
        activityIndicator.isHidden = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (selectedOptionType == 1) {
            return 1;
        } else if (selectedOptionType == 2) {
            return self.sponsorSections.count;
        }
        
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selectedOptionType == 2) {
            let totalRows = self.sponsorDict.object(forKey: self.sponsorSections[section]) as? NSMutableArray;
            return totalRows!.count;
        } else if (selectedOptionType == 3) {
            return self.filteredTeams.count
        }
        
       return self.filteredAttendees.count;
    }
    
    func callAttendeePhoneNumber (phone : String) {
        if !(phone ?? "").isEmpty {
            if let phoneCallURL:URL = URL.init(string: "tel://\(phone)") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    application.open(phoneCallURL, options: [:]);
                }
            }
        } else {
            var title = "Call Attendee";
            var message = "Phone number not available for this attendee.";
            
            if (selectedOptionType == 3) {
                title = "Call Volunteer";
                message = "Phone number not available for this volunteer.";
            }
            
            let alertController = UIAlertController(title: title, message:
                message, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil));
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (selectedOptionType == 1) {
            let attendee = self.filteredAttendees[indexPath.row] as! Attendee;
            callAttendeePhoneNumber(phone: attendee.phone as String);
        } else if (selectedOptionType == 3) {
            let team = self.filteredTeams[indexPath.row] as! Team;
            callAttendeePhoneNumber(phone: team.phone as String);
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (selectedOptionType == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sponsorTableViewCell", for: indexPath as IndexPath) as! SponsorTableViewCell
            let arr : NSMutableArray = (self.sponsorDict.object(forKey: self.sponsorSections.object(at: indexPath.section)) as? NSMutableArray)!;
            let sponsor = arr.object(at: indexPath.row) as! Sponsor;
            cell.sponsorName?.text = String(format: "%@",  sponsor.sponsorName);
            
            return cell
        } else if (selectedOptionType == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "teamsTableViewCell", for: indexPath) as! TeamsTableViewCell
            
            let team : Team = (self.filteredTeams[indexPath.row] as? Team)!;
            cell.teamName?.text = team.teamName as String;
            cell.contactName?.text = team.contactName as String;
            cell.phone?.tag = indexPath.row;
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "attendeeTableViewCell", for: indexPath as IndexPath) as! AttendeeTableViewCell
        
            let attendee = self.filteredAttendees[indexPath.row] ;
            cell.lastName?.text = String(format: "%@ %@",attendee.firstName, attendee.lastName) as String;
            cell.name?.text = attendee.otherNames as String;
            cell.location!.text = String(format: "%@, %@, %@",attendee.city, attendee.state, attendee.country);
            cell.chapterName!.text = attendee.chapterName as String;
            cell.phone!.tag = indexPath.row;
        
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (selectedOptionType == 2) {
            let  headerCell = tableView.dequeueReusableCell(withIdentifier: "sponsorSectionViewCell") as! SponsorSectionViewCell
            headerCell.sectionName?.text = (self.sponsorSections[section] as AnyObject).capitalized;
            return headerCell;
        }
        
        return nil;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (selectedOptionType == 1 || selectedOptionType == 3) {
            return 0;
        }

        return 40.0
    }
    
    @IBAction func callAttendee(sender : AnyObject?) {
        if (selectedOptionType == 3) {
            let team = self.teams[(sender?.tag)!] as! Team;
            callAttendeePhoneNumber(phone: team.phone as String);
        } else {
            let attendee = self.attendees[(sender?.tag)!] as! Attendee;
            callAttendeePhoneNumber(phone: attendee.phone as String);
        }
    }
    
    @IBAction func selectOptionType(sender : UIButton!) {
        let optionType = sender?.tag;
        if (optionType != selectedOptionType) {
            selectedOptionType = optionType!;
            
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
            
            sender.backgroundColor = UIColor(hexString: "a00000")
            sender.setTitleColor(UIColor.white, for: .normal)
            sender.titleLabel?.textColor = UIColor.white;
            
            if (selectedOptionType == 3) {
                searchBar.isHidden = false;
                searchBar.backgroundColor = UIColor.white
                searchBar.alpha = 1;
                searchBar.isUserInteractionEnabled = true;
                self.searchBar.placeholder = "Search for Teams here..."
                
                if (self.teams.count == 0){
                    loadScripts();
                } else {
                    self.tableView.reloadData();
                }
            } else if (selectedOptionType == 2) {
                searchBar.backgroundColor = UIColor.lightGray;
                searchBar.isUserInteractionEnabled = false;
                self.searchBar.placeholder = "";
                searchBar.alpha = 0.75;
                if (self.sponsors.count == 0 && self.sponsorSections.count == 0){
                    loadScripts();
                } else {
                    self.tableView.reloadData();
                }
            } else if (selectedOptionType == 1) {
                searchBar.isHidden = false;
                searchBar.backgroundColor = UIColor.white
                searchBar.alpha = 1;
                searchBar.isUserInteractionEnabled = true;
                self.searchBar.placeholder = "Search Attendees here...";

                if (self.attendees.count == 0) {
                    loadScripts();
                } else {
                    self.tableView.reloadData();
                }
            }
        }
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        if (selectedOptionType == 3) {
            filteredTeams = searchText.isEmpty ? self.teams :
                self.teams.filter({ (team) -> Bool in
                    return String(format: "%@ %@", team.teamName, team.contactName).lowercased().contains(searchText.lowercased());
                })
        } else if (selectedOptionType == 1) {
                filteredAttendees = searchText.isEmpty ? self.attendees :
                    self.attendees.filter({ (attendee) -> Bool in
                        return String(format: "%@ %@ %@ %@ %@", attendee.firstName, attendee.lastName, attendee.city, attendee.state, attendee.chapterName).lowercased().contains(searchText.lowercased());
                    })
        }
        
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}
