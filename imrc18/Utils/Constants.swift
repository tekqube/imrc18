//
//  Constants.swift
//  imrc
//
//  Created by Abhishek Soni on 4/10/16.
//  Copyright © 2016 Tekqube. All rights reserved.
//

import Foundation

struct Constants {
    // FileNames
    static let scheduleFileName = "Schedule";
    static let teamFileName = "Volunteers";
    static let foodMenuFileName = "FoodMenu";
    static let attendeeListFileName = "EventAttendees";
    static let speakerListFileName = "speakerdata";
    static let sponsorListFileName = "Sponsors";
    static let teamContactListFileName = "Volunteers";
    static let extensionName = ".xlsx";
    
    // Event Dates :
    static let eventDate1 = "2018-06-30";
    static let eventDate2 = "2018-07-01";
    static let eventDate3 = "2018-07-02";
    static let eventDate4 = "2018-07-03";
    
    // key for NSUserDefault
    static let downloadScheduleFileKey = "scheduleFileDownloadDateTime";
    static let downloadOtherFileKey = "otherFileDownloadDateTime";
    static let downloadTeamFileKey = "teamFileDownloadDateTime";
    static let downloadFoodMenuFileKey = "foodMenuDownloadDateTime";
    static let downloadAttendeeFileKey = "attendeeDownloadDateTime";
    static let downloadSpeakerFileKey = "speakerDownloadDateTime";
    static let downloadSponsorFileKey = "sponsorDownloadDateTime";
    static let downloadTeamContactListFileKey = "teamListDownloadDateTime";

    // Dropbox URL
    static let scheduleFile = "https://www.dropbox.com/s/zmjtw6a30kpqnuh/Schedule.xlsx?dl=1";
    static let foodMenuFile = "https://www.dropbox.com/s/7p21v4g5ruecryd/FoodMenu.xlsx?dl=1";
    static let attendeeListFile = "https://www.dropbox.com/s/lumuenho6x4n35a/EventAttendees.xlsx?dl=1";
    static let speakerDataFile = "https://www.dropbox.com/s/iy2x4r7rrut6mez/speakerdata.xlsx?dl=1";
    static let sponsorInformationFile = "https://www.dropbox.com/s/5ftyo88fjf063gy/Sponsors.xlsx?dl=1";
    static let teamPointOfContactList = "https://www.dropbox.com/s/96tax1zx9ayxonc/Volunteers.xlsx?dl=1";
}
