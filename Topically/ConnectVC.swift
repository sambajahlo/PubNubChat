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
        if let navigationController = segue.destination as? UINavigationController,
            let channelVC = navigationController.viewControllers.first as? ChannelVC{
            var username = ""
            var channel = ""
            if(usernameTextField.text == "" ){
                username = "A Naughty Moose"
            }
            else{
                username = usernameTextField.text ?? "A Naughty Moose"
            }
            if(channelTextField.text == "" ){
                print("nothing in channel")
                channel = "Random"
            }
            else{
                channel = channelTextField.text ?? "General"
            }
            
            
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

