//
//  SignUpViewController.swift
//  Rally
//
//  Created by Cody Sugarman on 7/7/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(self.activityIndicator)
        emailField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 150)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 150)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func usernameExists(username: String) -> Bool {
        let query = PFUser.query()
        query!.whereKey("username", equalTo:username)
        let userArray = query!.findObjects()
        if (userArray!.count == 0) {
            return false
        }
        informUserUsernameExists()
        return true
    }
    
    func emailExists(email: String) -> Bool {
        let query = PFUser.query()
        query!.whereKey("email", equalTo:email)
        let userArray = query!.findObjects()
        if (userArray!.count == 0) {
            return false
        }
        informUserEmailExists()
        return true
    }
    
    func informUserEmailExists() {
        let alert = UIAlertView(title: "Email Exists", message: "E-mail already registered", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func informUserUsernameExists() {
        let alert = UIAlertView(title: "User Exists", message: "Username already registered", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func signupNewRallyUser() {
        let rallyUser = PFUser()
        rallyUser.username = self.usernameField.text
        rallyUser.password = self.passwordField.text
        rallyUser.email = self.emailField.text
        rallyUser["eventsAttending"] = [String]()
        rallyUser["groupsMemberOf"] = [String]()
        rallyUser["displayedSplashPages"] = [false, false, false]
        let userPlaceholderImage = UIImage(named:"BlankProfile.png")
        let imageData = UIImageJPEGRepresentation(userPlaceholderImage!, 0.5)
        let imageFile = PFFile(data:imageData!)
        rallyUser["profilePicture"] = imageFile
        self.activityIndicator.startAnimating()
        rallyUser.signUpInBackground()
        self.activityIndicator.stopAnimating()
        let alert = UIAlertView(title: "Success", message: "Signed up!", delegate: self, cancelButtonTitle: "OK")
        alert.show()
        self.performSegueWithIdentifier("returnToEventFeed", sender: self)
    }
    
    @IBAction func signupAction(sender: AnyObject) {
        if (usernameExists(self.usernameField.text!) || emailExists(self.emailField.text!)) {
            return
        }

        // Username/password error checking
        if (self.usernameField.text?.characters.count < 4 || self.passwordField.text?.characters.count < 5) {
            let alert = UIAlertView(title: "Invalid Credentials", message: "Username and password must be greater than 5 characters", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
            
        //Successful signup
        } else {
            signupNewRallyUser()
        }
    }
}
