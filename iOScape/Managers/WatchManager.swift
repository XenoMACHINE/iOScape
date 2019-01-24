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

protocol WatchGestureDelegate : class {
    func didSwipe(direction : SwipeDirection)
    func didTap()
}

protocol WatchKeyboardDelegate : class {
    func didTap(figure : Int)
    func didValidate()
    func didClear()
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
    
    weak var watchCrownDelegate : WatchCrownDelegate?
    weak var watchSwipeDelegate : WatchGestureDelegate?
    weak var watchKeyboardDelegate : WatchKeyboardDelegate?

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
        
        if message["tap"] as? Int == 1 {
            watchSwipeDelegate?.didTap()
        }
        
        if let figure = message["colorCode"] as? Int {
            watchKeyboardDelegate?.didTap(figure: figure)
        }
        
        if message["colorCode"] as? String == "valid"{
            watchKeyboardDelegate?.didValidate()
        }
        
        if message["colorCode"] as? String == "clear"{
            watchKeyboardDelegate?.didClear()
        }
    }
}
