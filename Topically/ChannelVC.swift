//
//  ChannelVC.swift
//  Topically
//
//  Created by Samba Diallo on 4/3/19.
//  Copyright © 2019 Samba Diallo. All rights reserved.
//

import UIKit
import PubNub
class ChannelVC: UIViewController,PNObjectEventListener, UITableViewDataSource, UITableViewDelegate {
    
    
    struct Message {
        var message: String
        var username: String
        var uuid: String
    }
    var earliestMessageTime: NSNumber = 0
    var loadingMore = false
    
    var client: PubNub!
    var messages: [Message] = []
    var appDelegate: AppDelegate!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var channelName = "Channel Name"
    var username = "Username"
    //FIXME: When connected make sure that this page reopens
    //FIXME: Make it load more when at the top of the messages
    @IBOutlet weak var messageTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = channelName
        
        //Worling with the table view
        tableView.delegate = self
        tableView.dataSource = self
        
        //        let indexPath = IndexPath(row: messages.count-1, section: 0)
        //        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        
        
        //getting the pubnub client refrence from the app delegate
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        client = appDelegate.client
        client.addListener(self)
        client.subscribeToChannels([channelName],withPresence: true)
        
//        for i in 1...100{
//            let messageObject : [String:Any] =
//                [
//                    "message" : String(i),
//                    "username" : username,
//                    "uuid": client.uuid()
//            ]
//            client.publish(messageObject, toChannel: channelName)
//        }
        
        loadLastMessages()
    }
    
    
    
    
    //MARK: Actions
    
    @IBAction func returnKey(_ sender: UITextField) {
        publishMessage()
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        publishMessage()
    }
    @IBAction func unsubscribeButton(_ sender: UIBarButtonItem) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "channel")
        defaults.set(false, forKey: "subscribed")
        client.unsubscribeFromChannelGroups([channelName], withPresence: true)
    }
    
    //MARK: PubNub Functions
    func publishMessage() {
        // let messageObject = Message(message: messageTextField.text ?? "empty string", username: "tester", uuid: client.uuid())
        let messageString: String = messageTextField.text ?? "empty message"
        let messageObject : [String:Any] =
            [
                "message" : messageString,
                "username" : username,
                "uuid": client.uuid()
        ]
        //        do{
        //            let jData = try JSONSerialization.data(withJSONObject: messageObject, options: [])
        //            let jString = String(data: jData, encoding: .ascii)
        //
        //        }catch{
        //            print("json didnt work")
        //        }
        
        
        client.publish(messageObject, toChannel: channelName) { (status) in
            print(status.data.information)
        }
        messageTextField.text = ""
        
        
        
        
    }
    func loadLastMessages()
    {
        //, start: nil, end: nil, includeTimeToken: true
        client.historyForChannel(channelName,start: nil,end: nil,limit:2){ (result, status) in
            if(result != nil){
                self.earliestMessageTime = (result?.data.start ??  0)
                print(result!.data.messages)
                let messageDict = (result!.data.messages as! [[String:Any]])
                
                for m in messageDict{
                    let message = Message(message: m["message"] as! String, username: m["username"] as! String, uuid: m["uuid"] as! String)
                    self.messages.append(message)
                }
                
                self.tableView.reloadData()
                if(!self.messages.isEmpty){
                    let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
                
            }
            
            if(status != nil)
            {
                print(status!)
            }
        }
    }
    
    
    
    
    func client(_ client: PubNub, didReceive status: PNStatus) {
        // Check whether received information about successful subscription or restore.
        if status.operation == .unsubscribeOperation && status.category == .PNDisconnectedCategory{
            print("unsubscribed")
            performSegue(withIdentifier: "leaveChannelSegue", sender: self)
            
        }
        else{
            print(status)
        }
    }
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        //WHENEVER WE GET A NEW MESSAGE, WE PUT IT AT THE END OF OUR TABLE AND REFRESH THE LIST
        //let message = Message(message: m["message"] as! String, username: m["username"] as! String, uuid: m["uuid"] as! String)
        //self.messages.append(message)
        if(channelName == message.data.channel)
        {
            let m = message.data.message as! [String:Any]
            self.messages.append(Message(message: m["message"] as! String, username: m["username"] as! String, uuid: m["uuid"] as! String))
            print(messages.last!)
            tableView.reloadData()
            
            
            let indexPath = IndexPath(row: messages.count-1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            
        }
        
        print("Received message in Channel:",message.data.message!)
    }
    
    
    
    
    //MARK: Table view methods
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        if(!loadingMore){
            
            //find how long one screen size
            //            let scrollHeight = tableView.contentSize.height
            //            let scrollOffset = scrollHeight - tableView.bounds.size.height
            print(scrollView.contentOffset.y)
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y < 0 ) {
                loadingMore = true
                self.client.historyForChannel(channelName, start: earliestMessageTime, end: nil,limit:2) { (result, status) in
                    if(result != nil){
                        print(result!.data)

                        self.earliestMessageTime = result!.data.start
                        let messageDict = (result?.data.messages as! [[String:Any]])
                        
                        var newMessages :[Message] = []
                        for m in messageDict{
                            let message = Message(message: m["message"] as! String, username: m["username"] as! String, uuid: m["uuid"] as! String)
                            newMessages.append(message)
                        }
                        self.messages.insert(contentsOf: newMessages, at: 0)
                        
                        self.tableView.reloadData()
                        
                        self.loadingMore = false
                        
                    }
                    if(status != nil)
                    {
                        print(status!)
                    }
                    
                }
                
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //change later
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        
        cell.messageLabel.text = messages[indexPath.row].message
        cell.usernameLabel.text = messages[indexPath.row].username
        
        
        return cell
    }
}
