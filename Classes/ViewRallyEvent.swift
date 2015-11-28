//
//  ViewRallyEvent.swift
//  Rally
//
//  Created by Cody Sugarman on 7/12/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse
import Foundation

class ViewRallyEvent: UITableViewController {
    
    var rallyEvent:PFObject!
    
//    @IBOutlet weak var eventProgress: UIProgressView!
    @IBOutlet weak var joinOrLeaveEvent: UIButton!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventDate: UITextField!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventSponsor: UITextField!
//    @IBOutlet weak var eventTimeRemaining: UITextField!
    @IBOutlet weak var eventCategory: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventNumAttendees: UITextField!
//    @IBOutlet weak var eventTarget: UITextField!
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> NSString {
        let ti = NSInteger(interval)
        let minutesRemain = (ti % 3600) / 60 as Int
        let totalHours = (ti / 3600)
        let hoursRemain = (totalHours % 24)
        let daysRemain = (totalHours / 24)
        if (daysRemain > 0) {
            return String("\(daysRemain) days, \(hoursRemain) hours remaining")
        } else if (daysRemain == 0 && hoursRemain > 0) {
            return String("\(hoursRemain) hours and \(minutesRemain) minutes remaining")
        } else if (daysRemain == 0 && hoursRemain == 0 && minutesRemain > 0) {
            return String("\(minutesRemain) minutes remaining")
        } else {
            return "Event Closed"
        }
    }
    
    // timeRemaining = (createdAt + numDaysFundraising) - currentDate
//    func calculateTimeRemaining() -> String {
////        _: NSCalendar = NSCalendar.currentCalendar()
////        _ = NSDate()
//        let dateCreated = rallyEvent.createdAt
//        let numSecondsInDay = 60.0*60.0*24.0
//        let numDaysFundraising = rallyEvent["eventNumDaysFundraising"] as! Double
//        let secondsInInterval = numSecondsInDay * numDaysFundraising
//        let endDate = dateCreated!.dateByAddingTimeInterval(secondsInInterval) as NSDate
//        let timeRemaining = endDate.timeIntervalSinceDate(NSDate())
//        let timeRemainingString = stringFromTimeInterval(timeRemaining)
//        return timeRemainingString as String
//    }
    
    func setEventPhoto(rallyEvent :PFObject) {
        let eventImageFile = rallyEvent["eventImage"] as! PFFile
        eventImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if (error == nil) {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    self.eventImage.image = image
                }
            }
        }
    }
    
//    func assignEventProgress(rallyEvent :PFObject) {
//        let numAttendees = rallyEvent["eventNumAttendees"] as! Float
//        let target = rallyEvent["eventTargetNumAttendees"] as! Float
//        eventProgress.progress = numAttendees/target
//        eventProgress.transform = CGAffineTransformMakeScale(1, 10)
//    }
    
    //Add rounding so no decimals!
    func appendPrediction() -> String {
        let numAttendees = rallyEvent["eventNumAttendees"] as! Int!
        let attendees = String(numAttendees)
        let numRSVP = rallyEvent["eventNumAttendees"] as! Double!
        var predictionConstant = 1.0
        if (eventCategory.text == "Community Service") {
            predictionConstant = 0.77
        } else if (eventCategory.text == "Lecture") {
            predictionConstant = 0.65
        } else if (eventCategory.text == "Party") {
            predictionConstant = 0.80
        } else if (eventCategory.text == "Performance") {
            predictionConstant = 0.72
        } else if (eventCategory.text == "Pick-up Games") {
            predictionConstant = 0.85
        } else if (eventCategory.text == "Political Awareness") {
            predictionConstant = 0.87
        } else if (eventCategory.text == "Pre-party") {
            predictionConstant = 0.85
        } else if (eventCategory.text == "Pre-profressional") {
            predictionConstant = 0.82
        } else if (eventCategory.text == "Social Activism") {
            predictionConstant = 0.73
        } else if (eventCategory.text == "Sporting Event") {
            predictionConstant = 0.90
        } else if (eventCategory.text == "Study Groups") {
            predictionConstant = 1.0
        } else if (eventCategory.text == "Other") {
            predictionConstant = 0.75
        }
        let prediction = numRSVP*predictionConstant
        var predictionString = ""
        let roundedPrediction = Int(prediction)
        if (roundedPrediction == 1) {
            predictionString = attendees + " (1 attendee predicted)"
        } else {
            predictionString = attendees + " (" + String(stringInterpolationSegment: roundedPrediction) + " predicted)"
        }
        return predictionString
    }
    
    func setEventInfo(rallyEvent :PFObject) {
        setEventPhoto(rallyEvent)
        eventDate.text = rallyEvent["eventDate"] as! String!
//        let eventTargetNumAttendees = rallyEvent["eventTargetNumAttendees"] as! Int!
//        eventTarget.text = String(eventTargetNumAttendees)
        eventLocation.text = rallyEvent["eventLocation"] as! String!
        eventSponsor.text = rallyEvent["eventSponsor"] as! String!
//        let timeRemaining = calculateTimeRemaining()
//        eventTimeRemaining.text = timeRemaining
        eventCategory.text = rallyEvent["eventCategory"] as! String!
        eventDescription.text = rallyEvent["eventDescription"] as! String!
        let numAttendees = rallyEvent["eventNumAttendees"] as! Int
        let attendees = String(numAttendees)
        eventNumAttendees.text = attendees
//        assignEventProgress(rallyEvent)
    }
    
