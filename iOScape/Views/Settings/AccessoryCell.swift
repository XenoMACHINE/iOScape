//
//  AccessoryCell.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 16/12/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit

class AccessoryCell: UITableViewCell {

    @IBOutlet weak var globalView: UIView!
    @IBOutlet weak var accessoryName: UILabel!
    
    var basicColor : UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        basicColor = globalView.backgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        self.globalView.backgroundColor = highlighted ? .darkGray : basicColor
    }
    
}
