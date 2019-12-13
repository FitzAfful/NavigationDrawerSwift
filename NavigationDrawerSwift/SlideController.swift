//
//  SlideController.swift
//  NavigationDrawerSwift
//
//  Created by Fitzgerald Afful on 13/12/2019.
//  Copyright © 2019 Fitzgerald Afful. All rights reserved.
//

import Foundation

class SlideNavigationController: ESNavigationController {

    override func viewDidLoad() {

        super.viewDidLoad()

        // set left menu view controllers
        let optionalLeftVC = self.storyboard?.instantiateViewController(withIdentifier: "LeftMenu")
        if let leftVC = optionalLeftVC {
            self.setupMenuViewController(menu: .LeftMenu, viewController: leftVC)
            if var delegate: MenuDelegate = leftVC as? MenuDelegate{
                delegate.easySlideNavigationController = self
            }
        }

        // set right menu view controllers
        let optionalRightVC = self.storyboard?.instantiateViewController(withIdentifier: "RightMenu")
        if let rightVC = optionalRightVC {
            self.setupMenuViewController(menu: .RightMenu, viewController: rightVC)
            if var delegate: MenuDelegate = rightVC as? MenuDelegate{
                delegate.easySlideNavigationController = self
            }
        }
    }
}
