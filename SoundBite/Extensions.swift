//
//  Extensions.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-15.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
