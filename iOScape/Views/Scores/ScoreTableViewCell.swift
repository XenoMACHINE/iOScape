//
//  ScoreTableViewCell.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 16/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit

class ScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorView.layer.cornerRadius = colorView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    private func setColorView(_ index : Int){
        switch index{
        case 0:
            colorView.backgroundColor = UIColor.yellow
        case 1:
            colorView.backgroundColor = UIColor.gray
        case 2:
            colorView.backgroundColor = UIColor.orange
        default:
            colorView.backgroundColor = UIColor.clear
        }
    }
    
    private func secondsToHoursMinutesSeconds(seconds : Int) -> (hrs: Int, min: Int, sec: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    private func setScoreLabel(_ score : Int){
        let completeTime = secondsToHoursMinutesSeconds(seconds: score)
        scoreLabel.text = scoreLabel.text! + "\(completeTime.hrs)H \(completeTime.min)m \(completeTime.sec)s"
    }
    
    func setup(score: Int, index : Int){
        
        setColorView(index)
        
        scoreLabel.text = "\(index+1).\t"
        setScoreLabel(score)
    }
}
