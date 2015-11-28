//
//  ViewRallyGroups.swift
//  Rally
//
//  Created by Cody Sugarman on 7/13/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse


class ViewRallyGroups: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "groupCell"
    var query = PFQuery(className: "RallyGroup")
    var groupNames = [String]()
    var groupDescriptions = [String]()
    var groupNumMembers = [String]()
    var groupImageFiles = [PFFile]()
    var currentFilter = "No Filter"
    var previousFilter = "No Filter"
    
    func loadNewGroup() {
        let uploadingNewGroup : UIAlertView = UIAlertView(title: "Uploading New Rally Group", message: "This may take a few seconds...", delegate: nil, cancelButtonTitle: nil)
        let viewBack:UIView = UIView(frame: CGRectMake(83,0,100,50))
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(50, 10, 37, 37)) as UIActivityIndicatorView
        loadingIndicator.center = viewBack.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating()
        viewBack.addSubview(loadingIndicator)
        viewBack.center = self.view.center
        uploadingNewGroup.setValue(viewBack, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        uploadingNewGroup.show()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 5))
        dispatch_after(delayTime, dispatch_get_main_queue()){
            uploadingNewGroup.dismissWithClickedButtonIndex(-1, animated: true)
            self.viewWillAppear(true)
            let newRallyGroupCreated = UIAlertView(title: "New Rally Group Created", message: "Congratulations! You're ready to start Rallying!", delegate: self, cancelButtonTitle: "OK")
            newRallyGroupCreated.show()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func getGroupName(rallyGroup: AnyObject) {
        let groupName = rallyGroup["groupName"] as! String!
        self.groupNames.append(groupName)
    }
    
    func getGroupDescription(rallyGroup: AnyObject) {
        let groupDescription = rallyGroup["groupDescription"] as! String!
        self.groupDescriptions.append(groupDescription)
    }
    
    func getGroupNumMembers(rallyGroup: AnyObject) {
        let numMembers = rallyGroup["groupNumMembers"] as! Int!
        self.groupNumMembers.append(String(numMembers))
    }
    
    func getGroupImage(rallyGroup: AnyObject) {
        let groupImageFile = rallyGroup["groupImage"] as! PFFile
        self.groupImageFiles.append(groupImageFile)
    }
    
    func resetGroupFeed() {
        groupNames = [String]()
        groupDescriptions = [String]()
        groupNumMembers = [String]()
        groupImageFiles = [PFFile]()
    }
    
    func populateGroupFeed(rallyGroups :[AnyObject]) {
        for rallyGroup in rallyGroups {
            getGroupName(rallyGroup)
            getGroupDescription(rallyGroup)
            getGroupNumMembers(rallyGroup)
            getGroupImage(rallyGroup)
        }
    }
    
    func filterGroups(currentFilter :String, currentUser :PFUser) {
        if (currentFilter == "My Groups") {
            resetGroupFeed()
            query = PFQuery(className: "RallyGroup")
            let groupsMemberOf = currentUser["groupsMemberOf"] as! [String]
            for group in groupsMemberOf {
                query = PFQuery(className: "RallyGroup")
                query.whereKey("groupName", equalTo: group)
                query.findObjectsInBackgroundWithBlock {
                    (groups, error) -> Void in
                    if (error == nil && groups?.first != nil) {
                        let group = groups!.first as! PFObject
                        self.getGroupName(group)
                        self.getGroupDescription(group)
                        self.getGroupNumMembers(group)
                        self.getGroupImage(group)
                    }
                    self.tableView!.reloadData()
                }
            }
            self.tableView!.reloadData()
        }
    }
    
    func displaySplashPage(currentUser: PFUser) {
        var displayedSplashPages = currentUser["displayedSplashPages"] as! [Bool!]
        if (!displayedSplashPages[1]) {
            self.performSegueWithIdentifier("displayGroupsSplashPage", sender: self)
            self.tabBarController!.tabBar.userInteractionEnabled = false
            displayedSplashPages[1] = true
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
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.tableView.rowHeight = 140.0
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if (currentFilter == "No Filter") {
            query = PFQuery(className: "RallyGroup")
            query.findObjectsInBackgroundWithBlock {
                (rallyGroups, error) -> Void in
                if (error == nil) {
                    self.resetGroupFeed()
                    self.populateGroupFeed(rallyGroups!)
                    self.tableView.reloadData()
                }
            }
        } else {
            filterGroups(currentFilter, currentUser: currentUser!)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupNames.count
    }
    
    func uicolorFromHex(rgbValue:UInt32) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    func setGroupImage(cell :GroupCell, row :Int) {
        let profileImageFile = groupImageFiles[row]
        profileImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if (error == nil) {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    cell.groupImage.image = image
                }
            }
        }
        cell.groupImage.layer.masksToBounds = false
        cell.groupImage.layer.cornerRadius = cell.groupImage.frame.height/2
        cell.groupImage.clipsToBounds = true
        cell.groupImage.layer.borderWidth = 3.0
        cell.groupImage.layer.borderColor = uicolorFromHex(0x399a97).CGColor
    }
    
    //Sets cell data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! GroupCell
        let row = indexPath.row
        cell.groupName.text = groupNames[row]
        cell.groupDescription.text = groupDescriptions[row]
        if (groupNumMembers[row] == "1") {
            cell.numMembers.text = groupNumMembers[row] + " Member"
        } else {
            cell.numMembers.text = groupNumMembers[row] + " Members"
        }
        setGroupImage(cell, row: row)
        return cell
    }
    
    // When row tapped:
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        let selectedGroupName = groupNames[row]
        query.whereKey("groupName", equalTo: selectedGroupName)
        query.findObjectsInBackgroundWithBlock {
            (selectedGroups, error) -> Void in
            if (error == nil) {
                self.currentFilter = "No Filter"
                self.previousFilter = "No Filter"
                self.viewWillAppear(true)
                let selectedGroup = selectedGroups!.first as! PFObject
                self.performSegueWithIdentifier("displayRallyGroup", sender: selectedGroup)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "displayRallyGroup") {
            let detailController = segue.destinationViewController as! ViewRallyGroup
            let rallyGroup = sender as! PFObject
            detailController.rallyGroup = rallyGroup
        }
    }

    func redirectToLogin() {
        let promptLogin = UIAlertView(title: "Login Required", message: "Please login to create a new Rally Group", delegate: self, cancelButtonTitle: "OK")
        promptLogin.show()
        self.performSegueWithIdentifier("redirectToSignupFromGroups", sender: self)
    }
    
    @IBAction func createRallyGroup(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        if (currentUser == nil) {
            redirectToLogin()
            return
        }
        else {
            self.performSegueWithIdentifier("createRallyGroup", sender: self)
        }
    }
    
    @IBAction func checkUserLoggedIn(sender: AnyObject) {
        if (PFUser.currentUser() == nil) {
            let promptLogin = UIAlertView(title: "Login Required", message: "Please login to use a group filter", delegate: self, cancelButtonTitle: "OK")
            promptLogin.show()
            self.performSegueWithIdentifier("redirectToSignupFromGroups", sender: self)
        } else {
            self.performSegueWithIdentifier("displayGroupFilter", sender: self)
        }
    }
    
    func refreshGroups() {
        if (currentFilter != previousFilter) {
            viewWillAppear(true)
            previousFilter = currentFilter
        }
    }
    
    @IBAction func cancelCreateRallyGroup(sender: UIStoryboardSegue) {
    }
    
    @IBAction func saveNewRallyGroup(sender: UIStoryboardSegue) {
    }
    
    @IBAction func updateGroupFilter(sender: UIStoryboardSegue) {
    }
}
