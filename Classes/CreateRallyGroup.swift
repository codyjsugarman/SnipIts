//
//  CreateRallyGroup.swift
//  Rally
//
//  Created by Cody Sugarman on 7/29/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse

class CreateRallyGroup: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    let imagePicker = UIImagePickerController()
    let typePicker = UIPickerView()
    let typePickerOptions = ["Activism", "Arts/Culture", "Athletic", "Community Service", "Educational", "Greek Organizations", "Pre-professional", "Social", "Student Government", "Other"]
    
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var groupDescription: UITextField!
    @IBOutlet weak var groupType: UITextField!
    @IBOutlet weak var groupInfo: UITextView!
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typePickerOptions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typePickerOptions[row]
    }
    
    @IBAction func typeFieldSelected(sender: UITextField) {
        sender.inputView = typePicker
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        groupType.text = typePickerOptions[row]
    }
    
    func setUpGroupImage() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "changeGroupImage")
        groupImage.addGestureRecognizer(tapGesture)
        groupImage.userInteractionEnabled = true
        let userPlaceholderImage = UIImage(named:"BlankEvent.png")
        groupImage.image = userPlaceholderImage
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        typePicker.delegate = self
        typePicker.dataSource = self
        imagePicker.delegate = self
        setUpGroupImage()
    }
    
    // Handles the image picker
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            groupImage.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func changeGroupImage() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func setCurrentUserGroupMember(newRallyGroup :PFObject, currentUser :PFUser) {
        if (currentUser["groupsMemberOf"] != nil) {
            var currentUsersGroups = currentUser["groupsMemberOf"] as! [String]
            currentUsersGroups.append(groupName.text!)
            currentUser["groupsMemberOf"] = currentUsersGroups
        } else {
            var currentUsersGroups = [String]()
            currentUsersGroups.append(groupName.text!)
            currentUser["groupsMemberOf"] = currentUsersGroups
        }
        let currentInstallation = PFInstallation.currentInstallation()
        let groupChannel = groupName.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
        currentInstallation.addUniqueObject(groupChannel, forKey: "channels")
        currentInstallation.saveInBackground()
        currentUser.saveInBackground()
    }
    
    func saveGroupImage (newRallyGroup: PFObject) {
        let imageData = UIImageJPEGRepresentation(groupImage.image!, 0.5)
        let imageFile = PFFile(data:imageData!)
        newRallyGroup["groupImage"] = imageFile
    }
    
    func populateRallyGroupFields(newRallyGroup :PFObject, currentUser :PFUser) {
        saveGroupImage(newRallyGroup)
        newRallyGroup["groupType"] = groupType.text
        newRallyGroup["groupName"] = groupName.text
        newRallyGroup["groupDescription"] = groupDescription.text
        newRallyGroup["groupInfo"] = groupInfo.text
        let groupMembers = [currentUser.username] as [String!]
        newRallyGroup["groupMemberUsernames"] = groupMembers
        newRallyGroup["groupAdmin"] = currentUser.username
        newRallyGroup["groupNumMembers"] = 1
        
        //Call this only if other conditions are met
        setCurrentUserGroupMember(newRallyGroup, currentUser: currentUser)
    }
    
    func fieldsFull() -> Bool {
        if (groupName.text == "" || groupDescription.text == "" || groupInfo.text == "" || groupType.text == "") {
            let fieldsEmptyAlert = UIAlertView(title: "Fields Empty", message: "Please fill out all group fields", delegate: self, cancelButtonTitle: "OK")
            fieldsEmptyAlert.show()
            return false
        }
        return true
    }
    
    func typeIsType() -> Bool {
        if (typePickerOptions.indexOf(groupType.text!) != nil) {
            return true
        }
        let pleaseSelectType = UIAlertView(title: "Please Select a Valid Group Type", message: "If there is no valid type, select \"Other\"", delegate: self, cancelButtonTitle: "OK")
        pleaseSelectType.show()
        return false
    }
    
    func groupNameIsAlphanumeric() -> Bool {
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9 ].*", options: [])
        if regex.firstMatchInString(groupName.text!, options: [], range: NSMakeRange(0, groupName.text!.characters.count)) != nil {
            let noSpecialChars = UIAlertView(title: "No Special Characters in Group Name", message: "Please enter only alphanumeric characters for your group name", delegate: self, cancelButtonTitle: "OK")
            noSpecialChars.show()
            return false
        }
        return true
    }
    
    func validateGroupFields() -> Bool {
        if (fieldsFull() && typeIsType() && groupNameIsAlphanumeric()) {
            return true
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "saveNewRallyGroup") {
            let currentUser = PFUser.currentUser()
            let newRallyGroup = PFObject(className:"RallyGroup")
            if (validateGroupFields()) {
                populateRallyGroupFields(newRallyGroup, currentUser: currentUser!)
                newRallyGroup.saveInBackground()
                let viewRallyGroups = segue.destinationViewController as! ViewRallyGroups
                viewRallyGroups.loadNewGroup()
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if (identifier == "saveNewRallyGroup") {
            if (!validateGroupFields()) {
                return false
            }
            return true
        }
        return true
    }
    
}