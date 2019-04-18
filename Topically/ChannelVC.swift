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
    var noMoreMessages = false
    //Keep track of the earliest message we loaded
    var earliestMessageTime: NSNumber = -1
    
    //To keep track if we are already loading more messages
    var loadingMore = false
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
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
        
        //Setting the channel name at the top of the page in the nav bar
        self.navigationController?.navigationBar.topItem?.title = channelName
        
        //Working with the table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.transform =  CGAffineTransform(scaleX: 1, y: -1)
        
        
        //Adding event listeners for the keyboard notifications.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
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
    
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
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
        performSegue(withIdentifier: "leaveChannelSegue", sender: self)
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
    //Get and put the histroy of a channel into the messages array
    func addHiistory(start:NSNumber?,end:NSNumber?,limit:UInt   ){
        //The PubNub Function that returns an object of X messages, and when the first and last messages were sent.
        //The limit is how many messages are received with a maximum and default of 100.
        client.historyForChannel(channelName, start: start, end: end, limit:limit){ (result, status) in
            if(result != nil && status == nil){
                if(result!.data.start == 0 && result?.data.end == 0)
                {
                    self.noMoreMessages = true
                    return
                }
                //We save when the earliest message was sent in order to get ones previous to it when we want to load more.
                self.earliestMessageTime = result!.data.start
                
                //Convert the [Any] package we get into a dictionary of String and Any
                let messageDict = result!.data.messages as! [[String:String]]
                
                //Creating new messages from it and putting them at the end of messages array
//                var newMessages :[Message] = []
                for m in messageDict{
                    let message = Message(message: m["message"]! , username: m["username"]!, uuid: m["uuid"]! )
                    self.messages.insert(message, at: 0)
                }
                
                
                //Reload the table with the new messages and bring the tableview down to the bottom to the most recent messages
                self.tableView.reloadData()
                
                //Making sure that we wont be able to try to reload more data until this is completed.
                self.loadingMore = false
            }
            else if(status !=  nil){
                print(status!.category)
                
            }
            else{
                print("everything is nil whaaat")
            }
        }
    }
    //This function is called when this view initialy loads to populate the tableview
    func loadLastMessages()
    {
        addHiistory(start: nil, end: nil, limit: 20)
        if(!self.messages.isEmpty){
            self.tableView.scrollsToTop = true
        }
    }
    
    
    
    

    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        //Whenever we receive a new message, we add it to the end of our messages array and
        //reload the table so that it shows at thebottom.
        
        if(channelName == message.data.channel)
        {
            let m = message.data.message as! [String:String]
            self.messages.insert(Message(message: m["message"]!, username: m["username"]!, uuid: m["uuid"]!), at: 0)
            tableView.reloadData()
            
            
            self.tableView.scrollsToTop = true
            
        }
        
        print("Received message in Channel:",message.data.message!)
    }
    
    
    
    
    //MARK: Table view methods
    
    //This method allows users to query for more messages by dragging down from the top.
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        //If we are not loading more messages already
        if(!loadingMore && !noMoreMessages){
            let indexWant = IndexPath(row: messages.count - 1, section: 0)
            let visible = tableView.indexPathsForVisibleRows
            if(visible!.contains(indexWant)){
                loadingMore = true
                addHiistory(start: earliestMessageTime, end: nil, limit: 10)
                
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
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        return cell
    }
    
    //Objc method that handles keyboard changes.
    @objc func keyboardWillShow(notification: NSNotification){
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        
        //THIS LETS US DETECT WHAT PHONE SIZE IS BEING USED, AND THUS LETS US DECIDE WHETHER TO ACCOMADATE FOR THE SAFE AREA OR NOT
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136,1334,1920, 2208:
                print("Iphone with no safe area")
                bottomConstraint.constant =  -keyboardFrame.height
                
            case 2436,2688,1792:
                print("iPhone Xx")
                bottomConstraint.constant =  -keyboardFrame.height + 36
                
            default:
                print("Couldnt detect which iPhone being used, using default constraint")
                bottomConstraint.constant =  -keyboardFrame.height + 36
            }
        }
        
        
        
        
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomConstraint.constant = 0
    }
}
