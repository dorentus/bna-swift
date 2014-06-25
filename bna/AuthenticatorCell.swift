//
//  AuthenticatorCell.swift
//  bna
//
//  Created by Rox Dorentus on 2014-6-23.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import UIKit
import Padlock

@IBDesignable
class AuthenticatorCell: UITableViewCell {

    @IBOutlet var token_label: UILabel
    @IBOutlet var serial_label: UILabel

    var timer: NSTimer?

    var authenticator: Authenticator? {
        didSet {
            serial_label.text = authenticator?.serial.description
            update_token()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func update_token() {
        if let a = authenticator {
            let (token, progress) = a.token()
            token_label.text = token
        }
    }

    func start_timer() {
        timer = NSTimer(timeInterval: 0.5, target: self, selector: Selector("update_token"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }

    func stop_timer() {
        if let t = timer {
            t.invalidate()
        }
        timer = nil
    }

}
