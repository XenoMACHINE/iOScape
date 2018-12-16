//
//  MenuViewController.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 15/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import RHSideButtons
import Firebase

class MenuViewController: UIViewController {
    
    private let triggerButtonMargin = CGFloat(85)

    private var buttonsArr = [RHButtonView]()
    private var sideButtonsView: RHSideButtons?

    public var btnImageNames: [String] = ["icon_1","icon_2","icon_3","icon_4"]
    
    enum MenuType : Int{
        case SCORES = 1
        case SETTINGS = 2
        case LOGOUT = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setup()
        addButtons()
    }
    
    private func setup(){
        guard sideButtonsView == nil else { return }
        let triggerButton = RHTriggerButtonView(pressedImage: UIImage(named: "exit_icon")!) {
            $0.image = UIImage(named: "trigger_img")
        }
        
        sideButtonsView = RHSideButtons(parentView: view, triggerButton: triggerButton)
        sideButtonsView?.setTriggerButtonPosition(CGPoint(x: self.view.bounds.width - triggerButtonMargin, y: self.view.bounds.height - triggerButtonMargin))
        sideButtonsView?.delegate = self
        sideButtonsView?.dataSource = self
    }
    
    private func generateButton(withImgName imgName: String) -> RHButtonView {
        
        return RHButtonView {
            $0.image = UIImage(named: imgName)
        }
    }
    
    private func addButtons(){
        buttonsArr.removeAll()
        for name in btnImageNames{
            buttonsArr.append(generateButton(withImgName: name))
        }
        
        sideButtonsView?.reloadButtons()
    }
}

extension MenuViewController: RHSideButtonsDataSource {
    
    func sideButtonsNumberOfButtons(_ sideButtons: RHSideButtons) -> Int {
        return buttonsArr.count
    }
    
    func sideButtons(_ sideButtons: RHSideButtons, buttonAtIndex index: Int) -> RHButtonView {
        return buttonsArr[index]
    }
}

extension MenuViewController: RHSideButtonsDelegate {
    
    func sideButtons(_ sideButtons: RHSideButtons, didSelectButtonAtIndex index: Int) {
        guard let menuType = MenuType(rawValue: index) else { return }
        
        switch menuType{
            
        case .LOGOUT:
            try? Auth.auth().signOut()
            self.present(ConnectionViewController(), animated: true)
        case .SCORES:
            self.present(ScoresViewController(), animated: true)
        case .SETTINGS:
            self.present(SettingsViewController(), animated: true)
        }
    }
    
    func sideButtons(_ sideButtons: RHSideButtons, didTriggerButtonChangeStateTo state: RHButtonState) {
        
    }
}
