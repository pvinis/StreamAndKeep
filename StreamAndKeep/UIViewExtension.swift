//
//  UIViewExtension.swift
//  StreamAndKeep
//
//  Created by Pavlos Vinieratos on 04/09/16.
//  Copyright © 2016 Pavlos Vinieratos. All rights reserved.
//

import UIKit

extension UIView {
	func bindFrameToSuperviewBounds() {
		guard let superview = self.superview else {
			print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
			return
		}

		self.translatesAutoresizingMaskIntoConstraints = false
		superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": self]))
		superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": self]))
	}
}
