//
//  ViewAttendeeProfile.swift
//  Rally
//
//  Created by Cody Sugarman on 8/1/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse


class ViewAttendeeProfile: UITableViewController {
    var selectedUser:PFUser!
    
    @IBOutlet weak var selectedUserName: UITextField!
    @IBOutlet weak var selectedUserImage: UIImageView!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var userGroups: UITextField!
    
    
    @IBAction func reportUser(sender: AnyObject) {
        let reportWarning = UIAlertController(title: "Report Rally User", message: "Are you sure you want to report this user? Our team will investigate and potentially remove this content.", preferredStyle: UIAlertControllerStyle.Alert)
        reportWarning.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            self.selectedUser["hasBeenReported"] = true
            self.selectedUser.saveInBackground()
            self.displayReportSuccess()
        }))
        reportWarning.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        presentViewController(reportWarning, animated: true, completion: nil)
    }
    
    func displayReportSuccess() {
        let reportSuccess = UIAlertView(title: "User Reported", message: "You have successfully reported this user.", delegate: self, cancelButtonTitle: "OK")
        reportSuccess.show()
    }
    
    func setUserPhoto() {
        let userImageFile = selectedUser["profilePicture"] as! PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if (error == nil) {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    self.selectedUserImage.image = image
                }
            }
        }
        selectedUserImage.layer.masksToBounds = false
        selectedUserImage.layer.borderColor = UIColor.blackColor().CGColor
        selectedUserImage.layer.cornerRadius = selectedUserImage.frame.height/2
        selectedUserImage.clipsToBounds = true
    }
    
    func setGroupInfo() {
        let groupsMemberOf = selectedUser["groupsMemberOf"] as! [String!]
        let numGroups = groupsMemberOf.count
        var groupList = ""
        if (numGroups > 2) {
            groupList += groupsMemberOf[0] + ", " + groupsMemberOf[1]
            let extraGroups = numGroups-2
            groupList += " +\(extraGroups) more"
        } else if (numGroups == 2) {
            groupList += groupsMemberOf[0] + ", " + groupsMemberOf[1]
        } else if (numGroups == 1) {
            groupList += groupsMemberOf[0]
        } else {
            groupList += "No Groups"
        }
        userGroups.text = groupList
        userDescription.text = selectedUser["aboutMe"] as! String!
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewWillAppear(animated: Bool) {
        selectedUserName.text = selectedUser.username
        setGroupInfo()
        setUserPhoto()
    }
    
}
