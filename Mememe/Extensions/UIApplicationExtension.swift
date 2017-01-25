//
//  UIApplicationExtension.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 26..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//
import UIKit
import Foundation

extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return topViewController(viewController: navigationController.visibleViewController)
        }
        if let tabController = viewController as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }
}
