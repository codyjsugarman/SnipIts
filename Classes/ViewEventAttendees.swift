//
//  ViewEventAttendees.swift
//  Rally
//
//  Created by Cody Sugarman on 7/31/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse

class ViewEventAttendees: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var rallyEvent:PFObject!

    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "userCell"
    var attendeeNames = [String]()
    var attendeeImageFiles = [PFFile]()
    let query = PFUser.query()

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        attendeeNames = rallyEvent["eventAttendeeUsernames"] as! [String]
        for name in attendeeNames {
            query!.whereKey("username", equalTo:name)
            let user = query!.findObjects()!.first as! PFObject
            let profileImageFile = user["profilePicture"] as! PFFile
            self.attendeeImageFiles.append(profileImageFile)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendeeNames.count
    }
    
    // Assume all users have an associated picture (give users without images placeholders)
    func setProfileImage(cell :UserCell, row :Int) {
        cell.profileImage.layer.masksToBounds = false
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
        cell.profileImage.clipsToBounds = true
        let profileImageFile = attendeeImageFiles[row]
        profileImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if (error == nil) {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    cell.profileImage.image = image
                }
            }
        }
    }
    
    //Sets cell data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! UserCell
        
        let row = indexPath.row
        cell.profileName.text = attendeeNames[row]
        setProfileImage(cell, row: row)
        return cell
    }
    
    // When row tapped:
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        let row = indexPath.row
//        let selectedUsername = attendeeNames[row]
//        query!.whereKey("username", equalTo:selectedUsername)
//        let selectedUser = query!.findObjects()!.first as! PFUser
//        self.performSegueWithIdentifier("displayRallyUser", sender: selectedUser)
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "displayRallyUser") {
            let detailController = segue.destinationViewController as! ViewAttendeeProfile
            let selectedUser = sender as! PFUser
            detailController.selectedUser = selectedUser
        }
    }
    
}