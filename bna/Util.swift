//
//  Util.swift
//  bna
//
//  Created by Rox Dorentus on 2014-6-25.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import UIKit

func color(#progress: CGFloat) -> UIColor {
    let p = min(1.0, max(0.0, progress))

    let r = p
    let g = 0.5 - p * 0.5
    let b: CGFloat = 1.0

    return UIColor(red: r, green: g, blue: b, alpha: 1.0)
}

func color(#progress: Double) -> UIColor {
    return color(progress: CGFloat(progress))
}
