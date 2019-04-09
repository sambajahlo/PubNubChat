//
//  AppDelegate.swift
//  Topically
//
//  Created by Samba Diallo on 4/2/19.
//  Copyright © 2019 Samba Diallo. All rights reserved.
//

import UIKit
import PubNub

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var client: PubNub!
    
    //TODO: FULLY IMPLEMENT
//    func checkSubscribed() {
//        let defaults = UserDefaults.standard
//
//        //checks if the user has opened the app before
//        if let uuid = defaults.string(forKey: "uuid")
//        {
//            connectToPubNub(uuid: uuid)
//        }
//        else{
//            connectToPubNub(uuid: "")
//        }
//        //TODO: BRING THIS TO THE CHANNEL SCREEN
//        //PREPARE FOR SEGUE MIGHT NOT PUSH ALL THE INFORMATION WE WANT TO IT, SINCE WE USE INSTANTIATE VIEW CONTROLER
//        if(defaults.bool(forKey: "subscribed")){
//            if let channel = defaults.string(forKey:"channel"){
//                client.subscribeToPresenceChannels([channel])
//                let storyboard = UIStoryboard(name: "channelVC", bundle: nil)
//                print("auto subscribed to \(channel)")
//                window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "ChannelNav")
//                print("after segue app delegate")
//            }
//        }
//    }
    //TODO:FIX PREPARE FOR SEGUE OR FIGURE A WAY TO GET CHANNEL NAME AND USERNAME TO CHANNELVC
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let navigationController = segue.destination as? UINavigationController, let channelVC = navigationController.viewControllers.first as? ChannelVC{
//            let defaults = UserDefaults.standard
//            channelVC.channelName = defaults.string(forKey: "channel")
//
//
//        }
//    }
    func connectToPubNub(){
        
        let configuration = PNConfiguration(publishKey: "pub-c-4ce95ecd-4447-481d-8cc7-1080fd34f073", subscribeKey: "sub-c-7e0443e2-5634-11e9-b63d-361a0ea3785d")
        configuration.stripMobilePayload = false
        
//        if(uuid != "" ){
//            configuration.uuid = uuid
//        }
//        else{
        
            configuration.uuid = UUID().uuidString
            UserDefaults.standard.set(configuration.uuid, forKey: "uuid")
       // }
        self.client = PubNub.clientWithConfiguration(configuration)
        
        
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        connectToPubNub()
        //checkSubscribed()
        return true
    }
//    func client(_ client: PubNub, didReceive status: PNStatus) {
//        print("in ad ",status)
//    }
//    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
//        print("in ad ",message.data)
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

