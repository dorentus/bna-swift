//
//  ViewController.swift
//  bna
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import UIKit
import Authenticator

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()

        let serial = "CN-1402-1943-1283"
        let secret = "4202aa2182640745d8a807e0fe7e34b30c1edb23"
        let restorecode = "4CKBN08QEB"

        let a = Authenticator(serial, secret)
        println(a.tokenAtTime(timestamp: 1347279358))
        println(a.tokenAtTime(timestamp: 1347279360))
        println(a.tokenAtTime(timestamp: 1370448000))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
