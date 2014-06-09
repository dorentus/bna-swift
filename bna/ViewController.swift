//
//  ViewController.swift
//  bna
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let serial = "CN-1402-1943-1283"
        let secret = "4202aa2182640745d8a807e0fe7e34b30c1edb23"
        let restorecode = "4CKBN08QEB"

        let sl = Authenticator.Serial(serial)
        let st = Authenticator.Secret(secret)

        let r0 = Authenticator.Restorecode(sl, st)
        println(r0.text)

        let r1 = Authenticator.Restorecode(restorecode)
        println(r1.text)

        let r2 = Authenticator.Restorecode(serial, secret)
        println(r2.text)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

