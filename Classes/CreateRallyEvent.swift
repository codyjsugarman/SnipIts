//
//  CreateRallyEvent.swift
//  Rally
//
//  Created by Cody Sugarman on 7/28/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse
import Foundation

class CreateRallyEvent: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    let imagePicker = UIImagePickerController()
    
    let categoryPicker = UIPickerView()
    let categoryPickerOptions = ["Community Service", "Lecture", "Party", "Performance", "Pick-up Games", "Political Awareness", "Pre-party", "Pre-professional", "Social Activism", "Sporting Event", "Study Groups", "Other"]
    let sponsorPicker = UIPickerView()
    var sponsorPickerOptions = ["No Sponsor"]
    
//    let targetPicker = UIPickerView()
//    let targetPickerOptions = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 250]
    
//    let daysToRallyPicker = UIPickerView()
//    let daysToRallyPickerOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventCategory: UITextField!
    @IBOutlet weak var eventSponsor: UITextField!
    @IBOutlet weak var eventDate: UITextField!
//    @IBOutlet weak var eventTarget: UITextField!
//    @IBOutlet weak var eventDaysToRally: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    
    
    func setUpSponsorOptions() {
        let currentUser = PFUser.currentUser()
        var groupsMemberOf = [""]
        if let currentUser = currentUser {
            groupsMemberOf = currentUser["groupsMemberOf"] as! [String]
        }
        for group in groupsMemberOf {
            sponsorPickerOptions.append(group)
        }
    }
    
    func setUpPickers() {
        imagePicker.delegate = self
        sponsorPicker.delegate = self
        sponsorPicker.dataSource = self
        sponsorPicker.tag = 1
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryPicker.tag = 2
//        targetPicker.delegate = self
//        targetPicker.dataSource = self
//        targetPicker.tag = 3
//        daysToRallyPicker.delegate = self
//        daysToRallyPicker.dataSource = self
//        daysToRallyPicker.tag = 4
        setUpSponsorOptions()
    }
    
    func setUpEventImage() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "changeEventImage")
        eventImage.addGestureRecognizer(tapGesture)
        eventImage.userInteractionEnabled = true
        let userPlaceholderImage = UIImage(named:"BlankEvent.png")
        eventImage.image = userPlaceholderImage
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLoad() {
        setUpPickers()
        setUpEventImage()
    }
    
    // Handles the image picker
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            eventImage.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func changeEventImage() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Handles the category picker
    @IBAction func categoryFieldSelected(sender: UITextField) {
        sender.inputView = categoryPicker
    }
    
    // Handles the sponsor picker
    @IBAction func sponsorFieldSelector(sender: UITextField) {
        sender.inputView = sponsorPicker
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Sponsors
        if (pickerView.tag == 1) {
            return sponsorPickerOptions.count
        }
        // Category
        else if (pickerView.tag == 2) {
            return categoryPickerOptions.count
        }
        // Target
//        else if (pickerView.tag == 3) {
//            return targetPickerOptions.count
//        }
//        // Days to rally
//        else if (pickerView.tag == 4) {
//            return daysToRallyPickerOptions.count
//        }
        return -1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Sponsor
        if (pickerView.tag == 1) {
            return sponsorPickerOptions[row]
        }
        // Category
        else if (pickerView.tag == 2) {
            return categoryPickerOptions[row]
        }
        // Target
//        else if (pickerView.tag == 3) {
//            return String(targetPickerOptions[row])
//        }
        // Days to rally
//        else if (pickerView.tag == 4) {
//            return String(daysToRallyPickerOptions[row])
//        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Sponsor
        if (pickerView.tag == 1) {
            eventSponsor.text = sponsorPickerOptions[row]
        }
        // Category
        else if (pickerView.tag == 2) {
            eventCategory.text = categoryPickerOptions[row]
        }
        // Target
//        else if (pickerView.tag == 3) {
//            eventTarget.text = String(targetPickerOptions[row])
//        }
        // Days to rally
//        else if (pickerView.tag == 4) {
//            eventDaysToRally.text = String(daysToRallyPickerOptions[row])
//        }
    }
    
    // Handles the date picker
    func handleDatePicker(sender: UIDatePicker) {
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = .ShortStyle
        timeFormatter.timeStyle = .ShortStyle
        eventDate.text = timeFormatter.stringFromDate(sender.date)
    }
    
    @IBAction func dateFieldSelected(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        datePickerView.minimumDate = NSDate()
    }
    
//    @IBAction func targetFieldSelected(sender: UITextField) {
//        sender.inputView = targetPicker
//    }
    
//    @IBAction func daysToRallyFieldSelected(sender: UITextField) {
//        sender.inputView = daysToRallyPicker
//    }
    
    // Save/Cancel event actions
    func fieldsFull() -> Bool {
        if (eventTitle.text == "" || eventDate.text == "" || eventCategory.text == "" || eventDescription.text == "" || eventLocation.text == "" || eventSponsor.text == "") {
            let fieldsEmptyAlert = UIAlertView(title: "Fields Empty", message: "Please fill out all event fields", delegate: self, cancelButtonTitle: "OK")
            fieldsEmptyAlert.show()
            return false
        }
        return true
    }
    
