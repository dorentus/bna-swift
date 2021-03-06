//
//  AuthenticatorCell.swift
//  bna
//
//  Created by Rox Dorentus on 2014-6-23.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import UIKit
import QuartzCore
import Padlock

@IBDesignable
class AuthenticatorCell: UITableViewCell {
    class SelectionBackgroundView: UIView { }

    @IBOutlet weak var token_label: UILabel!
    @IBOutlet weak var serial_label: UILabel!

    var timer: CADisplayLink?

    var authenticator: Authenticator? {
        didSet {
            serial_label.text = authenticator?.serial.description
            update_token()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = SelectionBackgroundView()
    }

    func update_token() {
        if let a = authenticator {
            let (token, progress) = a.token()
            token_label.text = token
            token_label.textColor = color(progress: progress)
        }
    }

    func start_timer() {
        timer = CADisplayLink(target: self, selector: Selector("update_token"))
        timer!.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }

    func stop_timer() {
        if let t = timer {
            t.invalidate()
        }
        timer = nil
    }

}
