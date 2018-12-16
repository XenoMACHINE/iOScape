//
//  Loader.swift
//  GOOTdistri
//
//  Created by Alexandre Ménielle on 09/08/2018.
//  Copyright © 2018 GOOT. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

class Loader {
    
    var loader : NVActivityIndicatorView?
    var size : CGFloat = 50.0
    var moveX : CGFloat = 0
    var moveY : CGFloat = 0
    var type = NVActivityIndicatorType.ballPulse
    var color = UIColor.white

    init(moveX : CGFloat = 0, moveY : CGFloat = 0, size : CGFloat = 50){
        self.moveX = moveX
        self.moveY = moveY
        self.size = size
    }
    
    func startAnimating(_ view : UIView){
        if let nvView = getNVActivityOf(view: view){
            nvView.startAnimating()
        }else{
            createNVViewIn(view: view)
            loader?.startAnimating()
        }
    }
    
    func stopAnimating(_ view : UIView){
        getNVActivityOf(view: view)?.stopAnimating()
    }
    
    func createNVViewIn(view: UIView){
        let frame = CGRect(x: 0, y: 0, width: size, height: size)
        loader = NVActivityIndicatorView(frame: frame, type: type, color: color, padding: 0)
        view.addSubview(loader!)
        
        loader?.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: loader!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: moveX)
        let verticalConstraint = NSLayoutConstraint(item: loader!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: moveY)
        view.addConstraints([horizontalConstraint, verticalConstraint])
    }
    
    func getNVActivityOf(view : UIView) -> NVActivityIndicatorView?{
        for subview in view.subviews{
            if let nvView = subview as? NVActivityIndicatorView{
                return nvView
            }
        }
        return nil
    }
}

class LoaderBuilder {
    
    private var loader : Loader!
    
    init(){
        loader = Loader()
    }
    
    func setMoveX(_ x : CGFloat) -> LoaderBuilder{
        loader.moveX = x
        return self
    }
    
    func setMoveY(_ y : CGFloat) -> LoaderBuilder{
        loader.moveY = y
        return self
    }
    
    func setSize(_ size : CGFloat) -> LoaderBuilder{
        loader.size = size
        return self
    }
    
    func setType(_ type : NVActivityIndicatorType) -> LoaderBuilder{
        loader.type = type
        return self
    }
    
    func setColor(_ color : UIColor) -> LoaderBuilder{
        loader.color = color
        return self
    }
    
    func build() -> Loader{
        return loader
    }
}

