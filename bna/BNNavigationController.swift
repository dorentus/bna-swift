//
//  BNNavigationController.swift
//  bna
//
//  Created by Rox Dorentus on 2014-6-25.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import UIKit
import QuartzCore
import Padlock

class BNNavigationController: UINavigationController {

    var progressView: UIProgressView?
    var timer: CADisplayLink?

    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        addProgressView()
    }

    func addProgressView() {
        let progressView = UIProgressView(progressViewStyle: .Default)
        progressView.trackTintColor = UIColor.clearColor()
        progressView.progress = 0.5
        progressView.setTranslatesAutoresizingMaskIntoConstraints(false)

        if let v = self.view {
            v.addSubview(progressView)
            v.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[navbar]-(-2)-[progressview]", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["navbar": self.navigationBar, "progressview": progressView]))
            v.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[progressview]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["progressview": progressView]))
        }

        self.progressView = progressView

        let timer = CADisplayLink(target: self, selector: Selector("updateProgress"))
        timer.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.timer = timer
    }

    func updateProgress() {
        if let p = self.progressView {
            let progress = Authenticator.progress()
            p.progress = CFloat(progress)
            p.progressTintColor = color(progress: progress)
        }
    }

}
