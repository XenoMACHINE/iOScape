//
//  GameViewController.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 16/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import AudioToolbox
import FirebaseFirestore

class GameViewController: UIViewController {

    @IBOutlet weak var watchStatusLabel: UILabel!
    @IBOutlet weak var chronoLabel: UILabel!
    @IBOutlet weak var locksStackView: UIStackView!
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var vaultImg: UIImageView!
    @IBOutlet weak var imageCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorCodeTextfield: UITextField!
    
    let MAX_ROTATE_VALUE : CGFloat = 5
    
    var colors = [UIColor.green, UIColor.cyan, UIColor.lightGray, UIColor.brown, UIColor.yellow, UIColor.orange, UIColor.magenta, UIColor.blue, UIColor.red]
    var colorCode = "13965"
    
    var selectedColorIndex = -1 {
        didSet {
            self.colorsCollectionView.reloadData()
        }
    }
    
    var enigmaSolved = 0 {
        didSet{
            if enigmaSolved == 1 { initSecondEnigma() }
            if enigmaSolved == 2 { initThirdEnigma() }
            if enigmaSolved == 3 { endGame() }
            openNextLock()
        }
    }
    
    var time = 0
    var gameTimer : Timer?
    
    var rotateValue : CGFloat = 0
    var nbTap = 0
    
    lazy var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HomeKitManager.shared.lockAll()
        launchChrono()
        if WatchManager.shared.watchConnected{
            watchStatusLabel.text = "montre appairée"
        }
        
        WatchManager.shared.watchCrownDelegate = self
        WatchManager.shared.watchSwipeDelegate = self
        WatchManager.shared.watchKeyboardDelegate = self
        
