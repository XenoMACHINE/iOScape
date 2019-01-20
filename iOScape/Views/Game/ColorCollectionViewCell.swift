//
//  ColorCollectionViewCell.swift
//  iOScape
//
//  Created by Alexandre Ménielle on 20/01/2019.
//  Copyright © 2019 Alexandre Ménielle. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {

    private let animTime = 0.7
    private let animAlpha : CGFloat = 0.3
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5
    }
    
    func anim(){
        self.animWithAlpha(animAlpha)
        DispatchQueue.main.asyncAfter(deadline: .now() + animTime) {
            self.animWithAlpha(1)
        }
    }
    
    private func animWithAlpha(_ alpha : CGFloat){
        UIView.animate(withDuration: animTime) {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(alpha)
            self.layoutIfNeeded()
        }
    }

}
