//
//  GameViewController.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 16/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import AudioToolbox

class GameViewController: UIViewController {

    @IBOutlet weak var watchStatusLabel: UILabel!
    @IBOutlet weak var chronoLabel: UILabel!
    @IBOutlet weak var locksStackView: UIStackView!
    @IBOutlet weak var vaultImg: UIImageView!
    
    var enigmaSolved = 0
    var time = 0
    var gameTimer : Timer?
    
    var rotateValue : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HomeKitManager.shared.lockAll()
        launchChrono()
        if WatchManager.shared.watchConnected{
            watchStatusLabel.text = "montre appairée"
        }
        
        WatchManager.shared.watchCrownDelegate = self
        WatchManager.shared.watchSwipeDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        WatchManager.shared.sendAppStatus(.IN_GAME)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        WatchManager.shared.sendAppStatus(.OPEN)
        gameTimer?.invalidate()
    }
    
    func turnVault(value : CGFloat = 0.25){
        DispatchQueue.main.async {
            if value < 0.5 { self.rotateValue += value }
            else { self.rotateValue += 0.5 }
            UIView.animate(withDuration: 1.5, animations: {
                self.vaultImg.transform = CGAffineTransform(rotationAngle: CGFloat(self.rotateValue))
                print(self.rotateValue)
            })
        }
    }
    
    func launchChrono(){
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
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
        DispatchQueue.main.async {
            HomeKitManager.shared.unlockNext()
            for view in self.locksStackView.subviews{
                guard let img = view as? UIImageView else { continue }
                if img.tag == 0 {
                    img.tag = 1
                    img.image = UIImage(named: "unlock")
                    return
                }
            }
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension GameViewController : WatchCrownDelegate{
    func didRotate(value: Double) {
        guard enigmaSolved == 0 else { return }
        if value > 0 { //avance
            if rotateValue < 10 { turnVault(value: CGFloat(value)) } //max 10
            else { AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) }
        }else{ // recule
            if rotateValue > 0 { turnVault(value: CGFloat(value)) } //min 0
            else { AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) }
        }
    }
}


extension GameViewController : WatchSwipeDelegate {
    func didSwipe(direction: SwipeDirection) {
        switch direction{
        case .TOP:
            break
        case .RIGHT:
            if enigmaSolved == 0 && rotateValue >= 10 {
                enigmaSolved = 1
                openNextLock()
            }
        case .BOTTOM:
            break
        case .LEFT:
            break
        }
    }
}