        colorCodeTextfield.isHidden = true
        colorsCollectionView.isHidden = true
        colorsCollectionView.dataSource = self
        colorsCollectionView.delegate = self
        colorsCollectionView.register(UINib(nibName: "ColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ColorCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        WatchManager.shared.sendAppStatus(.IN_GAME)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        WatchManager.shared.sendAppStatus(.OPEN)
        gameTimer?.invalidate()
    }
    
    func endGame(){
        guard let userId = UserManager.shared.userId else { return }

        gameTimer?.invalidate()
        self.db.collection("users").document(userId).updateData(["scores":FieldValue.arrayUnion([self.time])])

        let quitGameAction = UIAlertAction(title: "Quitter la partie", style: .cancel) { (action) in
            self.dismiss(animated: true)
        }
        self.showAlert(title: "Félicitation !", message: "Tu as réussi toute les épreuves, tu peux sortir maintenant !", actions: [quitGameAction], style: .alert)
    }
    
    func initSecondEnigma(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                WatchManager.shared.sendWatchMessage("Ne t'énèrves surtout pas !")
            }
            self.gameImage.image = UIImage(named: "brokenglass0")
            self.vaultImg.isHidden = true
            self.setImage(visible: true)
        }
    }
    
    func initThirdEnigma(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            WatchManager.shared.sendWatchMessage("Observe attentivement")
            self.setRandomCode()
            self.colorCodeTextfield.isHidden = false
            self.colorsCollectionView.isHidden = false
            self.gameImage.isHidden = true
            self.setImage(visible: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.showColorsLoop()
            })
        }
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
    
    func setRandomCode(size : Int = 5){
        var randomCode = ""
        for _ in 0..<size{
            randomCode += "\(Int.random(in: 1...9))"
        }
        colorCode = randomCode
    }
    
    func showColorsLoop(){
        guard enigmaSolved == 2 else { return }
        self.showColorsCodeAnimation(callback: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.showColorsLoop()
            })
        })
    }
    
    func showColorsCodeAnimation(index : Int = 0, callback: (() -> Void)? = nil ){
        guard enigmaSolved == 2 else { return }
        guard index < colorCode.count else {
            callback?()
            return
        }
        let char = colorCode[index]
        guard let figure = Int("\(char)") else { return }
        self.selectedColorIndex = figure - 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showColorsCodeAnimation(index: index + 1, callback: callback)
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
            if self.chronoLabel.text == "00 : 00 : 03" {
                WatchManager.shared.sendWatchMessage("L'heure tourne ...")
            }
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
    
    func setImage(visible : Bool){
        DispatchQueue.main.async {
            if visible {
                self.imageCenterXConstraint.constant = -self.view.frame.width
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.5) {
                    self.imageCenterXConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }
            }else{
                UIView.animate(withDuration: 1) {
                    self.imageCenterXConstraint.constant = self.view.frame.width
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func soundVibrateNotif(){
        AudioServicesPlaySystemSound(1017)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func clearCodeTextfield(animated: Bool){
        DispatchQueue.main.sync {
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.06
            animation.repeatCount = 10
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.colorCodeTextfield.center.x - 10, y: self.colorCodeTextfield.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.colorCodeTextfield.center.x + 10, y: self.colorCodeTextfield.center.y))
            
            self.colorCodeTextfield.text = ""
            if animated {
                self.colorCodeTextfield.layer.add(animation, forKey: "position")
            }
        }
    }
    
    func solveFirstEnigma(){
        self.soundVibrateNotif()
        self.setImage(visible: false)
        WatchManager.shared.sendWatchMessage("Super ! Tu viens de d'ouvrir la porte")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            WatchManager.shared.sendWatchMessage("Voyons la suite ...")
        }
        enigmaSolved = 1
    }
    
    func solveSecondEnigma(){
        self.soundVibrateNotif()
        self.setImage(visible: false)
        WatchManager.shared.sendWatchMessage("Bien joué ! J'espère que la montre fonctionne encore ...")
        enigmaSolved = 2
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension GameViewController : WatchCrownDelegate{
    func didRotate(value: Double) {
        guard enigmaSolved == 0 else { return }
        
        if value >= 0 { //avance
            if rotateValue < MAX_ROTATE_VALUE { turnVault(value: CGFloat(value)) } //max
            else {
                WatchManager.shared.sendWatchMessage("Ça bloque ici, tu y es presque !")
            }
        }else{ // recule
            if rotateValue > 0 { turnVault(value: CGFloat(value)) } //min
            else {
                WatchManager.shared.sendWatchMessage("Merci, la porte est bien fermée !")
            }
        }
        
        if rotateValue > 0 && rotateValue < MAX_ROTATE_VALUE - 1 {
            WatchManager.shared.sendWatchMessage("On dirait que ça bouge !")
        }
    }
}

extension GameViewController : WatchSwipeDelegate {
    func didSwipe(direction: SwipeDirection) {
        switch direction{
        case .TOP:
            break
        case .RIGHT:
            if enigmaSolved == 0 && rotateValue >= MAX_ROTATE_VALUE {
                solveFirstEnigma()
            }
            if enigmaSolved == 1 && nbTap >= 9 {
                solveSecondEnigma()
            }
        case .BOTTOM:
            break
        case .LEFT:
            break
        }
    }
    
    func didTap() {
        guard enigmaSolved == 1 else { return }
        nbTap += 1
        nbTap = nbTap > 9 ? 9 : nbTap
        DispatchQueue.main.sync {
            self.gameImage.image = UIImage(named: "brokenglass\(nbTap)")
        }
        if nbTap >= 9 {
            WatchManager.shared.sendWatchMessage("Ça suffit !")
        }
    }
}

extension GameViewController : WatchKeyboardDelegate {
    func didTap(figure: Int) {
        DispatchQueue.main.sync {
            self.colorCodeTextfield.text = (colorCodeTextfield.text ?? "") + "\(figure)"
        }
    }
    
    func didValidate() {
        if colorCodeTextfield.text == colorCode {
            enigmaSolved += 1
        }else{
            clearCodeTextfield(animated: true)
        }
    }
    
    func didClear() {
        clearCodeTextfield(animated: false)
    }
}

extension GameViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath) as! ColorCollectionViewCell
        
        cell.backgroundColor = colors[indexPath.row]
        if indexPath.row == selectedColorIndex { cell.anim() }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = collectionView.bounds.width / 3 - 15
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
