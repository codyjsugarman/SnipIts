//
//  ViewEventFeed.swift
//  Rally
//
//  Created by Cody Sugarman on 7/11/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse

class ViewEventFeed: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    var currentFilter = "No Filter"
    var previousFilter = "No Filter"
    let reuseIdentifier = "collCell"
    var query = PFQuery(className: "RallyEvent")
    var eventTitles = [String]()
    var eventLocations = [String]()
//    var eventSponsors = [String]()
    var eventCategories = [String]()
    var eventDates = [String]()
//    var eventAttendance = [Float]()
    var eventImageFiles = [PFFile]()
    var eventTimes = [String]()
//    var eventDaysRemain = [Int]()
    var rallyEventList = [PFObject]()
    
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 65.0, bottom: 10.0, right: 65.0)
    
    @IBOutlet weak var subview: UIView!
    
    func refreshEventFeedFilter() {
        viewWillAppear(true)
    }
    
    func loadNewEvent() {
        let uploadingNewEvent : UIAlertView = UIAlertView(title: "Uploading New Rally Event", message: "This may take a few seconds...", delegate: nil, cancelButtonTitle: nil)
        let viewBack:UIView = UIView(frame: CGRectMake(83,0,100,50))
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(50, 10, 37, 37)) as UIActivityIndicatorView
        loadingIndicator.center = viewBack.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating()
        viewBack.addSubview(loadingIndicator)
        viewBack.center = self.view.center
        uploadingNewEvent.setValue(viewBack, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        uploadingNewEvent.show()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 8))
        dispatch_after(delayTime, dispatch_get_main_queue()){
            uploadingNewEvent.dismissWithClickedButtonIndex(-1, animated: true)
            self.viewWillAppear(true)
            let newRallyEventCreated = UIAlertView(title: "New Rally Event Created", message: "Congratulations! You're ready to start Rallying!", delegate: self, cancelButtonTitle: "OK")
            newRallyEventCreated.show()
        }
        self.collectionView!.reloadData()
    }
    
    func reloadEventFeed() {
        self.viewWillAppear(true)
    }
    
    func filterEvents(currentFilter :String, currentUser :PFUser) {
        if (currentFilter == "My Events") {
            resetEventFeed()
            query = PFQuery(className: "RallyEvent")
            let eventsAttending = currentUser["eventsAttending"] as! [String]
            if (eventsAttending.count == 0) {
                //Reload data but don't crash...
                self.collectionView!.collectionViewLayout.invalidateLayout()
                self.collectionView!.reloadData()
            }
            for event in eventsAttending {
                query = PFQuery(className: "RallyEvent")
                query.whereKey("eventTitle", equalTo: event)
                query.findObjectsInBackgroundWithBlock {
                    (events, error) -> Void in
                    if (error == nil && events?.first != nil) {
                        let event = events!.first as! PFObject
                        self.getEventTitle(event)
                        self.rallyEventList.append(event)
//                        self.getEventAttendance(event)
                        self.getEventImage(event)
//                        self.getEventCategory(event)
//                        self.getEventSponsor(event)
                        self.getEventDate(event)
                        self.getEventLocation(event)
//                        self.getDaysRemain(event)
                    }
                    self.collectionView!.reloadData()
                }
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func getEventTitle(rallyEvent :AnyObject) {
        self.eventTitles.append(rallyEvent["eventTitle"] as! String)
    }
    
    func getEventImage(rallyEvent :AnyObject) {
        let eventImageFile = rallyEvent["eventImage"] as! PFFile
        self.eventImageFiles.append(eventImageFile)
    }
    
//    func getEventAttendance(rallyEvent :AnyObject) {
//        let numRSVP = rallyEvent["eventNumAttendees"] as! Float
//        let numTarget = rallyEvent["eventTargetNumAttendees"] as! Float
//        let percentAttendance = numRSVP/numTarget
//        self.eventAttendance.append(percentAttendance)
//    }
    
//    func getEventCategory(rallyEvent :AnyObject) {
//        let eventCategory = rallyEvent["eventCategory"] as! String
//        self.eventCategories.append(eventCategory)
//    }
    
//    func getEventSponsor(rallyEvent :AnyObject) {
//        let eventSponsor = rallyEvent["eventSponsor"] as! String
//        self.eventSponsors.append(eventSponsor)
//    }
    
    func getEventLocation(rallyEvent :AnyObject) {
        let eventLocation = rallyEvent["eventLocation"] as! String
        self.eventLocations.append(eventLocation)
    }
    
    func getEventDate(rallyEvent :AnyObject) {
        let eventDate = rallyEvent["eventDate"] as! String
        var eventArray = eventDate.componentsSeparatedByString(", ")
        let dateString = eventArray[0]
        let timeString = eventArray[1]
        self.eventDates.append(dateString)
        self.eventTimes.append(timeString)
    }
    
    // daysRemain = (createdAt + numDaysFundraising) - currentDate
//    func getDaysRemain(rallyEvent :AnyObject) {
//        let dateCreated = rallyEvent.createdAt
//        let numSecondsInDay = 60.0*60.0*24.0
//        let numDaysFundraising = rallyEvent["eventNumDaysFundraising"] as! Double
//        let secondsInInterval = numSecondsInDay * numDaysFundraising
//        let endDate = dateCreated!!.dateByAddingTimeInterval(secondsInInterval) as NSDate
//        let timeRemaining = endDate.timeIntervalSinceDate(NSDate())
//        let daysRemain = Int(timeRemaining/numSecondsInDay)
//        let isClosed = rallyEvent["hasSentClosedNotification"] as! Bool
//        if (isClosed == true) {
//            self.eventDaysRemain.append(-1)
//        } else {
//            self.eventDaysRemain.append(daysRemain)
//        }
//    }
    
    func resetEventFeed() {
        eventTitles = [String]()
//        eventAttendance = [Float]()
        eventImageFiles = [PFFile]()
        eventLocations = [String]()
//        eventSponsors = [String]()
        eventCategories = [String]()
        rallyEventList = [PFObject]()
        eventDates = [String]()
        eventTimes = [String]()
//        eventDaysRemain = [Int]()
    }
    
    func populateEventFeed(rallyEvents :[AnyObject]) {
        let currentUser = PFUser.currentUser()
        for rallyEvent in rallyEvents {
            rallyEventList.append(rallyEvent as! PFObject)
            getEventTitle(rallyEvent)
//            getEventAttendance(rallyEvent)
            getEventImage(rallyEvent)
//            getEventCategory(rallyEvent)
//            getEventSponsor(rallyEvent)
            getEventLocation(rallyEvent)
            getEventDate(rallyEvent)
//            getDaysRemain(rallyEvent)
        }
    }
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    func displaySplashPage(currentUser: PFUser) {
        var displayedSplashPages = currentUser["displayedSplashPages"] as! [Bool]
        if (!displayedSplashPages[0]) {
            self.performSegueWithIdentifier("displayEventFeedSplashPage", sender: self)
            self.tabBarController!.tabBar.userInteractionEnabled = false
            displayedSplashPages[0] = true
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
    
    override func viewWillAppear(animated: Bool) {
        let currentUser = PFUser.currentUser()
        // Set filter
        if (currentFilter == "No Filter") {
            query = PFQuery(className: "RallyEvent")
            query.findObjectsInBackgroundWithBlock {
                (rallyEvents, error) -> Void in
                if (error == nil) {
                    self.resetEventFeed()
                    self.populateEventFeed(rallyEvents!)
                    self.collectionView!.reloadData()
                }
            }
        } else {
            filterEvents(currentFilter, currentUser: currentUser!)
            self.collectionView!.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        collectionView.collectionViewLayout.invalidateLayout()
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventTitles.count
    }
    
    func setEventImage(cell :CollectionViewCell, row :Int) {
        let eventImageFile = eventImageFiles[row]
        eventImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if (error == nil) {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    cell.eventImage.image = image
                }
            }
        }
    }
    
//    func setPercentAttendance(cell :CollectionViewCell, row :Int) {
//        let percentAttendance = eventAttendance[row] * 100
//        let numPercent = Int(percentAttendance)
//        let stringPercent = String(numPercent)
//    }
    
    func hasJoinedEvent(currentUser :PFUser, eventTitle :String, rallyEvent :PFObject) -> Bool {
        let usersAttendingEvent = rallyEvent["eventAttendeeUsernames"] as! [String]
        let eventsUserAttending = currentUser["eventsAttending"] as! [String]
        let eventTitle = rallyEvent["eventTitle"] as! String!
        if (usersAttendingEvent.indexOf(currentUser.username!) != nil && eventsUserAttending.indexOf(eventTitle) != nil) {
            return true
        }
        return false
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let currentUser = PFUser.currentUser()
        let event = self.rallyEventList[indexPath.row] as PFObject
        let eventTitle = event["eventTitle"] as! String!
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        cell.title.text = self.eventTitles[indexPath.row % eventTitles.count]
        cell.rallyEvent = self.rallyEventList[indexPath.row]
        setEventImage(cell, row: indexPath.row)
        cell.eventLocation.text = self.eventLocations[indexPath.row]
        cell.eventDate.text = self.eventDates[indexPath.row]
        cell.eventTime.text = self.eventTimes[indexPath.row]
        if (PFUser.currentUser() != nil) {
            if (hasJoinedEvent(currentUser!, eventTitle: eventTitle, rallyEvent: event)) {
                cell.joinOrLeaveEventButton.setImage(UIImage(named: "LeaveEvent.png"), forState: UIControlState.Normal)
            } else {
                cell.joinOrLeaveEventButton.setImage(UIImage(named: "AddEvent.png"), forState: UIControlState.Normal)
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSize(width: 300, height: 400)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "displayRallyEvent") {
            let detailController = segue.destinationViewController as! ViewRallyEvent
            let rallyEvent = sender as! PFObject
            detailController.rallyEvent = rallyEvent
        }
    }
    
    //Account for case where filter is applied
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        let query = PFQuery(className: "RallyEvent")
//        let cell : UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)!
        let row = indexPath.row
        query.whereKey("eventTitle", equalTo: self.eventTitles[row])
        query.findObjectsInBackgroundWithBlock {
            (rallyEvents, error) -> Void in
            if (error == nil) {
                //Reset feed filter
                self.currentFilter = "No Filter"
                self.previousFilter = "No Filter"
                self.viewWillAppear(true)
                let rallyEvent = rallyEvents?.first as! PFObject
                self.performSegueWithIdentifier("displayRallyEvent", sender: rallyEvent)
            }
        }
    }
    
    func redirectToLogin() {
        let promptLogin = UIAlertView(title: "Login Required", message: "Please login to create a new Rally Event", delegate: self, cancelButtonTitle: "OK")
        promptLogin.show()
        self.performSegueWithIdentifier("redirectToSignupFromEventFeed", sender: self)
    }
    
    
    @IBAction func checkUserLoggedIn(sender: AnyObject) {
        if (PFUser.currentUser() == nil) {
            let promptLogin = UIAlertView(title: "Login Required", message: "Please login to use an event filter", delegate: self, cancelButtonTitle: "OK")
            promptLogin.show()
            self.performSegueWithIdentifier("redirectToSignupFromEventFeed", sender: self)
        } else {
            self.performSegueWithIdentifier("displayEventFilter", sender: self)
        }
    }
    
    @IBAction func createRallyEvent(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        if (currentUser == nil) {
            redirectToLogin()
            return
        }
        else {
            self.performSegueWithIdentifier("createRallyEvent", sender: self)
        }
    }
    
    @IBAction func cancelNewRallyEvent(sender: UIStoryboardSegue) {
    }
    
    @IBAction func saveNewRallyEvent(sender: UIStoryboardSegue) {
    }
    
    @IBAction func updateEventFilter(sender: UIStoryboardSegue) {
    }
    
}