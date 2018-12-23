//
//  WatchManager.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 16/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchManager: NSObject {
    
    static let shared = WatchManager()

    enum AppStatus : Int{
        case CLOSE = 0
        case OPEN = 1
        case IN_GAME = 2
    }
    
    var currentStatus : AppStatus = .OPEN
    var watchConnected = false
    var session : WCSession?
    
    func connect(){
        if WCSession.isSupported(){
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func sendAppStatus(_ appStatus : AppStatus){
        currentStatus = appStatus
        session?.sendMessage(["AppStatus" : appStatus.rawValue], replyHandler: nil, errorHandler: { (err) in })
    }
}

extension WatchManager : WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Iphone OK")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
        if message["Watch"] as? String == "OK"{
            watchConnected = true
            sendAppStatus(currentStatus)
        }
    }
}
