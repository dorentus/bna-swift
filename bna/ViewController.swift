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

        let sl = Authenticator.Serial(text: serial)
        let st = Authenticator.Secret(text: secret)

        let r0 = Authenticator.Restorecode(serial: sl, secret: st)
        let r1 = Authenticator.Restorecode(text: restorecode)

        println(r0.text)
        println(r1.text)

        println(hmac_sha1_hexdigest(serial, secret))
        println(hmac_sha1_hexdigest(serial.bytes, st.binary))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

