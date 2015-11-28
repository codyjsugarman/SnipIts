//
//  ViewRallyGroup.swift
//  Rally
//
//  Created by Cody Sugarman on 7/13/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse

class ViewRallyGroup: UITableViewController {
    
    @IBOutlet weak var reportGroupButton: UIButton!
    var rallyGroup:PFObject!
    
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupMembers: UITextField!
    @IBOutlet weak var groupType: UITextField!
    @IBOutlet weak var groupDescription: UITextView!
    @IBOutlet weak var groupActionButton: UIButton!
    
    @IBAction func reportGroup(sender: AnyObject) {
//        let reportWarning = UIAlertController(title: "Report Rally Group", message: "Are you sure you want to report this group? Our team will investigate and potentially remove this content.", preferredStyle: UIAlertControllerStyle.Alert)
//        reportWarning.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
//            self.rallyGroup["hasBeenReported"] = true
//            self.rallyGroup.saveInBackground()
//            self.displayReportSuccess()
//        }))
//        reportWarning.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
//        }))
//        presentViewController(reportWarning, animated: true, completion: nil)
        self.rallyGroup["hasBeenReported"] = true
        self.rallyGroup.saveInBackground()
        self.displayReportSuccess()
    }
    
    func displayReportSuccess() {
        let reportSuccess = UIAlertView(title: "Group Reported", message: "This group has been flagged and will be investigated further.", delegate: self, cancelButtonTitle: "OK")
        reportSuccess.show()
    }
    
    func hasJoinedGroup (currentUser :PFUser) -> Bool {
        let usersInGroup = rallyGroup["groupMemberUsernames"] as! [String]
        let groupName = rallyGroup["groupName"] as! String
        let groupsUserMemberOf = currentUser["groupsMemberOf"] as! [String]
        if (usersInGroup.indexOf(currentUser.username!) != nil && groupsUserMemberOf.indexOf(groupName) != nil) {
            return true
        }
        return false
    }
    
    func setGroupPhoto(rallyGroup :PFObject) {
        let groupImageFile = rallyGroup["groupImage"] as! PFFile
        groupImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if (error == nil) {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    self.groupImage.image = image
                }
            }
        }
    }
    
    func setGroupInfo(rallyGroup :PFObject) {
        setGroupPhoto(rallyGroup)
        let numMembers = rallyGroup["groupNumMembers"] as! Int!
        groupDescription.text = rallyGroup["groupDescription"] as! String!
        groupMembers.text = String(numMembers)
        groupType.text = rallyGroup["groupType"] as! String!
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLoad() {
        setGroupInfo(rallyGroup)
        self.title = rallyGroup["groupName"] as! String!
        let currentUser = PFUser.currentUser()
        if (currentUser != nil) {
            if (hasJoinedGroup(currentUser!)) {
                groupActionButton.setTitle("Unfollow Group", forState: .Normal)
            } else {
                groupActionButton.setTitle("Follow Group", forState: .Normal)
            }
        }
    }
    
    func redirectToLogin() {
        let promptLogin = UIAlertView(title: "Login Required", message: "Please login to support a Rally Group", delegate: self, cancelButtonTitle: "OK")
        promptLogin.show()
        self.performSegueWithIdentifier("redirectToSignupFromGroup", sender: self)
    }
    
    @IBAction func joinOrLeaveRallyGroup(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        let currentInstallation = PFInstallation.currentInstallation()
        if (currentUser == nil) {
            redirectToLogin()
            return
        }
        var usersInGroup = rallyGroup["groupMemberUsernames"] as! [String]
        var groupsUserMemberOf = [String]()
        if let currentUser = currentUser {
            groupsUserMemberOf = currentUser["groupsMemberOf"] as! [String]
        }
        
        //Join Rally Group
        if (!hasJoinedGroup(currentUser!)) {
            addUserToGroup(currentUser!, usersInGroup: &usersInGroup)
            addGroupToUser(currentUser!, groupsUserMemberOf: &groupsUserMemberOf, currentInstallation: currentInstallation)
            informUserJoinedGroup()
        //Leave Rally Group
        } else {
            removeUserFromGroup(currentUser!, usersInGroup: &usersInGroup)
            removeGroupfromUser(currentUser!, groupsUserMemberOf: &groupsUserMemberOf, currentInstallation: currentInstallation)
            informUserLeftGroup()
        }
        
        rallyGroup.saveInBackground()
        currentUser!.saveInBackground()
        currentInstallation.saveInBackground()
        viewDidLoad()
    }
    
    func informUserLeftGroup() {
        let leftRallyGroup = UIAlertView(title: "Left Rally Group", message: "You've been removed from this group.)", delegate: self, cancelButtonTitle: "OK")
        leftRallyGroup.show()
    }
    
    func removeGroupfromUser(currentUser :PFUser, inout groupsUserMemberOf :[String], currentInstallation: PFInstallation) {
        let groupName = rallyGroup["groupName"] as! String!
        let indexOfGroupToRemove = groupsUserMemberOf.indexOf(groupName)
        groupsUserMemberOf.removeAtIndex(indexOfGroupToRemove!)
        currentUser["groupsMemberOf"] = groupsUserMemberOf
        let groupChannel = groupName.stringByReplacingOccurrencesOfString(" ", withString: "")
        currentInstallation.removeObject(groupChannel, forKey: "channels")
    }
    
    func removeUserFromGroup(currentUser :PFUser, inout usersInGroup :[String]) {
        let indexOfUserToRemove = usersInGroup.indexOf(currentUser.username!) as Int!        
        usersInGroup.removeAtIndex(indexOfUserToRemove!)
        rallyGroup["groupMemberUsernames"] = usersInGroup
        var updatedNumMembers = rallyGroup["groupNumMembers"] as! Int
        updatedNumMembers--
        rallyGroup["groupNumMembers"] = updatedNumMembers
    }
    
    func informUserJoinedGroup() {
        let joinedRallyGroup = UIAlertView(title: "Joined Rally Group", message: "Congratulations! You've joined this group!", delegate: self, cancelButtonTitle: "OK")
        joinedRallyGroup.show()
    }
    
    func addUserToGroup(currentUser :PFUser, inout usersInGroup :[String]) {
        usersInGroup.append(currentUser.username!)
        rallyGroup["groupMemberUsernames"] = usersInGroup
        var updatedNumMembers = rallyGroup["groupNumMembers"] as! Int
        updatedNumMembers++
        rallyGroup["groupNumMembers"] = updatedNumMembers
    }
    
    func addGroupToUser(currentUser :PFUser, inout groupsUserMemberOf :[String], currentInstallation :PFInstallation) {
        let groupName = rallyGroup["groupName"] as! String!
        groupsUserMemberOf.append(groupName)
        currentUser["groupsMemberOf"] = groupsUserMemberOf
        let groupChannel = groupName.stringByReplacingOccurrencesOfString(" ", withString: "")
        currentInstallation.addUniqueObject(groupChannel, forKey: "channels")
    }
    
    // Send rallyGroup to next page
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "displayGroupMembers") {
            let detailController = segue.destinationViewController as! ViewGroupMembers
            detailController.rallyGroup = rallyGroup
        }
    }
    
}
