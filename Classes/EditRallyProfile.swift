//
//  EditRallyProfile.swift
//  Rally
//
//  Created by Cody Sugarman on 7/15/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse

class EditRallyProfile: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var userProfileImage: UIImageView!    
//    @IBOutlet weak var userAboutMe: UITextView!
    let imagePicker = UIImagePickerController()

    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userProfileImage.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    func changeProfilePhoto() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func setProfilePhoto(currentUser :PFUser) {
        let userImageFile = currentUser["profilePicture"] as! PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if (error == nil) {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    self.userProfileImage.image = image
                }
            }
        }
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        let currentUser = PFUser.currentUser()
        if (currentUser == nil) {
            redirectToLogin()
            return
        }
        imagePicker.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: "changeProfilePhoto")
        userProfileImage.addGestureRecognizer(tapGesture)
        userProfileImage.userInteractionEnabled = true
//        if (currentUser!["aboutMe"] != nil) {
//            userAboutMe.text = currentUser!["aboutMe"] as! String
//        }
        setProfilePhoto(currentUser!)
        userProfileImage.layer.masksToBounds = false
        userProfileImage.layer.borderColor = UIColor.blackColor().CGColor
        userProfileImage.layer.cornerRadius = userProfileImage.frame.height/2
        userProfileImage.clipsToBounds = true
    }
    
    func redirectToLogin() {
        let promptLogin = UIAlertView(title: "Login Required", message: "Please login to view your Rally proile", delegate: self, cancelButtonTitle: "OK")
        promptLogin.show()
        performSegueWithIdentifier("redirectToSignupFromEditProfile", sender: self)
    }
    
    @IBAction func saveUserProfile(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
//        let aboutMe = userAboutMe.text
        let imageData = UIImageJPEGRepresentation(userProfileImage.image!, 0.5)
        let imageFile = PFFile(data:imageData!)
        if let currentUser = currentUser {
//            currentUser["aboutMe"] = aboutMe
            currentUser["profilePicture"] = imageFile
        }
        informUserChangesSaved()
        currentUser!.saveInBackground()
    }
    
    func removeUserFromGroup(currentUser :PFUser, group :String, groupQuery :PFQuery) {
        groupQuery.whereKey("groupName", equalTo:group)
        let groups = groupQuery.findObjects()
        let group = groups!.first as! PFObject
        var usersInGroup = group["groupMemberUsernames"] as! [String]
        let indexOfUserToRemove = usersInGroup.indexOf(currentUser.username!) as Int!
        usersInGroup.removeAtIndex(indexOfUserToRemove!)
        group["groupMemberUsernames"] = usersInGroup
        let updatedNumMembers = group["groupNumMembers"] as! Int - 1
        group["groupNumMembers"] = updatedNumMembers
        group.saveInBackground()
    }
    
    func removeUserFromEvent(currentUser :PFUser, event :String, eventQuery :PFQuery) {
        eventQuery.whereKey("eventTitle", equalTo:event)
        let events = eventQuery.findObjects()
        let event = events!.first as! PFObject
        var usersInEvent = event["eventAttendeeUsernames"] as! [String]
        let indexOfUserToRemove = usersInEvent.indexOf(currentUser.username!) as Int!
        usersInEvent.removeAtIndex(indexOfUserToRemove!)
        event["eventAttendeeUsernames"] = usersInEvent
        let updatedNumAttendees = event["eventNumAttendees"] as! Int - 1
        event["eventNumAttendees"] = updatedNumAttendees
        event.saveInBackground()
    }
    
    func removeUserFromEventsAndGroups(currentUser :PFUser) {
        // Remove from groups
        let groupQuery = PFQuery(className: "RallyGroup")
        let userGroups = currentUser["groupsMemberOf"] as! [String]
        for group in userGroups {
            removeUserFromGroup(currentUser, group: group, groupQuery: groupQuery)
        }
        
        // Remove from events
        let eventQuery = PFQuery(className: "RallyEvent")
        let userEvents = currentUser["eventsAttending"] as! [String]
        for event in userEvents {
            removeUserFromEvent(currentUser, event: event, eventQuery: eventQuery)
        }
    }
    
    func removeUserFromPushChannels(currentUser :PFUser) {
        let currentInstallation = PFInstallation.currentInstallation()
        let subscribedChannels = currentInstallation.channels as! [String]
        for channel in subscribedChannels {
            currentInstallation.removeObject(channel, forKey: "channels")
        }
        currentInstallation.saveInBackground()
    }
    
    @IBAction func deleteUserProfile(sender: AnyObject) {
        let deleteWarning = UIAlertController(title: "Delete Rally Profile", message: "Are you sure you want to delete your Rally profile? All existing data will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
        deleteWarning.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            let currentUser = PFUser.currentUser()
            self.removeUserFromEventsAndGroups(currentUser!)
            self.removeUserFromPushChannels(currentUser!)
            PFUser.currentUser()!.deleteInBackground()
            PFUser.logOut()
            self.displayDeleteSuccess()
            self.performSegueWithIdentifier("redirectToSignupFromEditProfile", sender: self)
        }))
        deleteWarning.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        presentViewController(deleteWarning, animated: true, completion: nil)
    }
    
    func displayDeleteSuccess() {
        let deleteSuccess = UIAlertView(title: "User Deleted", message: "You have successfully deleted your Rally account.", delegate: self, cancelButtonTitle: "OK")
        deleteSuccess.show()
    }
    
    func informUserChangesSaved() {
        let informUserSaved = UIAlertView(title: "Profile Updated!", message: "You have successfully updated your Rally profile.", delegate: self, cancelButtonTitle: "OK")
        informUserSaved.show()
    }

}
