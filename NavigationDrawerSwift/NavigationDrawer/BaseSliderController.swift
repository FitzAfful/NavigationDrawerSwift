//
//  BaseSliderController.swift
//  NavigationDrawerSwift
//
//  Created by Fitzgerald Afful on 13/12/2019.
//  Copyright © 2019 Fitzgerald Afful. All rights reserved.
//

import UIKit

class BaseSliderController: UIViewController {

    private var currentMenu: MenuType = .LeftMenu

    // data
    private var leftRevealType: RevealType = .SlideOver
    private var rightRevealType: RevealType = .SlideOver
    private var leftSpeed: CGFloat = 0.35
    private var rightSpeed: CGFloat = 0.35
    private var leftCanPan: Bool = true
    private var rightCanPan: Bool = true
    private var leftShadowEnabled: Bool = true
    private var rightShadowEnabled: Bool = true
    private var leftEnabled: Bool = true
    private var rightEnabled: Bool = true
    private var leftWidth: CGFloat = 250
    private var rightWidth: CGFloat = 250

    // MARK: Menu Methods

    private func getEasySlide() -> ESNavigationController {
        return self.navigationController as! ESNavigationController
    }

    func addMenuButtons(){
        let leftButton = UIBarButtonItem(title: "Left", style: .done, target: self, action: Selector("openLeftView"))
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
    }

    @objc func openLeftView(){
        self.getEasySlide().openMenu(menu: .LeftMenu, animated: true, completion: {})
    }

    @objc func openRightView(){
        self.getEasySlide().openMenu(menu: .RightMenu, animated: true, completion: {})
    }

    // MARK: Getting

    internal func getMenuRevealType(menu: MenuType) -> RevealType{
        return (self.currentMenu == .LeftMenu) ? self.leftRevealType : self.rightRevealType
    }

    internal func getMenuSpeed(menu: MenuType) -> CGFloat{
        return (self.currentMenu == .LeftMenu) ? self.leftSpeed : self.rightSpeed
    }

    internal func getMenuPan(menu: MenuType) -> Bool{
        return (self.currentMenu == .LeftMenu) ? self.leftCanPan : self.rightCanPan
    }

    internal func getMenuShadow(menu: MenuType) -> Bool{
        return (self.currentMenu == .LeftMenu) ? self.leftShadowEnabled : self.rightShadowEnabled
    }

    internal func getMenuDisable(menu: MenuType) -> Bool{
        return (self.currentMenu == .LeftMenu) ? self.leftEnabled : self.rightEnabled
    }

    internal func getMenuWidth(menu: MenuType) -> CGFloat{
        return (self.currentMenu == .LeftMenu) ? self.leftWidth : self.rightWidth
    }

    // MARK: Setting
    internal func setMenuRevealType(menu: MenuType, value: RevealType){
        if(menu == .LeftMenu){
           self.leftRevealType = value
        } else {
            self.rightRevealType = value
        }
    }

    internal func setMenuSpeed(menu: MenuType, value: CGFloat){
        if(menu == .LeftMenu){
            self.leftSpeed = value
        } else {
            self.rightSpeed = value
        }
    }

    internal func setMenuPan(menu: MenuType, value: Bool){
        if(menu == .LeftMenu){
            self.leftCanPan = value
        } else {
            self.rightCanPan = value
        }
    }

    internal func setMenuShadow(menu: MenuType, value: Bool){
        if(menu == .LeftMenu){
            self.leftShadowEnabled = value
        } else {
            self.rightShadowEnabled = value
        }
    }

    internal func setMenuDisable(menu: MenuType, value: Bool){
        if(menu == .LeftMenu){
            self.leftEnabled = value
        } else {
            self.rightEnabled = value
        }
    }

    internal func setMenuWidth(menu: MenuType, value: CGFloat){
        if(menu == .LeftMenu){
            self.leftWidth = value
        } else {
            self.rightWidth = value
        }
    }
}
