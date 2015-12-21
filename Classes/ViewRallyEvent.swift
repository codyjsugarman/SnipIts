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
import MessageUI

class ViewRallyEvent: UITableViewController {
    
    var rallyEvent:PFObject!
    @IBOutlet weak var eventCountdown: UIButton!
    @IBOutlet weak var joinOrLeaveEvent: UIButton!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventDate: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventNumAttendees: UITextField!
    @IBOutlet weak var eventTitle: UILabel!
    
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
                    self.view.backgroundColor = UIColor.clearColor()
                    
//                    //Blur entire view (when user has joined event to show countdown?)
//                    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
//                    blurEffectView.frame = self.view.bounds
//                    blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//                    self.view.addSubview(blurEffectView)
            
                }
            }
        }
    }
    
    func setEventInfo(rallyEvent :PFObject) {
        setEventPhoto(rallyEvent)
        let date = rallyEvent["eventDate"] as! String
        var eventArray = date.componentsSeparatedByString(", ")
        let dateString = eventArray[0]
        let timeString = eventArray[1]
        let dateAndTime = synthesizeDateAndTime(dateString, eventTime: timeString)
        let eventLocation = rallyEvent["eventLocation"] as! String!
        eventDate.text = dateAndTime + " @ " + eventLocation
        eventDescription.text = rallyEvent["eventDescription"] as! String!
        let numAttendees = rallyEvent["eventNumAttendees"] as! Int
        let attendees = String(numAttendees)
        eventNumAttendees.text = attendees
    }
    
    func synthesizeDateAndTime(eventDate :String, eventTime :String) -> String {
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "M/d/yy"
        let todayDate = formatter.dateFromString(eventDate)!
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
        let weekDay = intToDay(myComponents.weekday)
        let dateArray = eventDate.componentsSeparatedByString("/")
        let month = intToMonth(Int(dateArray[0])!)
        return weekDay + ", " + month + " " + dateArray[1] + ". " + eventTime
    }
    
    func intToMonth(month :Int) -> String {
        if (month == 1) {
            return "Jan"
        } else if (month == 2) {
            return "Feb"
        } else if (month == 3) {
            return "Mar"
        } else if (month == 4) {
            return "Apr"
        } else if (month == 5) {
            return "May"
        } else if (month == 6) {
            return "Jun"
        } else if (month == 7) {
            return "Jul"
        } else if (month == 8) {
            return "Aug"
        } else if (month == 9) {
            return "Sep"
        } else if (month == 10) {
            return "Oct"
        } else if (month == 11) {
            return "Nov"
        } else {
            return "Dec"
        }
    }
    
    func intToDay(weekDay :Int) -> String {
        if (weekDay == 1) {
            return "Sun"
        } else if (weekDay == 2) {
            return "Mon"
        } else if (weekDay == 3) {
            return "Tues"
        } else if (weekDay == 4) {
            return "Wed"
        } else if (weekDay == 5) {
            return "Thu"
        } else if (weekDay == 6) {
            return "Fri"
        } else {
            return "Sat"
        }
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
    
//    func displaySplashPage(currentUser: PFUser) {
//        var displayedSplashPages = currentUser["displayedSplashPages"] as! [Bool!]
//        if (!displayedSplashPages[2]) {
//            self.performSegueWithIdentifier("displayEventSplashPage", sender: self)
//            self.tabBarController!.tabBar.userInteractionEnabled = false
//            displayedSplashPages[2] = true
//            currentUser["displayedSplashPages"] = displayedSplashPages
//            currentUser.saveInBackground()
//        }
//    }
    
    override func viewDidAppear(animated: Bool) {
//        let currentUser = PFUser.currentUser()
//        if (currentUser != nil) {
//            displaySplashPage(currentUser!)
//        }
    }
    
    override func viewDidLoad() {
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("countDownUntilChat"), userInfo: nil, repeats: true)

        let currentUser = PFUser.currentUser()
        let title = rallyEvent["eventTitle"] as! String!
        //eventTitle.text = title
        //self.title = title
        setEventInfo(rallyEvent)
        if (currentUser != nil) {
            if (hasJoinedEvent(currentUser!, eventTitle: title)) {
                joinOrLeaveEvent.setImage(UIImage(named: "JoinedEvent.png"), forState: UIControlState.Normal)
            } else {
                joinOrLeaveEvent.setImage(UIImage(named: "JoinEvent.png"), forState: UIControlState.Normal)
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
        self.rallyEvent["hasBeenReported"] = true
        self.rallyEvent.saveInBackground()
        self.displayReportSuccess()
    }
    
    func displayReportSuccess() {
        let reportSuccess = UIAlertView(title: "Event Reported", message: "This event has been flagged and will be investigated further.", delegate: self, cancelButtonTitle: "OK")
        reportSuccess.show()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "enterEventChat") {
            if (eventCountdown.currentTitle != "Event Live - Join The Action!") {
                return false
            }
        }
        return true
    }
    
    // Send rallyEvent to next page
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "enterEventChat") {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let detailController = destinationNavigationController.topViewController as! MessagesViewController
            detailController.rallyEvent = rallyEvent
        }
    }
    
    @IBAction func closeSplashPage(sender: UIStoryboardSegue) {
    }
    
