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
    
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        print("cooucou")
        crownSequencer.delegate = self
        
        if WCSession.isSupported(){
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func didAppear() {
        crownSequencer.focus()
    }

}

extension InterfaceController : WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch OK \(activationState)")
        let session = WCSession.default
        guard session.isReachable else { return }
        let message : [String : Any] = ["Watch":"OK"]
        session.sendMessage(message, replyHandler: nil) { (err) in
            print(err)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print(userInfo)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let appStatusMessage = message["AppStatus"] as? Int, let appStatus = AppStatus(rawValue: appStatusMessage){
            switch appStatus{
            case .OPEN:
                self.statusLabel.setText("App open")
            case .CLOSE:
                self.statusLabel.setText("App close")
            case .IN_GAME:
                self.statusLabel.setText("In game")
            }
        }
    }
}

extension InterfaceController : WKCrownDelegate {
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        print(rotationalDelta)
    }
}