//    func intIsString() -> Bool {
//        if (Int(eventTarget.text!) != nil) {
//            return true
//        }
//        let pleaseEnterInteger = UIAlertView(title: "Please Enter an Integer", message: "Please enter an integer for both the event target and days to rally field", delegate: self, cancelButtonTitle: "OK")
//        pleaseEnterInteger.show()
//        return false
//    }
    
    func sponsorIsSponsor() -> Bool {
        if (sponsorPickerOptions.indexOf(eventSponsor.text!) != nil) {
            return true
        }
        let pleaseSelectSponsor = UIAlertView(title: "Please Select a Valid Event Sponsor", message: "If there is no sponsor, select \"No Sponsor\"", delegate: self, cancelButtonTitle: "OK")
        pleaseSelectSponsor.show()
        return false
    }
    
    func categoryIsCategory() -> Bool {
        if (categoryPickerOptions.indexOf(eventCategory.text!) != nil) {
            return true
        }
        let pleaseSelectCategory = UIAlertView(title: "Please Select a Valid Event Category", message: "If no category fits your event, select \"Other\"", delegate: self, cancelButtonTitle: "OK")
        pleaseSelectCategory.show()
        return false
    }
    
    func titleIsAlphanumeric() -> Bool {
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9 ].*", options: [])
        if regex.firstMatchInString(eventTitle.text!, options: [], range: NSMakeRange(0, eventTitle.text!.characters.count)) != nil {
            let noSpecialChars = UIAlertView(title: "No Special Characters in Event Title", message: "Please enter only alphanumeric characters for your event title", delegate: self, cancelButtonTitle: "OK")
            noSpecialChars.show()
            return false
        }
        return true
    }
    
    func validateEventFields() -> Bool {
        if (fieldsFull() && sponsorIsSponsor() && categoryIsCategory() && titleIsAlphanumeric()) {
            return true
        }
        return false
    }

    func saveEventImage (newRallyEvent: PFObject) {
        let imageData = UIImageJPEGRepresentation(eventImage.image!, 0.5)
        let imageFile = PFFile(data:imageData!)
        newRallyEvent["eventImage"] = imageFile
    }
    
    func populateRallyEventFields(newRallyEvent: PFObject, currentUser: PFUser) {
        saveEventImage(newRallyEvent)
        newRallyEvent["eventTitle"] = eventTitle.text
        newRallyEvent["eventLocation"] = eventLocation.text
        newRallyEvent["eventDate"] = eventDate.text
//        newRallyEvent["eventTargetNumAttendees"] = Int(eventTarget.text!)
//        newRallyEvent["eventNumDaysFundraising"] = Int(eventDaysToRally.text!)
        newRallyEvent["eventNumAttendees"] = 1
        newRallyEvent["eventIsHappening"] = false
        let eventAttendees = [currentUser.username] as [String!]
        newRallyEvent["eventAttendeeUsernames"] = eventAttendees
        newRallyEvent["eventAdmin"] = currentUser.username
        newRallyEvent["eventSponsor"] = eventSponsor.text
        newRallyEvent["eventCategory"] = eventCategory.text
        newRallyEvent["eventDescription"] = eventDescription.text
        newRallyEvent["hasSentSuccessNotification"] = false
        newRallyEvent["hasSentClosedNotification"] = false
    }
    
    func setCurrentUserAttendingEvent(currentUser: PFUser) {
        var currentUsersEvents = currentUser["eventsAttending"] as! [String]
        currentUsersEvents.append(eventTitle.text!)
        currentUser["eventsAttending"] = currentUsersEvents
        let currentInstallation = PFInstallation.currentInstallation()
        let eventChannel = eventTitle.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
        currentInstallation.addUniqueObject(eventChannel, forKey: "channels")
        currentInstallation.saveInBackground()
        currentUser.saveInBackground()
    }
    
    func sendNewEventNotificationToGroup() {
        if (eventSponsor.text != "No Sponsor") {
            let push = PFPush()
            let groupChannel = eventSponsor.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
            push.setChannel(groupChannel)
            push.setMessage("A new event - \(eventTitle.text) - has just been created by \(eventSponsor.text)!")
            push.sendPushInBackground()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "saveNewRallyEvent") {
            let currentUser = PFUser.currentUser()
            if (validateEventFields()) {
                let newRallyEvent = PFObject(className:"RallyEvent")
                populateRallyEventFields(newRallyEvent, currentUser: currentUser!)
                setCurrentUserAttendingEvent(currentUser!)
                sendNewEventNotificationToGroup()
                newRallyEvent.saveInBackground()
                let viewRallyEventFeed = segue.destinationViewController as! ViewEventFeed
                viewRallyEventFeed.loadNewEvent()
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if (identifier == "saveNewRallyEvent") {
            if (!validateEventFields()) {
                return false
            }
            return true
        }
        return true
    }
    
}