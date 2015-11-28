//
//  ViewMyProfile.swift
//  Rally
//
//  Created by Cody Sugarman on 8/2/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse

class ViewMyProfile: UITableViewController {
    
    @IBOutlet weak var myProfileImage: UIImageView!
    @IBOutlet weak var myUsername: UITextField!
    @IBOutlet weak var myGroups: UITextField!
    @IBOutlet weak var myEvents: UITableView!
    
    var eventTitles = [String]()
    var eventDates = [String]()
    var eventTimes = [String]()
    var eventLocations = [String]()

    var query = PFQuery(className: "RallyEvent")
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func setUserPhoto(currentUser :PFUser) {
        let userImageFile = currentUser["profilePicture"] as! PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if (error == nil) {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    self.myProfileImage.image = image
                }
            }
        }
        myProfileImage.layer.masksToBounds = false
        myProfileImage.layer.cornerRadius = myProfileImage.frame.height/2
        myProfileImage.clipsToBounds = true
    }
    
    func setProfileInfo(currentUser :PFUser) {
        let groupsMemberOf = currentUser["groupsMemberOf"] as! [String!]
        let numGroups = groupsMemberOf.count
        var groupList = ""
        if (numGroups > 2) {
            groupList += groupsMemberOf[0] + ", " + groupsMemberOf[1]
            let extraGroups = numGroups-2
            groupList += " +\(extraGroups) more"
        } else if (numGroups == 2) {
            groupList += groupsMemberOf[0] + ", " + groupsMemberOf[1]
        } else if (numGroups == 1){
            groupList += groupsMemberOf[0]
        } else {
            groupList += "No groups"
        }
        myGroups.text = groupList
    }
    
    func resetEventFeed() {
        eventTitles = [String]()
        eventDates = [String]()
        eventTimes = [String]()
        eventLocations = [String]()
    }
    
    func getEventTitle(rallyEvent: AnyObject) {
        let eventTitle = rallyEvent["eventTitle"] as! String!
        self.eventTitles.append(eventTitle)
    }
    
    func getEventLocations(rallyEvent: AnyObject) {
        let eventLocation = rallyEvent["eventLocation"] as! String!
        self.eventLocations.append(eventLocation)
    }
    
    func getEventDateAndTime(rallyEvent: AnyObject) {
        let eventDateAndTime = rallyEvent["eventDate"] as! String
        var eventArray = eventDateAndTime.componentsSeparatedByString(", ")
        let dateString = eventArray[0]
        let timeString = eventArray[1]
        self.eventDates.append(dateString)
        self.eventTimes.append(timeString)
    }
    
    func filterEvents(currentFilter :String, currentUser :PFUser) {
        if (currentFilter == "My Events") {
            resetEventFeed()
            query = PFQuery(className: "RallyEvent")
            let events = currentUser["eventsAttending"] as! [String]
            for event in events {
                query = PFQuery(className: "RallyEvent")
                query.whereKey("eventTitle", equalTo: event)
                query.findObjectsInBackgroundWithBlock {
                    (events, error) -> Void in
                    if (error == nil && events?.first != nil) {
                        let event = events!.first as! PFObject
                        self.getEventTitle(event)
                        self.getEventDateAndTime(event)
                        self.getEventLocations(event)
                    }
                    self.myEvents!.reloadData()
                }
            }
            self.myEvents!.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        let currentUser = PFUser.currentUser()
        self.myEvents.delegate = self
        self.myEvents.dataSource = self
        if (currentUser == nil) {
            performSegueWithIdentifier("redirectToSignupFromProfile", sender: self)
            return
        }
        filterEvents("My Events", currentUser: currentUser!)
        setProfileInfo(currentUser!)
        setUserPhoto(currentUser!)
        myUsername.text = currentUser!.username
    }
    
    @IBAction func editUserProfile(sender: AnyObject) {
        _ = PFUser.currentUser()
        performSegueWithIdentifier("displayEditRallyProfileView", sender: self)
    }
    
    func displayLogoutSuccess() {
        let logoutSuccess = UIAlertView(title: "User Logout", message: "You have successfully logged out.", delegate: self, cancelButtonTitle: "OK")
        logoutSuccess.show()
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        displayLogoutSuccess()
        PFUser.logOut()
        performSegueWithIdentifier("redirectToSignupFromProfile", sender: self)

    }
    
    @IBAction func saveRallyProfile(sender: UIStoryboardSegue) {
    }

}






