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
    
    var client: PubNub!
    
    //CONSTANTS FOR DEV PURPOSES
    let username = "totinos boy" //usernameTextField.text!
    let channel = "dasda" //channelTextField.text!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var channelTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        client = appDelegate.client
        client.addListener(self)
        
        
    }
    @IBAction func connectToChannel(_ sender: UIButton) {
        
        // if(checkInputs()){
        client.subscribeToChannels([channel], withPresence: true)
        //}
        
        
    }
    
    func client(_ client: PubNub, didReceive status: PNStatus) {
        // Check whether received information about successful subscription or restore.
        if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
            
            if status.category == .PNConnectedCategory {
                print("Subscribed Successfully")
                
                self.performSegue(withIdentifier: "connectSegue", sender: self)
            }
        }
        else if status.operation == .unsubscribeOperation && status.category == .PNDisconnectedCategory{
            print("unsubscribed successfully")
        }
        else{
            print("Something went wrong subscribing")
        }
    }
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
                print("nothing in username")
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
            
            
            channelVC.username = username
            channelVC.channelName = channel
            
            let defaults = UserDefaults.standard
            defaults.set(username, forKey: "username")
            defaults.set(channel,forKey: "channel")
            defaults.set(true, forKey: "subscribed")
            
        }
    }
    //TODO: DECIDE
    //NOT SURE IF I WANT TO USE THIS
    func checkInputs() -> Bool {
        if(usernameTextField.text == "" || usernameTextField.text == nil ){
            print("username not filled out")
            return false
            
        }
        else if(channelTextField.text == "" || channelTextField.text == nil){
            print("channel not filled out")
            return false
        }
        return true
    }
}