//    @IBAction func sendMessage(sender: AnyObject) {
//        let messageVC = MFMessageComposeViewController()
//        
//        messageVC.body = "Enter a message";
//        messageVC.recipients = ["Enter tel-nr"]
//        messageVC.messageComposeDelegate = self;
//        print("A")
//        self.presentViewController(messageVC, animated: false, completion: nil)
//        print("B")
//    }
//    
//    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
//        switch (result.rawValue) {
//        case MessageComposeResultCancelled.rawValue:
//            print("Message was cancelled")
//            self.dismissViewControllerAnimated(true, completion: nil)
//        case MessageComposeResultFailed.rawValue:
//            print("Message failed")
//            self.dismissViewControllerAnimated(true, completion: nil)
//        case MessageComposeResultSent.rawValue:
//            print("Message was sent")
//            self.dismissViewControllerAnimated(true, completion: nil)
//        default:
//            break;
//        }
//    }
    
    //COUNTDOWN STUFF:
    
    var daysLeft = 0
    var hoursLeft = 0
    var minutesLeft = 0
    var secondsLeft = 0
    
    func countDownUntilChat() {
        // here we set the current date
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Second, .Hour, .Minute, .Month, .Year, .Day], fromDate: date)

        let currentDate = calendar.dateFromComponents(components)
        
        // here we set the due date. When the timer is supposed to finish
        let userCalendar = NSCalendar.currentCalendar()
        let competitionDate = NSDateComponents()
        let eventDateAndTime = rallyEvent["eventDate"] as! String
        var eventArray = eventDateAndTime.componentsSeparatedByString(", ")
        let dateString = eventArray[0]
        var dateArray = dateString.componentsSeparatedByString("/")

        //9:00 PM
        let timeString = eventArray[1]
        //[9:00, PM]
        let timeArray = timeString.componentsSeparatedByString(" ")
        //[9, 00]
        let hourArray = timeArray[0].componentsSeparatedByString(":")
        var numHours = Int(hourArray[0])
        if (timeArray[1] == "PM") {
            numHours = numHours! + 12
        }
        var numYears = Int(dateArray[2])
        numYears = numYears! + 2000
        
        competitionDate.second = 00
        competitionDate.year = Int(numYears!)
        competitionDate.month = Int(dateArray[0])!
        competitionDate.day = Int(dateArray[1])!
        competitionDate.hour = numHours!
        competitionDate.minute = Int(hourArray[1])!
        let competitionDay = userCalendar.dateFromComponents(competitionDate)!
        
        // Here we compare the two dates
        competitionDay.timeIntervalSinceDate(currentDate!)
        let dayCalendarUnit: NSCalendarUnit = ([.Day, .Hour, .Minute, .Second])
        
        //here we change the seconds to hours,minutes and days
        let CompetitionDayDifference = userCalendar.components(
            dayCalendarUnit, fromDate: currentDate!, toDate: competitionDay,
            options: [])
        
        //finally, here we set the variable to our remaining time
        daysLeft = CompetitionDayDifference.day
        hoursLeft = CompetitionDayDifference.hour
        minutesLeft = CompetitionDayDifference.minute
        secondsLeft = CompetitionDayDifference.second
        
        if (daysLeft > 0 || hoursLeft > 0 || minutesLeft > 0 || secondsLeft > 0) {
            eventCountdown.setTitle(String(daysLeft) + " Days, " + String(hoursLeft) + " Hours, " + String(minutesLeft) + " Mins, and " + String(secondsLeft) + " Seconds", forState: .Normal)
        } else if (eventOngoing(CompetitionDayDifference)) {
            eventCountdown.setTitle("Event Live - Join The Action!", forState: .Normal)
        } else {
            eventCountdown.setTitle("Event Closed", forState: .Normal)
        }
        
    }
    
    func eventOngoing(CompetitionDayDifference :NSDateComponents) -> Bool {
        //Get event length
        let eventLength = rallyEvent["eventLength"] as! Int

        //Compare length to CompetitionDayDifference
        if (abs(CompetitionDayDifference.hour) < eventLength && CompetitionDayDifference.day == 0) {
            return true
        }
        return false
    }
    

}
