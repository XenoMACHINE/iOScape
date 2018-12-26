//
//  HomeKitManager.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 23/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import HomeKit

enum LockStatus : Int {
    case UNLOCK = 0
    case LOCK = 1
}

class HomeKitManager : NSObject {
    
    static let shared = HomeKitManager()
    
    private let STARTUP_NAME = "iOScape"
    private let homeManager = HMHomeManager()
    
    var escapeHome : HMHome?

    func load(){
        homeManager.delegate = self
    }
    
    func getLocksStatus() -> [LockStatus]{
        
        var lockStatus : [LockStatus] = []
        
        for accessory in escapeHome?.accessories ?? []{
            guard let characteristic = accessory.findCharacteristic(type: HMCharacteristicTypeTargetLockMechanismState),
                let value = characteristic.value as? Int,
                let state = HMCharacteristicValueLockMechanismState(rawValue: value) else { continue }
            
            if state == .secured { lockStatus.append(.LOCK) }
            else { lockStatus.append(.UNLOCK) }
        }
        
        return lockStatus
    }
    
    func lockAll(){
        for accessory in escapeHome?.accessories ?? []{
            guard let characteristic = accessory.findCharacteristic(type: HMCharacteristicTypeTargetLockMechanismState) else { continue }
            characteristic.writeValue(LockStatus.LOCK.rawValue) { (_) in }
        }
    }
    
    func unlockNext(){
        guard let index = getLocksStatus().firstIndex(of: .LOCK),
            let characteristic = escapeHome?.accessories[index].findCharacteristic(type: HMCharacteristicTypeTargetLockMechanismState) else { return }
        
        characteristic.writeValue(LockStatus.UNLOCK.rawValue) { (_) in }
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

extension HMAccessory {
    
    func findCharacteristic(type: String) -> HMCharacteristic? {
        for service in self.services{
            for characteristic in service.characteristics{
                if characteristic.characteristicType == type {
                    return characteristic
                }
            }
        }
        
        return nil
    }
}
