//
//  ScoresViewController.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 16/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ScoresViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var noScoreLabel: UILabel!
    
    lazy var db = Firestore.firestore()
    var scores : [Int] = [] {
        didSet{
            self.tableview.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.dataSource = self
        tableview.register(UINib(nibName: "ScoreTableViewCell", bundle: nil), forCellReuseIdentifier: "ScoreCell")
        tableview.separatorStyle = .none
        tableview.tableFooterView = UIView()
        
        getScore()
    }
    
    func getScore(){
        guard let userId = UserManager.shared.userId else { return }
        Loader().startAnimating(self.view)
        db.collection("users").document(userId).getDocument { (snap, err) in
            self.scores = (snap?.data()?["scores"] as? [Int] ?? []).sorted()
            Loader().stopAnimating(self.view)
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension ScoresViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Loader().getNVActivityOf(view: self.view)?.isAnimating == false{
            self.noScoreLabel.isHidden = self.scores.count > 0
        }
        return scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ScoreTableViewCell = tableview.dequeueReusableCell(withIdentifier: "ScoreCell") as! ScoreTableViewCell
        
        let index = indexPath.row
        cell.setup(score: scores[index], index: index)
        
        return cell
    }
}
