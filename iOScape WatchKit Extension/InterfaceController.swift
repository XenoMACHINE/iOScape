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

    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    
    enum SwipeDirection : Int{
        case TOP = 0
        case RIGHT = 1
        case BOTTOM = 2
        case LEFT = 3
    }
    
    var temp = 0
    let sessionManager = SessionManager.shared
    
    var gameMessage = "La partie commence..." {
        didSet{
            self.statusLabel.setText(gameMessage)
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        crownSequencer.delegate = self
        
        SessionManager.shared.initialize()
        SessionManager.shared.delegate = self
    }
    
    override func didAppear() {
        crownSequencer.focus()
    }
    
    @IBAction func onTapGesture(_ sender: Any) {
        sessionManager.sendNoReplyMessage(message: ["tap": 1])
    }
    
    @IBAction func onSwipeRight(_ sender: Any) {
        sessionManager.sendNoReplyMessage(message: ["swipe": SwipeDirection.RIGHT.rawValue])
    }
}

extension InterfaceController : SessionManagerDelegate{
    func didReceiveMessage(message: String) {
        self.gameMessage = message
    }
}

extension InterfaceController : WKCrownDelegate {
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        if temp == 10 || temp == 0{
            sessionManager.sendNoReplyMessage(message: ["rotationalDelta": rotationalDelta])
            temp = 1
        }
        temp += 1
    }
}
