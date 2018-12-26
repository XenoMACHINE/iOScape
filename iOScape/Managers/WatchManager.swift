//
//  WatchManager.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 16/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol WatchCrownDelegate : class {
    func didRotate(value : Double)
}

protocol WatchSwipeDelegate : class {
    func didSwipe(direction : SwipeDirection)
}

enum SwipeDirection : Int{
    case TOP = 0
    case RIGHT = 1
    case BOTTOM = 2
    case LEFT = 3
}

class WatchManager: NSObject {
    
    static let shared = WatchManager()

    enum AppStatus : Int{
        case CLOSE = 0
        case OPEN = 1
        case IN_GAME = 2
    }
    
    var watchCrownDelegate : WatchCrownDelegate?
    var watchSwipeDelegate : WatchSwipeDelegate?

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
    
    func sendWatchMessage(_ message : String){
        session?.sendMessage(["gameMessage" : message], replyHandler: nil, errorHandler: { (err) in })
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
        //print(message)
        if message["Watch"] as? String == "OK"{
            watchConnected = true
            sendAppStatus(currentStatus)
        }
        
        if let rotationalDelta = message["rotationalDelta"] as? Double {
            watchCrownDelegate?.didRotate(value: rotationalDelta)
        }
        
        if let swipe = message["swipe"] as? Int, let swipeDirection = SwipeDirection(rawValue: swipe) {
            watchSwipeDelegate?.didSwipe(direction: swipeDirection)
        }
    }
}
