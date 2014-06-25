//
//  DetailViewController.swift
//  bna
//
//  Created by Rox Dorentus on 2014-6-23.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import UIKit
import QuartzCore
import Padlock

@IBDesignable
class DetailViewController: UITableViewController {

    @IBOutlet var serialView: UITextView
    @IBOutlet var tokenView: UITextView
    @IBOutlet var restorecodeView: UITextView

    var timer: NSTimer?
    var authenticator: Authenticator?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let a = authenticator {
            title = a.serial.description

            serialView.text = a.serial.description
            restorecodeView.text = a.restorecode.description
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        tick()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        timer?.invalidate()
        timer = nil
    }

    func tick() {
        if let a = authenticator {
            let (token, progress) = a.token()
            tokenView.text = token

            let diff = 30 * (1 - progress)
            timer = NSTimer(timeInterval: diff, target: self, selector: Selector("tick"), userInfo: nil, repeats: false)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
    }
}
