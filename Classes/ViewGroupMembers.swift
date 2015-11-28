//
//  ViewGroupMembers.swift
//  Rally
//
//  Created by Cody Sugarman on 8/2/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse

class ViewGroupMembers: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var rallyGroup:PFObject!
    
    @IBOutlet weak var tableView: UITableView!

    let textCellIdentifier = "userCell"
    var memberNames = [String]()
    var memberImageFiles = [PFFile]()
    let query = PFUser.query()
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func getMemberImages() {
        for name in memberNames {
            query!.whereKey("username", equalTo:name)
            let user = query!.findObjects()!.first as! PFObject
            let profileImageFile = user["profilePicture"] as! PFFile
            self.memberImageFiles.append(profileImageFile)
        }
    }
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        memberNames = rallyGroup["groupMemberUsernames"] as! [String]!
        getMemberImages()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberNames.count
    }
    
    // Assume all users have an associated picture (give users without images placeholders)
    func setProfileImage(cell :UserCell, row :Int) {
        cell.profileImage.layer.masksToBounds = false
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
        cell.profileImage.clipsToBounds = true
        let profileImageFile = memberImageFiles[row]
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
        cell.profileName.text = memberNames[row]
        setProfileImage(cell, row: row)
        return cell
    }
    
//    // When row tapped:
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        let row = indexPath.row
//        let selectedUsername = memberNames[row]
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
