//
//  CollectionViewCell.swift
//  Rally
//
//  Created by Cody Sugarman on 7/11/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class CollectionViewCell: UICollectionViewCell, MFMessageComposeViewControllerDelegate {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var joinOrLeaveEventButton: UIButton!
    @IBOutlet weak var numAttendees: UILabel!
    
    var rallyEvent: PFObject!
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
    }
    
    func addUserToEvent(currentUser :PFUser, inout usersAttendingEvent :[String], eventTitle :String) {
        usersAttendingEvent.append(currentUser.username!)
        rallyEvent["eventAttendeeUsernames"] = usersAttendingEvent
        var updatedNumAttendees = rallyEvent["eventNumAttendees"] as! Int
        updatedNumAttendees++
        rallyEvent["eventNumAttendees"] = updatedNumAttendees
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
//        self.performSegueWithIdentifier("redirectToSignupFromEventFeed", sender: self)
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
    
    @IBAction func joinOrLeaveEvent(sender: AnyObject) {
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
            joinOrLeaveEventButton.setImage(UIImage(named: "JoinedEvent.png"), forState: UIControlState.Normal)
            numAttendees.text = String(Int(numAttendees.text!)! + 1)
        // Leave Rally Event
        } else {
            removeEventfromUser(currentUser!, eventsUserAttending: &eventsUserAttending, eventTitle: eventTitle, currentInstallation: currentInstallation)
            currentInstallation.saveInBackground()
            removeUserFromEvent(currentUser!, usersAttendingEvent: &usersAttendingEvent)
            informUserLeftEvent(eventTitle)
            joinOrLeaveEventButton.setImage(UIImage(named: "JoinEvent.png"), forState: UIControlState.Normal)
            numAttendees.text = String(Int(numAttendees.text!)! - 1)
        }
        rallyEvent.saveInBackground()
        currentUser!.saveInBackground()
    }
}