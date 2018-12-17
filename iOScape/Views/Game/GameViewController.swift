//
//  GameViewController.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 16/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
class GameViewController: UIViewController {

    @IBOutlet weak var watchStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WatchManager.shared.connected{
            watchStatusLabel.text = "montre appairée"
        }
        
        WatchManager.shared.startGame()
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
