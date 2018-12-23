//
//  HomeViewController.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 15/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeViewController: MenuViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkSession()
    }
    
    
    func checkSession(){
        if Auth.auth().currentUser == nil {
            self.present(ConnectionViewController(), animated: true)
        }
    }
}
