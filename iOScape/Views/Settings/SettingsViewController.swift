//
//  SettingsViewController.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 16/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import HomeKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var animView: UIView!
    
    let STARTUP_NAME = "iOScape"
    
    let homeManager = HMHomeManager()
    let accessoryBrowser = HMAccessoryBrowser()
    
    var allAccessories : [(accessory:HMAccessory, connected:Bool)] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    
    var escapeHome : HMHome? {
        didSet{
            setAccessories()
            accessoryBrowser.startSearchingForNewAccessories()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableview()
        
        homeManager.delegate = self
        accessoryBrowser.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addSearchAnimation()
    }
    
    func initTableview(){
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "AccessoryCell", bundle: nil), forCellReuseIdentifier: "AccessoryCell")
    }
    
    func sortAccessories(){
        allAccessories.sort { (one, two) -> Bool in
            one.connected == two.connected
        }
    }
    
    //Manage home
    func checkEscapeHome(){
        for home in homeManager.homes{
            if home.name.contains(STARTUP_NAME){
                self.escapeHome = home
                return
            }
        }
        createEscapeHome()
    }

    func createEscapeHome(){
        self.homeManager.addHome(withName: "\(STARTUP_NAME) Home", completionHandler: { (home, err) in
            self.escapeHome = home
        })
    }
    
    //Manage Accessories
    func setAccessories(){
        let connectedAccessories = (escapeHome?.accessories ?? []).map({ ($0, true) })
        self.allAccessories.append(contentsOf: connectedAccessories)
        self.sortAccessories()
    }
    
    
    //Animation
    func addSearchAnimation(){
        let radius = animView.bounds.size.width/2.0
        
        let count = 3
        let duration : Double = 5
        
        for i in 0..<count{
            let circle = UIView(frame: animView.bounds)
            circle.layer.cornerRadius = radius
            circle.layer.borderWidth = 1
            circle.layer.borderColor = UIColor.white.cgColor
            circle.backgroundColor = UIColor.clear
            circle.layer.masksToBounds = true
            
            
            animView.addSubview(circle)
            
            circle.alpha = 1;
            circle.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            let delay = Double(i)*duration/Double(count)
            UIView.animate(withDuration: duration, delay: delay, options: .repeat, animations: {
                circle.transform = CGAffineTransform(scaleX: 5, y: 5)
                circle.alpha = 0
            })
        }
    }
    
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension SettingsViewController : HMHomeManagerDelegate{
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        checkEscapeHome()
    }
}

extension SettingsViewController : HMAccessoryBrowserDelegate{
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        if accessory.name.lowercased().starts(with: STARTUP_NAME.lowercased()){
            self.allAccessories.append((accessory, false))
            self.sortAccessories()
        }
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        self.allAccessories.removeAll(where: { return $0.accessory.uniqueIdentifier == accessory.uniqueIdentifier })
    }
}

extension SettingsViewController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAccessories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : AccessoryCell = tableView.dequeueReusableCell(withIdentifier: "AccessoryCell") as! AccessoryCell
        
        let item = allAccessories[indexPath.row]
        
        cell.accessoryName.text = item.accessory.name
        cell.accessoryType = item.connected ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = allAccessories[indexPath.row]
        
        escapeHome?.addAccessory(item.accessory, completionHandler: { (err) in
            guard err == nil else { return }
            self.allAccessories.insert((item.accessory, true), at: 0)
        })
    }
}
