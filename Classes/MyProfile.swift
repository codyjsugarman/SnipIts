//
//  MyProfile.swift
//  Rally
//
//  Created by Cody Sugarman on 8/2/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse

class MyProfile: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myProfileImage: UIImageView!
//    @IBOutlet weak var myUsername: UITextField!
//    @IBOutlet weak var myGroups: UITextField!
    @IBOutlet weak var myEvents: UITableView!    
    
    @IBAction func signOut(sender: AnyObject) {
        PFUser.logOut()
    }
    
    
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
    
    //Sets cell data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = myEvents.dequeueReusableCellWithIdentifier("pinboardCell", forIndexPath: indexPath) as! EventBoardCell
        
        let row = indexPath.row
        cell.eventDate.text = eventDates[row]
        cell.eventTime.text = eventTimes[row]
        cell.eventLocation.text = eventLocations[row]
        cell.eventName.text = eventTitles[row]
//        setProfileImage(cell, row: row)
        return cell
    }
    
    // When row tapped:
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        let row = indexPath.row
//        let selectedUsername = attendeeNames[row]
//        query!.whereKey("username", equalTo:selectedUsername)
//        let selectedUser = query!.findObjects()!.first as! PFUser
//        self.performSegueWithIdentifier("displayRallyUser", sender: selectedUser)
    }
    
    func setUserPhoto(currentUser :PFUser) {
//        let userImageFile = currentUser["profilePicture"] as! PFFile
//        userImageFile.getDataInBackgroundWithBlock {
//            (imageData: NSData?, error: NSError?) -> Void in
//            if (error == nil) {
//                if let imageData = imageData {
//                    let image = UIImage(data:imageData)
//                    self.myProfileImage.image = image
//                }
//            }
//        }
        myProfileImage.image = UIImage(named:"SnipItsLogo.png")
        myProfileImage.layer.masksToBounds = false
        myProfileImage.layer.cornerRadius = myProfileImage.frame.height/2
        myProfileImage.clipsToBounds = true
    }
    
    func setProfileInfo(currentUser :PFUser) {
//        let groupsMemberOf = currentUser["groupsMemberOf"] as! [String!]
//        let numGroups = groupsMemberOf.count
//        var groupList = ""
//        if (numGroups > 2) {
//            groupList += groupsMemberOf[0] + ", " + groupsMemberOf[1]
//            let extraGroups = numGroups-2
//            groupList += " +\(extraGroups) more"
//        } else if (numGroups == 2) {
//            groupList += groupsMemberOf[0] + ", " + groupsMemberOf[1]
//        } else if (numGroups == 1){
//            groupList += groupsMemberOf[0]
//        } else {
//            groupList += "No groups"
//        }
//        myGroups.text = groupList
    }
    
    override func viewDidLoad() {
        self.myEvents.delegate = self
        self.myEvents.dataSource = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventTitles.count
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
    
//    func getEventDateOrder(eventDates :[String]) -> [Int] {
//        var eventOrder = [Int]()
//        for date in eventDates
//        return eventOrder
//    }
    
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
//            let eventOrder = getEventDateOrder(eventDates)
            self.myEvents!.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        let currentUser = PFUser.currentUser()
        if (currentUser == nil) {
            performSegueWithIdentifier("redirectToSignupFromProfile", sender: self)
            return
        }
        filterEvents("My Events", currentUser: currentUser!)
        setProfileInfo(currentUser!)
        setUserPhoto(currentUser!)
//        myUsername.text = currentUser!.username
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






