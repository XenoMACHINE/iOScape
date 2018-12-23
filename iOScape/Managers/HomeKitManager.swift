//
//  HomeKitManager.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 23/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import HomeKit

class HomeKitManager : NSObject {
    
    static let shared = HomeKitManager()
    
    private let STARTUP_NAME = "iOScape"
    private let homeManager = HMHomeManager()
    
    var escapeHome : HMHome?

    func load(){
        homeManager.delegate = self
    }
    
    private func checkEscapeHome(){
        for home in homeManager.homes{
            if home.name.contains(STARTUP_NAME){
                self.escapeHome = home
                return
            }
        }
        createEscapeHome()
    }
    
    private func createEscapeHome(){
        self.homeManager.addHome(withName: "\(STARTUP_NAME) Home", completionHandler: { (home, err) in
            self.escapeHome = home
        })
    }
}

extension HomeKitManager : HMHomeManagerDelegate{
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        checkEscapeHome()
    }
}
