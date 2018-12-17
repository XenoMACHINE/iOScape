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

    var connected = false
    
    var session : WCSession?
    
    func connect(){
        if WCSession.isSupported(){
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func startGame(){
        session?.sendMessage(["New game":0], replyHandler: nil, errorHandler: { (err) in
            
        })
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
            connected = true
        }
    }
}
