//
//  UserManager.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 16/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UserManager: NSObject {
    
    static let shared = UserManager()
    
    lazy var db = Firestore.firestore()
    
    var userId : String?
    var email : String {
        get{
            return UserDefaults.standard.string(forKey: "user_email") ?? ""
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "user_email")
        }
    }
    
    func initUser(){
        self.userId = Auth.auth().currentUser?.uid
    }
    
    func createUser(){
        guard let id = self.userId else { return }
        let data : [String:Any] =  ["email" : email,
                                    "id" : id,
                                    "score" : 0]
        db.collection("users").document(id).setData(data)
    }
}
