//
//  SnipItsChatRoom.swift
//  SnipIts
//
//  Created by Cody Sugarman on 12/17/15.
//  Copyright © 2015 Cody Sugarman. All rights reserved.
//

import Foundation
import UIKit

class SnipItsChatRoom: JSQMessagesViewController {
    
    var ref = Firebase(url:"https://snipits.firebaseio.com")
    
    override func viewDidAppear(animated: Bool) {
        //Setup listeners
        setupFirebase()
        
        //Send test messages
        sendMessageOne()
        sendMessageTwo()
    }
    
    //Listen for new messages (limit to 25)
    func setupFirebase() {
        let messageRef = ref.childByAppendingPath("Sigma Nu All Campus")
        messageRef.queryLimitedToNumberOfChildren(25).observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
            let sender = snapshot.value["sender"] as? String
            let text = snapshot.value["text"] as? String
            print(sender! + " says: " + text!)
        })
    }
    
    //Example of sending message1
    func sendMessageOne() {
        let messageRef = ref.childByAppendingPath("Sigma Nu All Campus")
        let messageToSend = "Hey guys!"
        messageRef.childByAutoId().setValue(["sender":"Cody Sugarman", "text":messageToSend])
    }
    
    //Example of sending message2
    func sendMessageTwo() {
        let messageRef = ref.childByAppendingPath("Sigma Nu All Campus")
        let messageToSend = "HEY CODY!!"
        messageRef.childByAutoId().setValue(["sender":"Brandon Sugarman", "text":messageToSend])
    }
    
}
