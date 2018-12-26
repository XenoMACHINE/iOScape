//
//  InterfaceController.swift
//  iOScape WatchKit Extension
//
//  Created by Alexandre Ménielle on 16/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    enum AppStatus : Int{
        case CLOSE = 0
        case OPEN = 1
        case IN_GAME = 2
    }
    
    enum SwipeDirection : Int{
        case TOP = 0
        case RIGHT = 1
        case BOTTOM = 2
        case LEFT = 3
    }
    
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    
    let session = WCSession.default
    var temp = 0
    
    var gameMessage = "La partie commence..." {
        didSet{
            self.statusLabel.setText(gameMessage)
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        crownSequencer.delegate = self
        
        if WCSession.isSupported(){
            session.delegate = self
            session.activate()
        }
    }
    
    override func didAppear() {
        crownSequencer.focus()
    }
    
    @IBAction func onSwipeRight(_ sender: Any) {
        session.sendMessage(["swipe": SwipeDirection.RIGHT.rawValue], replyHandler: nil) { (_) in }
    }
}

extension InterfaceController : WCSessionDelegate{
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
                self.statusLabel.setText("En l'attente d'une partie ...")
            case .CLOSE:
                self.statusLabel.setText("Ouvrez l'application iOScape")
            case .IN_GAME:
                gameMessage = "La partie commence !"
            }
        }
        
        if let gameVCMessage = message["gameMessage"] as? String{
            gameMessage = gameVCMessage
        }
    }
}

extension InterfaceController : WKCrownDelegate {
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        //guard rotationalDelta > 2 else { return }
        if temp == 10 || temp == 0{
            session.sendMessage(["rotationalDelta": rotationalDelta], replyHandler: nil) { (_) in }
            temp = 1
        }
        temp += 1
    }
}