//    func sendEventClosedNotifications(eventTitle :String) {
//        let push = PFPush()
//        let eventChannel = eventTitle.stringByReplacingOccurrencesOfString(" ", withString: "")
//        push.setChannel(eventChannel)
//        if (eventProgress.progress >= 1) {
//            push.setMessage("We rallied enough people! \(eventTitle) is on!")
//        } else {
//            push.setMessage("\(eventTitle) did not reach critical mass and is now closed for Rallying")
//        }
//        push.sendPushInBackground()
//    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func displaySplashPage(currentUser: PFUser) {
        var displayedSplashPages = currentUser["displayedSplashPages"] as! [Bool!]
        if (!displayedSplashPages[2]) {
            self.performSegueWithIdentifier("displayEventSplashPage", sender: self)
            self.tabBarController!.tabBar.userInteractionEnabled = false
            displayedSplashPages[2] = true
            currentUser["displayedSplashPages"] = displayedSplashPages
            currentUser.saveInBackground()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let currentUser = PFUser.currentUser()
        if (currentUser != nil) {
            displaySplashPage(currentUser!)
        }
    }
    
    override func viewDidLoad() {
        let currentUser = PFUser.currentUser()
        let eventTitle = rallyEvent["eventTitle"] as! String!
        self.title = eventTitle
        if (rallyEvent["groupSponsor"] != nil) {
            eventSponsor.text = rallyEvent["groupSponsor"] as! String!
        }
        setEventInfo(rallyEvent)
        if (currentUser != nil) {
            if (hasJoinedEvent(currentUser!, eventTitle: eventTitle)) {
                joinOrLeaveEvent.setImage(UIImage(named: "LeaveEvent.png"), forState: UIControlState.Normal)
            } else {
                joinOrLeaveEvent.setImage(UIImage(named: "AddEvent.png"), forState: UIControlState.Normal)
            }
            let eventAdmin = rallyEvent["eventAdmin"] as! String!
            if (currentUser!.username == eventAdmin) {
                eventNumAttendees.text = appendPrediction()
            }
        }
        //Whatever it says when event is over
//        if (eventTimeRemaining.text == "Event Closed") {
//            joinOrLeaveEvent.setTitle("Event Closed", forState: .Normal)
//            joinOrLeaveEvent.enabled = false
//            let hasSentClosedNotification = rallyEvent["hasSentClosedNotification"] as! Bool
//            if (!hasSentClosedNotification) {
//                sendEventClosedNotifications(eventTitle)
//                rallyEvent["hasSentClosedNotification"] = true
//                rallyEvent.saveInBackground()
//            }
//        }
    }
    
    func hasJoinedEvent(currentUser :PFUser, eventTitle :String) -> Bool {
        let usersAttendingEvent = rallyEvent["eventAttendeeUsernames"] as! [String]
        let eventsUserAttending = currentUser["eventsAttending"] as! [String]
        let eventTitle = rallyEvent["eventTitle"] as! String!
        if (usersAttendingEvent.indexOf(currentUser.username!) != nil && eventsUserAttending.indexOf(eventTitle) != nil) {
            return true
        }
        return false
    }
    
    func sendEventSuccessNotifications(eventTitle :String) {
        let push = PFPush()
        let eventChannel = eventTitle.stringByReplacingOccurrencesOfString(" ", withString: "")
        push.setChannel(eventChannel)
        push.setMessage("Congratulations! \(eventTitle) has been successful!")
        push.sendPushInBackground()
    }
    
    func addUserToEvent(currentUser :PFUser, inout usersAttendingEvent :[String], eventTitle :String) {
        usersAttendingEvent.append(currentUser.username!)
        rallyEvent["eventAttendeeUsernames"] = usersAttendingEvent
        var updatedNumAttendees = rallyEvent["eventNumAttendees"] as! Int
        updatedNumAttendees++
        rallyEvent["eventNumAttendees"] = updatedNumAttendees
//        let numRequired = rallyEvent["eventTargetNumAttendees"] as! Int
//        if (updatedNumAttendees == numRequired) {
//            rallyEvent["eventIsHappening"] = true
//            let hasSentSuccessNotification = rallyEvent["hasSentSuccessNotification"] as! Bool
//            if (!hasSentSuccessNotification) {
//                sendEventSuccessNotifications(eventTitle)
//                rallyEvent["hasSentSuccessNotification"] = true
//            }
//        }
    }
    
    func removeUserFromEvent(currentUser :PFUser, inout usersAttendingEvent :[String]) {
        let indexOfUserToRemove = usersAttendingEvent.indexOf(currentUser.username!) as Int!
        usersAttendingEvent.removeAtIndex(indexOfUserToRemove!)
        rallyEvent["eventAttendeeUsernames"] = usersAttendingEvent
        let updatedNumAttendees = rallyEvent["eventNumAttendees"] as! Int - 1
        rallyEvent["eventNumAttendees"] = updatedNumAttendees
    }
    
    func addEventToUser(currentUser :PFUser, inout eventsUserAttending :[String], eventTitle :String, currentInstallation :PFInstallation) {
        let eventChannel = eventTitle.stringByReplacingOccurrencesOfString(" ", withString: "")
        currentInstallation.addUniqueObject(eventChannel, forKey: "channels")
        eventsUserAttending.append(eventTitle)
        currentUser["eventsAttending"] = eventsUserAttending
    }
    
    func removeEventfromUser(currentUser :PFUser, inout eventsUserAttending :[String], eventTitle :String, currentInstallation: PFInstallation) {
        let indexOfEventToRemove = eventsUserAttending.indexOf(eventTitle)        
        eventsUserAttending.removeAtIndex(indexOfEventToRemove!)
        currentUser["eventsAttending"] = eventsUserAttending
        let eventChannel = eventTitle.stringByReplacingOccurrencesOfString(" ", withString: "")
        currentInstallation.removeObject(eventChannel, forKey: "channels")
    }
    
    func informUserJoinedEvent(eventTitle :String) {
        let joinedRallyEvent = UIAlertView(title: "Joined Rally Event", message: "Congratulations! You've joined \(eventTitle)!", delegate: self, cancelButtonTitle: "OK")
        joinedRallyEvent.show()
    }
    
    func informUserLeftEvent(eventTitle :String) {
        let leftRallyEvent = UIAlertView(title: "Left Rally Event", message: "You've been removed from \(eventTitle)", delegate: self, cancelButtonTitle: "OK")
        leftRallyEvent.show()
    }
    
    func promptUserLogin() {
        let cannotJoinEvent = UIAlertView(title: "Cannot Join Rally Event", message: "Please login to support this event.", delegate: self, cancelButtonTitle: "OK")
        cannotJoinEvent.show()
    }
    
    func redirectToLogin() {
        let promptLogin = UIAlertView(title: "Login Required", message: "Please login to support a Rally Event", delegate: self, cancelButtonTitle: "OK")
        promptLogin.show()
        self.performSegueWithIdentifier("redirectToSignupFromEvent", sender: self)
    }
    
    // When "Join" or "Leave" button is clicked
    @IBAction func joinOrLeaveRallyEvent(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        let currentInstallation = PFInstallation.currentInstallation()
        if (currentUser == nil) {
            redirectToLogin()
            return
        }
        var usersAttendingEvent = rallyEvent["eventAttendeeUsernames"] as! [String]
        var eventsUserAttending = currentUser!["eventsAttending"] as! [String]
        let eventTitle = rallyEvent["eventTitle"] as! String!
        
        // Join Rally Event
        if (!hasJoinedEvent(currentUser!, eventTitle: eventTitle)) {
            addEventToUser(currentUser!, eventsUserAttending: &eventsUserAttending, eventTitle: eventTitle, currentInstallation: currentInstallation)
            currentInstallation.saveInBackground()
            addUserToEvent(currentUser!, usersAttendingEvent: &usersAttendingEvent, eventTitle: eventTitle)
            informUserJoinedEvent(eventTitle)
        // Leave Rally Event
        } else {
            removeEventfromUser(currentUser!, eventsUserAttending: &eventsUserAttending, eventTitle: eventTitle, currentInstallation: currentInstallation)
            currentInstallation.saveInBackground()
            removeUserFromEvent(currentUser!, usersAttendingEvent: &usersAttendingEvent)
            informUserLeftEvent(eventTitle)
        }
        rallyEvent.saveInBackground()
        currentUser!.saveInBackground()
        viewDidLoad()
    }
    
    @IBAction func reportEvent(sender: AnyObject) {
//        let reportWarning = UIAlertController(title: "Report Rally Event", message: "Are you sure you want to report this event? Our team will investigate and potentially remove this content.", preferredStyle: UIAlertControllerStyle.Alert)
//        reportWarning.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
//            self.rallyEvent["hasBeenReported"] = true
//            self.rallyEvent.saveInBackground()
//            self.displayReportSuccess()
//        }))
//        reportWarning.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
//        }))
//        presentViewController(reportWarning, animated: true, completion: nil)
        self.rallyEvent["hasBeenReported"] = true
        self.rallyEvent.saveInBackground()
        self.displayReportSuccess()
    }
    
    func displayReportSuccess() {
        let reportSuccess = UIAlertView(title: "Event Reported", message: "This event has been flagged and will be investigated further.", delegate: self, cancelButtonTitle: "OK")
        reportSuccess.show()
    }
    
    // Send rallyEvent to next page
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "displayEventAttendees") {
            let detailController = segue.destinationViewController as! ViewEventAttendees
            detailController.rallyEvent = rallyEvent
        }
    }
    
    @IBAction func closeSplashPage(sender: UIStoryboardSegue) {
    }
    
}
