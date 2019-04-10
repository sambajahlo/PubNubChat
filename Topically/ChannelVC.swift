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
    
    //Our Message struct, makes working with messages a little easier
    struct Message {
        var message: String
        var username: String
        var uuid: String
    }
    var messages: [Message] = []
    
    //Var to keep track of the earliest message we loaded
    var earliestMessageTime: NSNumber = -1
    
    //To keep track if we are already loading more messages
    var loadingMore = false
    
    //Our PubNub object that we will use to publish, subscribe, and get the history of our channel
    var client: PubNub!
    
    //We populated this with the information from our messages array
    @IBOutlet weak var tableView: UITableView!
    
    //Temporary values
    var channelName = "Channel Name"
    var username = "Username"
    
    //Where our messages come in
    @IBOutlet weak var messageTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Settin the channel name at the top of the page in the nav bar
        self.navigationController?.navigationBar.topItem?.title = channelName
        
        //Worling with the table view
        tableView.delegate = self
        tableView.dataSource = self
        
        
        //Setting up our PubNub object!
        let configuration = PNConfiguration(publishKey: "pub-c-4ce95ecd-4447-481d-8cc7-1080fd34f073", subscribeKey: "sub-c-7e0443e2-5634-11e9-b63d-361a0ea3785d")
        //Gets rid of deprecated warning
                configuration.stripMobilePayload = false
        //Making each connection identifiable for future development
                configuration.uuid = UUID().uuidString
                client = PubNub.clientWithConfiguration(configuration)
        client.addListener(self)
        client.subscribeToChannels([channelName],withPresence: true)
        
        //We load the last x messages to populate the tableview
        loadLastMessages()
    }
    
    
    
    
    //MARK: Actions
    //When the return key is pressed, the message will send
    @IBAction func returnKey(_ sender: UITextField) {
        publishMessage()
    }
    //When the send button is clicked, the message will send
    @IBAction func sendMessage(_ sender: UIButton) {
        publishMessage()
    }
    @IBAction func unsubscribeButton(_ sender: UIBarButtonItem) {
        
        client.unsubscribeFromChannelGroups([channelName], withPresence: true)
    }
    
    //MARK: PubNub Functions
    func publishMessage() {
        if(messageTextField.text != "" || messageTextField.text != nil){
            let messageString: String = messageTextField.text!
            let messageObject : [String:Any] =
                [
                    "message" : messageString,
                    "username" : username,
                    "uuid": client.uuid()
            ]
            
            client.publish(messageObject, toChannel: channelName) { (status) in
                print(status.data.information)
            }
            messageTextField.text = ""
        }
        
        
        
        
        
    }
    //This function is called when this view initialy loads to populate the tableview
    func loadLastMessages()
    {
        //The PubNub Function that returns an object of X messages, and when the first and last messages were sent.
        //The limit is how many messages are received with a maximum and default of 100.
        client.historyForChannel(channelName,start: nil,end: nil,limit:5){ (result, status) in
            if(result != nil && status == nil){
                
                //We save when the earliest message was sent in order to get ones previous to it when we want to load more.
                self.earliestMessageTime = result!.data.start
                
                //Convert the [Any] package we get into a dictionary of String and Any
                let messageDict = result!.data.messages as! [[String:String]]
                
                //Creating new messages from it and putting them at the end of messages array
                for m in messageDict{
                    let message = Message(message: m["message"] as! String, username: m["username"] as! String, uuid: m["uuid"] as! String)
                    self.messages.append(message)
                }
                //Reload the table with the new messages and bring the tableview down to the bottom to the most recent messages
                self.tableView.reloadData()
                if(!self.messages.isEmpty){
                    let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
                
            }
            else if(status !=  nil){
                print(status!.category)
                
            }
            else{
                print("everything is nil whaaat")
            }
        }
    }
    
    
    
    
    func client(_ client: PubNub, didReceive status: PNStatus) {
        // Check whether received information about successful subscription or restore.
        if status.operation == .unsubscribeOperation && status.category == .PNDisconnectedCategory{
            performSegue(withIdentifier: "leaveChannelSegue", sender: self)
            
        }
        else{
            print(status)
        }
    }
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        //Whenever we receive a new message, we add it to the end of our messages array and
        //reload the table so that it shows at thebottom.

        if(channelName == message.data.channel)
        {
            let m = message.data.message as! [String:Any]
            self.messages.append(Message(message: m["message"] as! String, username: m["username"] as! String, uuid: m["uuid"] as! String))
            tableView.reloadData()
            
            
            let indexPath = IndexPath(row: messages.count-1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            
        }
        
        print("Received message in Channel:",message.data.message!)
    }
    
    
    
    
    //MARK: Table view methods
    
    //This method allows users to query for more messages by dragging down from the top.
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        //If we are not loading more messages already
        if(!loadingMore){
            
            //-40 is when you have dragged down from the top of all the messages
            if(scrollView.contentOffset.y < -40 ) {
                loadingMore = true
                
                //Gets the channels history that starts from the earliest message we received and
                //we can set a limit here to however many messages we want, 100 and under
                client.historyForChannel(channelName, start: earliestMessageTime, end: nil,limit:10) { (result, status) in
                    //We check if the result is nil and if the data we get back is empty,
                    //if the start and end are 0 that means we have gone through all the back catalog of messages
                    if(result != nil && result?.data.start != 0 && result?.data.end != 0){
                        self.earliestMessageTime = result!.data.start
                        let messageDict = (result?.data.messages as! [[String:Any]])
                        
                        //Add all the new messages to a new arry and then insert it into the messages array
                        var newMessages :[Message] = []
                        for m in messageDict{
                            let message = Message(message: m["message"] as! String, username: m["username"] as! String, uuid: m["uuid"] as! String)
                            newMessages.append(message)
                        }
                        self.messages.insert(contentsOf: newMessages, at: 0)
                        
                        self.tableView.reloadData()
                        
                        
//                        let indexPath = IndexPath(row: 11, section: 0)
//                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                        
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
    
    //Tableview functions required.
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
