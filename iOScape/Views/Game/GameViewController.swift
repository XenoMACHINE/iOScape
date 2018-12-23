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
    @IBOutlet weak var chronoLabel: UILabel!
    @IBOutlet weak var locksStackView: UIStackView!
    
    var time = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        launchChrono()
        if WatchManager.shared.watchConnected{
            watchStatusLabel.text = "montre appairée"
        }
    }
    
    func launchChrono(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.time += 1
            let formattedTime = self.secondsToHoursMinutesSeconds(seconds: self.time)
            let hours = String(format: "%02d", formattedTime.hrs)
            let min = String(format: "%02d", formattedTime.min)
            let sec = String(format: "%02d", formattedTime.sec)

            self.chronoLabel.text = "\(hours) : \(min) : \(sec)"
        }
    }
    
    func secondsToHoursMinutesSeconds(seconds : Int) -> (hrs: Int, min: Int, sec: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func openNextLock(){
        for view in locksStackView.subviews{
            guard let img = view as? UIImageView else { continue }
            if img.tag == 0 {
                img.tag = 1
                img.image = UIImage(named: "unlock")
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        WatchManager.shared.sendAppStatus(.IN_GAME)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        WatchManager.shared.sendAppStatus(.OPEN)
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
