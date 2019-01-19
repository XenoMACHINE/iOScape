//
//  SessionManager.swift
//  iOScape WatchKit Extension
//
//  Created by Alexandre Ménielle on 19/01/2019.
//  Copyright © 2019 Alexandre Ménielle. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol SessionManagerDelegate : class {
    func didReceiveMessage(message : String)
}

class SessionManager: NSObject {
    
    static let shared = SessionManager()
    
    private let session = WCSession.default
    
    weak var delegate : SessionManagerDelegate?
    
    enum AppStatus : Int{
        case CLOSE = 0
        case OPEN = 1
        case IN_GAME = 2
    }
    
    func initialize(){
        if WCSession.isSupported(){
            session.delegate = self
            session.activate()
        }
    }
    
    func sendNoReplyMessage(message : [String:Any]){
        session.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
}

extension SessionManager : WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch OK \(activationState)")
        guard session.isReachable else { return }
        let message : [String : Any] = ["Watch":"OK"]
        session.sendMessage(message, replyHandler: nil) { (_) in }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print(userInfo)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let appStatusMessage = message["AppStatus"] as? Int, let appStatus = AppStatus(rawValue: appStatusMessage){
            switch appStatus{
            case .OPEN:
                delegate?.didReceiveMessage(message: "En l'attente d'une partie ...")
            case .CLOSE:
                delegate?.didReceiveMessage(message: "Ouvrez l'application iOScape")
            case .IN_GAME:
                delegate?.didReceiveMessage(message: "La partie commence !")
            }
        }

        if let gameVCMessage = message["gameMessage"] as? String{
            delegate?.didReceiveMessage(message: gameVCMessage)
        }
    }
}
