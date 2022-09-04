//
//  Schedule.swift
//  imrc
//
//  Created by Abhishek Soni on 4/10/16.
//  Copyright © 2016 Tekqube. All rights reserved.
//

import Foundation

class Schedule : NSObject, NSCoding {
    var time : NSString = "";
    var day : Int = 0;
    var room : NSString = "";
    var session : NSString = "";
    var targetGroup : NSString = "";
    var startTime : NSString = "";
    var endTime : NSString = "";
    var start24Time : NSString = "";
    var end24Time : NSString = "";
    var desc : NSString = "";
    var teamResponsibility : NSString = "";
    var identifier : Int = 0;
    var volunteerName: NSString = "";
    var volunteerPhone: NSString = "";
    var speakerImage: NSString = "";
    var speakerName: NSString = "";
    var speakerBio: NSString = "";
    var eventImage: NSString = "";
    var eventStatus: NSString = "SCHEDULE";
    
    override init() {
        super.init();
    }
    
    required init(coder aDecoder: NSCoder) {
        self.time = aDecoder.decodeObject(forKey: "time") as! String as NSString;
        self.day = aDecoder.decodeInteger(forKey: "day") as Int;
        self.room = aDecoder.decodeObject(forKey: "room") as! String  as NSString;
        self.session = aDecoder.decodeObject(forKey: "session") as! String  as NSString;
        self.targetGroup = aDecoder.decodeObject(forKey: "targetGroup") as! String  as NSString;
        self.startTime = aDecoder.decodeObject(forKey: "startTime") as! String  as NSString;
        self.endTime = aDecoder.decodeObject(forKey: "endTime") as! String  as NSString;
        self.start24Time = aDecoder.decodeObject(forKey: "start24Time") as! String  as NSString;
        self.end24Time = aDecoder.decodeObject(forKey: "end24Time") as! String  as NSString;
        self.desc = aDecoder.decodeObject(forKey: "desc") as! String  as NSString;
        self.teamResponsibility = aDecoder.decodeObject(forKey: "teamResponsibility") as! String  as NSString;
        self.identifier = aDecoder.decodeInteger(forKey: "identifier") as Int;
        self.volunteerName = aDecoder.decodeObject(forKey: "volunteerName") as! String  as NSString;
        self.volunteerPhone = aDecoder.decodeObject(forKey: "volunteerPhone") as! String  as NSString;
        self.speakerName = aDecoder.decodeObject(forKey: "speakerName") as! String  as NSString;
        self.speakerImage = aDecoder.decodeObject(forKey: "speakerImage") as! String  as NSString;
        self.speakerBio = aDecoder.decodeObject(forKey: "speakerBio") as! String as NSString;
        
        if ((aDecoder.decodeObject(forKey: "eventStatus")) != nil) {
            self.eventStatus = aDecoder.decodeObject(forKey: "eventStatus") as! String as NSString;
        }
        
        if ((aDecoder.decodeObject(forKey: "eventImage")) != nil) {
            self.eventImage = aDecoder.decodeObject(forKey: "eventImage") as! String as NSString;
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.time, forKey:"time");
        aCoder.encode(self.day, forKey:"day");
        aCoder.encode(self.room, forKey:"room");
        aCoder.encode(self.session, forKey:"session");
        aCoder.encode(self.targetGroup, forKey:"targetGroup");
        aCoder.encode(self.startTime, forKey:"startTime");
        aCoder.encode(self.endTime, forKey:"endTime");
        aCoder.encode(self.start24Time, forKey:"start24Time");
        aCoder.encode(self.end24Time, forKey:"end24Time");
        aCoder.encode(self.desc, forKey:"desc");
        aCoder.encode(self.teamResponsibility, forKey:"teamResponsibility");
        aCoder.encode(self.identifier, forKey: "identifier");
        aCoder.encode(self.volunteerPhone, forKey: "volunteerPhone");
        aCoder.encode(self.speakerName, forKey: "speakerName");
        aCoder.encode(self.speakerImage, forKey: "speakerImage");
        aCoder.encode(self.speakerBio, forKey: "speakerBio");
        aCoder.encode(self.volunteerName, forKey: "volunteerName");
        
        if (self.eventStatus != nil) {
            aCoder.encode(self.eventStatus, forKey: "eventStatus");
        }
        
        if (self.eventImage != nil) {
            aCoder.encode(self.eventImage, forKey: "eventImage");
        }
    }
}
