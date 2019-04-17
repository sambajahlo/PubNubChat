//
//  ViewController.swift
//  Topically
//
//  Created by Samba Diallo on 4/2/19.
//  Copyright © 2019 Samba Diallo. All rights reserved.
//

import UIKit
import PubNub

class ConnectVC: UIViewController, PNObjectEventListener{
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var channelTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Adding event listeners for the keyboard notifications.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        
        
    }
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//    }
    
    //Objc method that handles keyboard changes.
    @objc func keyboardWillShow(notification: NSNotification){
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= keyboardFrame.height
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    @IBAction func connectToChannel(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "connectSegue", sender: self)
        
        
    }
    
//    func client(_ client: PubNub, didReceive status: PNStatus) {
//        // Check whether received information about successful subscription or restore.
//        if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
//
//            if status.category == .PNConnectedCategory {
//                print("Subscribed Successfully")
//
//                self.performSegue(withIdentifier: "connectSegue", sender: self)
//            }
//        }
//        else if status.operation == .unsubscribeOperation && status.category == .PNDisconnectedCategory{
//            print("unsubscribed successfully")
//        }
//        else{
//            print("Something went wrong subscribing")
//        }
//    }
//    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
//        print("Received message in ConnectVC:",message.data)
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Accessing Nav Controller and ChannelVC view
        if let navigationController = segue.destination as? UINavigationController,
            let channelVC = navigationController.viewControllers.first as? ChannelVC{
            var username = ""
            var channel = ""
            
            //Replacing empty values with default ones
            if(usernameTextField.text == "" ){
                username = "A Naughty Moose"
            }
            else{
                username = usernameTextField.text ?? "A Naughty Moose"
            }
            if(channelTextField.text == "" ){
                print("nothing in channel")
                channel = "General"
            }
            else{
                channel = channelTextField.text ?? "General"
            }
            
            //Setting values in ChannelVC 
            channelVC.username = username
            channelVC.channelName = channel
        }
    }
    //Use this to check if the user input anything  into the channel or username textfields
    func checkInputs() -> Bool {
        if(usernameTextField.text == "" || usernameTextField.text == nil ){
            //Tell the user to enter their username
            return false
            
        }
        else if(channelTextField.text == "" || channelTextField.text == nil){
            //Tell the user to enter a channel name
            return false
        }
        return true
    }
}

