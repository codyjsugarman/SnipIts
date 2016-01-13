//
//  MessagesViewController.swift
//  FireChat-Swift
//
//  Created by Katherine Fang on 8/13/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

import UIKit
import Foundation

class MessagesViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var rallyEvent:PFObject!
    let imagePicker = UIImagePickerController()
    var imageToSend = UIImage()
    var messages = [JSQMessage]()
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var isSendingImage = false
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        
    var senderImageUrl: String!
    var batchMessages = true
    var ref = Firebase(url: "https://snipits.firebaseio.com")
    
    
    // *** STEP 1: STORE FIREBASE REFERENCES
    var messagesRef = Firebase(url: "https://snipits.firebaseio.com")
    var sender = "Anonymous"
    
    func setupFirebase() {
        // *** STEP 4: RECEIVE MESSAGES FROM FIREBASE
        messagesRef.observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
            self.sender = snapshot.value["sender"] as! String
            print("SENDER: " + self.sender)
            let text = snapshot.value["text"] as? String
            let imageUrl = snapshot.value["imageUrl"] as? String
            if (imageUrl == nil || imageUrl == "") {
                let message = JSQMessage(senderId: self.sender, displayName: self.sender, text: text)
                self.messages.append(message)
            } else {
                //Use imageUrl to retrieve image from firebase
                let decodedData = NSData(base64EncodedString: imageUrl!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                let imgToSend = UIImage(data: decodedData!)
                let photoMediaItem = JSQPhotoMediaItem(image: imgToSend)
                let message = JSQMessage(senderId: self.sender, displayName: self.sender, media: photoMediaItem)
                self.messages.append(message)
            }
            self.finishReceivingMessage()
        })
    }
    
    func sendMessage(text: String!, sender: String!) {
        // *** STEP 3: ADD A MESSAGE TO FIREBASE
        var data: NSData = NSData()
        
        let image: UIImage? = imageToSend
        if (isSendingImage == true) {
            data = UIImageJPEGRepresentation(image!,0.1)!
            let base64String = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            messagesRef.childByAutoId().setValue([
                "text":text,
                "sender":sender,
                "imageUrl":base64String
                ])
        } else { 
            messagesRef.childByAutoId().setValue([
                "text":text,
                "sender":sender,
                ])
        }
        self.isSendingImage = false
    }
    
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name, incoming: incoming)
    }
    
    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = name.characters.count
        let initials : String? = name.substringToIndex(sender.startIndex.advancedBy(min(3, nameLength)))
        
        let userImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        print("IMAGE: " + String(userImage.avatarImage))
        avatars[name] = userImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyScrollsToMostRecentMessage = true
        imagePicker.delegate = self
        let eventTitle = rallyEvent["eventTitle"] as? String
        self.title = eventTitle
        messagesRef = ref.childByAppendingPath(eventTitle)
        self.sender = "Anonymous"

        
//        if let urlString = profileImageUrl {
//            setupAvatarImage(sender, imageUrl: urlString as String, incoming: false)
//            senderImageUrl = urlString as String
//        } else {
//            setupAvatarColor(sender, incoming: false)
//            senderImageUrl = ""
//        }

        setupFirebase()
    }
    
    override func viewWillAppear(animated: Bool) {
        let currentUser = PFUser.currentUser()
        let username = currentUser?.username
        self.senderId = username
        self.senderDisplayName = "Anonymous"
        self.senderImageUrl = ""
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if ref != nil {
            ref.unauth()
        }
    }
    
    // ACTIONS
    func receivedMessagePressed(sender: UIBarButtonItem) {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        sendMessage(text, sender: senderId)
        finishSendingMessage()
    }
    
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.Portrait
//    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        let optionMenu = UIAlertController(title: nil, message: "Select Option", preferredStyle: .ActionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
//                let imagePicker = UIImagePickerController()
                self.imagePicker.sourceType = .Camera;
                self.imagePicker.allowsEditing = false
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            print("Camera pressed!")
        })
        
        let selectPhotoAction = UIAlertAction(title: "Select Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
//            let imagePicker = UIImagePickerController()
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            print("Photo Selected")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(selectPhotoAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
        
    }

    
//    override func shouldAutorotate() -> Bool {
//        return false
//    }
    
//    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
//        let message = messages[indexPath.item]
//        
//        if message.sender() == sender {
//            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
//        }
//        
//        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
//    }
    
    
    
    
    
    
    
//    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
//        let message = messages[indexPath.item]
//        if let avatar = avatars[message.senderDisplayName] {
//            return UIImageView(image: avatar.avatarImage)
//        } else {
//            setupAvatarImage(message.senderDisplayName, imageUrl: senderImageUrl, incoming: true)
//            return UIImageView(image:avatars[message.senderDisplayName]?.avatarImage)
//        }
//    }
    
    
//    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
//        
//        let message = messages[indexPath.item]
//        if message.senderDisplayName == sender {
//            cell.textView!.textColor = UIColor.blackColor()
//        } else {
//            cell.textView!.textColor = UIColor.whiteColor()
//        }
//        
//        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView!.textColor!, NSUnderlineStyleAttributeName: 1]
//        cell.textView!.linkTextAttributes = attributes as! [String:AnyObject]
//
//        cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(),
//            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
//        
//        return cell
//    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        let data = self.messages[indexPath.row]
        
        
//        let media = JSQPhotoMediaItem()
//        media.image = UIImage(named: "rally.png")

        
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
//  View  usernames above bubbles
//    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
//        let data = self.collectionView(self.collectionView, messageDataForItemAtIndexPath: indexPath)
//        if (self.senderDisplayName == data.senderDisplayName()) {
//            return nil
//        }
//        return NSAttributedString(string: data.senderDisplayName())
//    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        isSendingImage = false
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //Do whatever with info
        self.imageToSend = info[UIImagePickerControllerOriginalImage] as! UIImage
        isSendingImage = true
        sendMessage("", sender: self.sender)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
//    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
//        let data = self.collectionView(self.collectionView, messageDataForItemAtIndexPath: indexPath)
//        if (self.senderDisplayName == data.senderDisplayName()) {
//            return 0.0
//        }
//        return kJSQMessagesCollectionViewCellLabelHeightDefault
//    }

}
