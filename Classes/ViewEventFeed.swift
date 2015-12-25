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
    
    var eventDateOrder = [String:[Int]]()
    var eventDates = [String]()
    var eventTitles = [String]()
    var eventLocations = [String]()
    var eventImageFiles = [PFFile]()
    var eventTimes = [String]()
    var eventNumAttendees = [Int]()
    var currentFilter = "No Filter"
    var previousFilter = "No Filter"
    let reuseIdentifier = "collCell"
    var query = PFQuery(className: "RallyEvent")
    var rallyEventList = [PFObject]()
    
    let sectionInsets = UIEdgeInsets(top: 0.0, left: 65.0, bottom: 0.0, right: 65.0)
    
    @IBOutlet weak var subview: UIView!
    
    // Create a MessageComposer
    let messageComposer = MessageComposer()
    
    @IBAction func sendTextMessageButtonTapped(sender: UIButton) {
        // Make sure the device can send text messages
        if (messageComposer.canSendText()) {
            // Obtain a configured MFMessageComposeViewController
            let messageComposeVC = messageComposer.configuredMessageComposeViewController()
            
            // Present the configured MFMessageComposeViewController instance
            // Note that the dismissal of the VC will be handled by the messageComposer instance,
            // since it implements the appropriate delegate call-back
            presentViewController(messageComposeVC, animated: true, completion: nil)
        } else {
            // Let the user know if his/her device isn't able to send text messages
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
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
            var eventNum = 0
            for event in eventsAttending {
                query = PFQuery(className: "RallyEvent")
                query.whereKey("eventTitle", equalTo: event)
                query.findObjectsInBackgroundWithBlock {
                    (events, error) -> Void in
                    if (error == nil && events?.first != nil) {
                        let event = events!.first as! PFObject
                        self.getEventDate(event, eventNum: eventNum)
                        self.getEventTitle(event, eventNum: eventNum)
                        self.getEventLocation(event, eventNum: eventNum)
                        self.getEventImage(event, eventNum: eventNum)
                        self.getEventNumAttendees(event, eventNum: eventNum)
                        self.rallyEventList.append(event)
                        eventNum++
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
    
    func getEventTitle(rallyEvent :AnyObject, eventNum :Int) {
        self.eventTitles.append(rallyEvent["eventTitle"] as! String)
    }
    
    func getEventNumAttendees(rallyEvent :AnyObject, eventNum :Int) {
        self.eventNumAttendees.append(rallyEvent["eventNumAttendees"] as! Int)
    }
    
    func getEventImage(rallyEvent :AnyObject, eventNum :Int) {
        let eventImageFile = rallyEvent["eventImage"] as! PFFile
        self.eventImageFiles.append(eventImageFile)
    }
    
    func getEventLocation(rallyEvent :AnyObject, eventNum :Int) {
        let eventLocation = rallyEvent["eventLocation"] as! String
        self.eventLocations.append(eventLocation)
    }
    
    func getEventDate(rallyEvent :AnyObject, eventNum :Int) {
        let eventDate = rallyEvent["eventDate"] as! String
        var eventArray = eventDate.componentsSeparatedByString(", ")
        let dateString = eventArray[0]
        let timeString = eventArray[1]
        self.eventDates.append(dateString)
        self.eventTimes.append(timeString)
        if (self.eventDateOrder[dateString] == nil) {
            self.eventDateOrder[dateString] = [eventNum]
        } else {
            self.eventDateOrder[dateString]?.append(eventNum)
        }
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
        eventImageFiles = [PFFile]()
        eventLocations = [String]()
        rallyEventList = [PFObject]()
        eventDates = [String]()
        eventDateOrder = [String:[Int]]()
        eventTimes = [String]()
        eventNumAttendees = [Int]()
    }
    
    func populateEventFeed(rallyEvents :[AnyObject]) {
        var eventNum = 0
        for rallyEvent in rallyEvents {
            getEventDate(rallyEvent, eventNum: eventNum)
            getEventTitle(rallyEvent, eventNum: eventNum)
            getEventLocation(rallyEvent, eventNum: eventNum)
            getEventNumAttendees(rallyEvent, eventNum: eventNum)
            getEventImage(rallyEvent, eventNum: eventNum)
            rallyEventList.append(rallyEvent as! PFObject)
            eventNum++
        }
        let eventOrder = getEventSortedOrder()
        sortEventFeed(eventOrder)
    }
    
    func sortEventFeed(eventOrder:[(String, [Int])]) {
        let correctEventOrder = getEventOrder(eventOrder)
        
        var newDatesOrder = [String]()
        var newTimesOrder = [String]()
        var newTitlesOrder = [String]()
        var newLocationsOrder = [String]()
        var newPhotosOrder = [PFFile]()
        var newNumAttendeesOrder = [Int]()
        var newEventOrder = [PFObject]()
        
        for eventNum in correctEventOrder {
            newDatesOrder.append(eventDates[eventNum])
            newTimesOrder.append(eventTimes[eventNum])
            newTitlesOrder.append(eventTitles[eventNum])
            newLocationsOrder.append(eventLocations[eventNum])
            newEventOrder.append(rallyEventList[eventNum])
            newPhotosOrder.append(eventImageFiles[eventNum])
            newNumAttendeesOrder.append(eventNumAttendees[eventNum])
        }
        
        eventDates = newDatesOrder
        eventTimes = newTimesOrder
        eventTitles = newTitlesOrder
        eventLocations = newLocationsOrder
        rallyEventList = newEventOrder
        eventImageFiles = newPhotosOrder
        eventNumAttendees = newNumAttendeesOrder
        
    }
    
    func getEventOrder(eventOrder:[(String, [Int])]) -> [Int] {
        var newEventOrder = [Int]()
        for event in eventOrder {
            newEventOrder.appendContentsOf(event.1)
        }
        return newEventOrder
    }
    
    func getEventSortedOrder() -> [(String, [Int])]{
        let df = NSDateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        let myArrayOfTuples = eventDateOrder.sort{ df.dateFromString($0.0)!.compare(df.dateFromString($1.0)!) == .OrderedAscending}
        return myArrayOfTuples
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
    
    func createUserProfile() {
        let rallyUser = PFUser()
        rallyUser.username = randomStringWithLength(10) as String
        rallyUser.password = ""
        rallyUser["eventsAttending"] = [String]()
        rallyUser["groupsMemberOf"] = [String]()
        rallyUser["displayedSplashPages"] = [false, false, false]
        let userPlaceholderImage = UIImage(named:"BlankProfile.png")
        let imageData = UIImageJPEGRepresentation(userPlaceholderImage!, 0.5)
        let imageFile = PFFile(data:imageData!)
        rallyUser["profilePicture"] = imageFile
        rallyUser.signUpInBackground()
        rallyUser.save()
        let alert = UIAlertView(title: "Success", message: "Welcome to SnipIts!", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func randomStringWithLength (len : Int) -> NSString {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for (var i=0; i < len; i++){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        return randomString
    }
    
    override func viewDidAppear(animated: Bool) {
        let currentUser = PFUser.currentUser()
        if (currentUser == nil) {
            createUserProfile()
        }
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
        let eventTitle = self.eventTitles[indexPath.row % eventTitles.count]
        let numAttendees = self.eventNumAttendees[indexPath.row] as Int
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        cell.title.text = eventTitle
        cell.numAttendees.text = String(numAttendees)
        cell.rallyEvent = self.rallyEventList[indexPath.row]
        setEventImage(cell, row: indexPath.row)
        let dateAndTime = synthesizeDateAndTime(eventDates[indexPath.row], eventTime: eventTimes[indexPath.row])
        cell.eventDate.text = dateAndTime + " @ " + eventLocations[indexPath.row]
        if (PFUser.currentUser() != nil) {
            if (hasJoinedEvent(currentUser!, eventTitle: eventTitle, rallyEvent: event)) {
                cell.joinOrLeaveEventButton.setImage(UIImage(named: "JoinedEvent.png"), forState: UIControlState.Normal)
            } else {
                cell.joinOrLeaveEventButton.setImage(UIImage(named: "JoinEvent.png"), forState: UIControlState.Normal)
            }
        }
        return cell
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
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let requiredWidth = collectionView.bounds.size.width
            return CGSize(width: requiredWidth, height: 420)
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