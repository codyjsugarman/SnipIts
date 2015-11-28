//
//  LoginViewController.swift
//  Rally
//
//  Created by Cody Sugarman on 7/7/15.
//  Copyright (c) 2015 Cody Sugarman. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func imageResize (image image:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!,  NSForegroundColorAttributeName: UIColor.whiteColor()]
        if (PFUser.currentUser() != nil) {
            self.performSegueWithIdentifier("returnToEventFeed", sender: self)
        }
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(self.activityIndicator)
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 200)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 200)
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
    
    @IBAction func loginAction(sender: AnyObject) {
        let username = self.usernameField.text
        let password = self.passwordField.text
        if (username?.characters.count < 4 || password?.characters.count < 5) {
            let alert = UIAlertView(title: "Invalid", message: "Username must be greater than 4 and password must be greater than 5", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        } else {
            self.activityIndicator.startAnimating()
            
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: {
                (user, error) -> Void in
                self.activityIndicator.stopAnimating()
                
                if ((user) != nil) {
                    let alert = UIAlertView(title: "Success", message: "Logged In", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    self.performSegueWithIdentifier("returnToEventFeed", sender: self)
                } else {
                    let alert = UIAlertView(title: "Error", message: "Invalid login parameters", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
            })
        }
    }
    
    @IBAction func signupAction(sender: AnyObject) {
        self.performSegueWithIdentifier("displayRallySignupPage", sender: self)
    }
    
    
    @IBAction func returnToEventFeed(sender: AnyObject) {
        self.performSegueWithIdentifier("returnToEventFeed", sender: self)
    }
    
    
    @IBAction func signupViaFacebook(sender: AnyObject) {
        let permissions = ["public_profile", "email", "user_friends"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    self.setUserDetails() //update this function
                } else {
                    self.welcomeBackUser()
                    self.performSegueWithIdentifier("returnToEventFeed", sender: self)
                }
            } else {
               print("Uh oh. The user cancelled the Facebook login.")
            }
        }
        
    }
    
    func welcomeBackUser() {
        let welcomeBack = UIAlertView(title: "Welcome back!", message: "", delegate: self, cancelButtonTitle: "OK")
        welcomeBack.show()
    }
    
    func congratulateUserFacebookSignup() {
        let congratulateUser = UIAlertView(title: "Congratulations!", message: "You've signed up via Facebook - get ready to Rally!", delegate: self, cancelButtonTitle: "OK")
        congratulateUser.show()
    }
    
    func informUserUsernameExists() {
        let alert = UIAlertView(title: "User Exists", message: "Username already registered", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func setUserDetails() {
        let currentUser = PFUser.currentUser()
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) == nil) {
                //Set all fields
                
                //Username
                let userName:NSString = result.valueForKey("name") as! String
                
                //If userName exists: delete user, display error message, and return
                let query = PFUser.query()
                query!.whereKey("username", equalTo:userName)
                let userArray = query!.findObjects()
                if (userArray!.count != 0) {
                    self.informUserUsernameExists()
                    currentUser?.delete()
                    PFUser.logOut()
                    return
                }
                
                currentUser!.username = userName as String
                //Picture
                let facebookID:String = result.valueForKey("id") as! String
                let pictureURL = "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_resources=1"
                let URLRequest = NSURL(string: pictureURL)
                let URLRequestNeeded = NSURLRequest(URL: URLRequest!)
                NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?, error: NSError?) -> Void in
                    if (error == nil) {
                        let picture = PFFile(data: data!)
                        if let currentUser = currentUser {
                            currentUser["profilePicture"] = picture
                        }
                        currentUser!.save()
                    }
                    else {
                        print("Error: \(error!.localizedDescription)")
                    }
                })
                if (result.valueForKey("email") != nil) {
                    let facebookEmail:String = result.valueForKey("email") as! String
                    currentUser!.email = facebookEmail
                }

                if let currentUser = currentUser {
                    currentUser["eventsAttending"] = [String]()
                    currentUser["groupsMemberOf"] = [String]()
                    currentUser["displayedSplashPages"] = [false, false, false]
                }
                currentUser!.save()
                self.performSegueWithIdentifier("returnToEventFeed", sender: self)
                self.congratulateUserFacebookSignup()
            }
        })
    }
  
}
