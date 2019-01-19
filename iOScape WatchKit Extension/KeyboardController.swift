//
//  KeyboardController.swift
//  iOScape WatchKit Extension
//
//  Created by Alexandre Ménielle on 19/01/2019.
//  Copyright © 2019 Alexandre Ménielle. All rights reserved.
//

import WatchKit

class KeyboardController: WKInterfaceController {
    
    var entireCode = ""
    
    func onClick(figure : Int){
        entireCode += "\(figure)"
    }
    
    
    //IBACTIONS
    
    @IBAction func onValidate() {
        print(entireCode)
        entireCode = ""
    }
    
    @IBAction func click0() { onClick(figure: 0) }
    @IBAction func click1() { onClick(figure: 1) }
    @IBAction func click2() { onClick(figure: 2) }
    @IBAction func click3() { onClick(figure: 3) }
    @IBAction func click4() { onClick(figure: 4) }
    @IBAction func click5() { onClick(figure: 5) }
    @IBAction func click6() { onClick(figure: 6) }
    @IBAction func click7() { onClick(figure: 7) }
    @IBAction func click8() { onClick(figure: 8) }
    @IBAction func click9() { onClick(figure: 9) }
    
}
