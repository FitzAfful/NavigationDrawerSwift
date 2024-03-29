
/*
* EasySlide
* ESNavigationController
*
* Author: Nathan Blamirs
* Copyright © 2016 Nathan Blamires. All rights reserved.
*/

import UIKit

class ESNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    // side view controllers
    private var leftMenuViewController = UIViewController()
    private var rightMenuViewController = UIViewController()
    private var mainContentOverlay: UIView = UIView()

    // autolayout
    private var lefttrailingConstraint: NSLayoutConstraint?
    private var rightleadingConstraint: NSLayoutConstraint?

    // left menu
    private var leftMenuSet: Bool = false
    private var leftEnabled: Bool = true
    private var leftWidth: CGFloat = 250
    private var leftRevealType: RevealType = .SlideOver
    private var leftAnimationSpeed: CGFloat = 0.3
    private var leftShadowEnabled: Bool = true
    private var leftPanningEnabled: Bool = true

    // right menu
    private var rightMenuSet: Bool = false
    private var rightEnabled: Bool = true
    private var rightWidth: CGFloat = 250
    private var rightRevealType: RevealType = .SlideUnder
    private var rightAnimationSpeed: CGFloat = 0.3
    private var rightShadowEnabled: Bool = true
    private var rightPanningEnabled: Bool = true

    // swipe access
    private var panLimitedAccess: Bool = false
    private var panAccessView: MenuType = .LeftMenu
    private var leftPanAccessRange: CGFloat = 50
    private var rightPanAccessRange: CGFloat = 50

    // state tracking
    private var inactiveView: MenuType = .BothMenus
    private var panChangePoint: CGFloat = 0

    // MARK: Open/Close Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOverlay()
        let panSelector = #selector(ESNavigationController.panEventFired as (ESNavigationController) -> (UIPanGestureRecognizer) -> ())
        let panGestrure = UIPanGestureRecognizer(target: self, action: panSelector)
        panGestrure.delegate = self
        self.view.addGestureRecognizer(panGestrure)
    }

    private func setupOverlay(){

        // add the view
        self.view.addSubview(self.mainContentOverlay)

        // set attributes
        mainContentOverlay.isHidden = true
        mainContentOverlay.backgroundColor = UIColor.clear

        // add gestures
        let panSelector = #selector(ESNavigationController.panEventFired as (ESNavigationController) -> (UIPanGestureRecognizer) -> ())
        let panGestrure = UIPanGestureRecognizer(target: self, action: panSelector)
        mainContentOverlay.addGestureRecognizer(panGestrure)
        let tapSelector = #selector(ESNavigationController.automatedCloseOpenMenu as (ESNavigationController) -> () -> ())
        mainContentOverlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: tapSelector))

        // add constraints
        mainContentOverlay.translatesAutoresizingMaskIntoConstraints = false
        for attribute: NSLayoutConstraint.Attribute in [.leading, .trailing, .top, .bottom]{
            self.view.addConstraint(NSLayoutConstraint(item: mainContentOverlay, attribute: attribute, relatedBy: .equal, toItem: self.view, attribute: attribute, multiplier: 1, constant: 0))
        }
    }

    // MARK: Setup Methods

    func setupMenuViewController(menu: MenuType, viewController: UIViewController){
        if self.isMenuOpen(menu: menu) { self.closeOpenMenu(animated: false, completion: nil) }
        self.getMenuView(menu: menu).removeFromSuperview()
        if (menu == .LeftMenu) { self.leftMenuViewController = viewController; self.leftMenuSet = true }
        if (menu == .RightMenu) { self.rightMenuViewController = viewController; self.rightMenuSet = true  }
    }

    func setBodyViewController(viewController: UIViewController, closeOpenMenu:Bool, ignoreClassMatch:Bool){

        // get view controller types
        let rootType = Mirror(reflecting: self.viewControllers[0])
        let newType = Mirror(reflecting: viewController)

        // change vs if not the same class as the current one
        if(!ignoreClassMatch || rootType.subjectType != newType.subjectType){
            setViewControllers([viewController], animated: false)
        }
        if closeOpenMenu { self.closeOpenMenu(animated:true, completion: nil)}
    }

    // MARK: Open/Close Methods

    func openMenu(menu: MenuType, animated:Bool, completion:(()->(Void))?){
        if menu == .BothMenus { return }
        if self.isMenuEnabled(menu: menu) && self.isMenuSet(menu: menu) {
            self.menuSetup(menu: menu)
            self.changeMenu(menu: menu, animated: animated, percentage: 1.0, completion: completion);
        }
    }

    func closeOpenMenu(animated:Bool, completion:(()->(Void))?){
        let openMenu: MenuType = self.isMenuOpen(menu: .LeftMenu) ? .LeftMenu : .RightMenu
        self.changeMenu(menu: openMenu, animated: true, percentage: 0.0, completion: completion)
    }

    @objc internal func automatedCloseOpenMenu(){
        self.closeOpenMenu(animated: true, completion: nil)
    }

    func isMenuOpen(menu: MenuType) -> Bool{
        return (self.inactiveView != .BothMenus && self.inactiveView != menu) ? true : false
    }

    // MARK: Private Open/Close Helper Methods

    private func changeMenu(menu: MenuType, animated: Bool, percentage: CGFloat, completion:(()->(Void))?){
        let speed = animated ? self.getMenuAnimationSpeed(menu: menu) : 0
        self.animateLayoutChanges(menu: menu, percentage: percentage, speed: speed, completion: completion)
    }

    private func animateLayoutChanges(menu: MenuType, percentage: CGFloat, speed: CGFloat, completion:(()->(Void))?){

        self.view.window?.layoutIfNeeded()
        self.menuLayoutChanges(menu: menu, percentage: percentage)
        self.mainContentOverlay.isHidden = false

        // do animation
        UIView.animate(withDuration: Double(speed), delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
            self.view.window?.layoutIfNeeded()
            self.menuManualViewChanges(menu: menu, percentage: percentage)
            }) { (finished) -> Void in
                self.mainContentOverlay.isHidden = (percentage == 0) ? true : false
                self.inactiveView = (percentage == 1.0) ? self.getOppositeMenu(menu: menu) : .BothMenus
                if percentage == 0.0 { self.menuCleanUp(menu: menu) }
                completion?()
        }
    }

    private func addMenuToWindow(menu: MenuType){

        self.view.window?.insertSubview(self.getMenuView(menu: menu), at: 0)
        if (self.getMenuRevealType(menu: menu) == .SlideOver){
            self.view.window?.bringSubviewToFront(self.getMenuView(menu: menu))
        }

        self.getMenuView(menu: menu).translatesAutoresizingMaskIntoConstraints = false
        if (menu == .LeftMenu) {
            self.lefttrailingConstraint = NSLayoutConstraint(item: self.leftMenuViewController.view!, attribute: .trailing, relatedBy: .equal, toItem: self.view.window!, attribute: .leading, multiplier: 1, constant: 0)
        } else {
            self.rightleadingConstraint = NSLayoutConstraint(item: self.rightMenuViewController.view!, attribute: .leading, relatedBy: .equal, toItem: self.view.window!, attribute: .trailing, multiplier: 1, constant:  0)
        }
        let widthConstraint = NSLayoutConstraint(item: self.getMenuView(menu: menu), attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.getMenuWidth(menu: menu));
        let topConstraint = NSLayoutConstraint(item: self.getMenuView(menu: menu), attribute: .top, relatedBy: .equal, toItem: self.view.window!, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.getMenuView(menu: menu), attribute: .bottom, relatedBy: .equal, toItem: self.view.window!, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.window?.addConstraints([self.getHorizontalConstraintForMenu(menu: menu),widthConstraint,topConstraint,bottomConstraint]);
    }

    // MARK: Configurations

    func setMenuRevealType(menu: MenuType, revealType:RevealType){
        switch menu {
            case .LeftMenu: self.leftRevealType = revealType
            case .RightMenu: self.rightRevealType = revealType
            case .BothMenus: self.leftRevealType = revealType; self.rightRevealType = revealType
        }
    }

    func setMenuWidth(menu: MenuType, width:CGFloat){
        switch menu {
            case .LeftMenu: self.leftWidth = width
            case .RightMenu: self.rightWidth = width
            case .BothMenus: self.leftWidth = width; self.rightWidth = width
        }
    }

    func setMenuAnimationSpeed(menu: MenuType, speed:CGFloat){
        switch menu {
            case .LeftMenu: self.leftAnimationSpeed = speed
            case .RightMenu: self.rightAnimationSpeed = speed
            case .BothMenus: self.leftAnimationSpeed = speed; self.rightAnimationSpeed = speed
        }
    }

    func enableMenu(menu: MenuType, enabled:Bool){
        switch menu {
            case .LeftMenu: self.leftEnabled = enabled
            case .RightMenu: self.rightEnabled = enabled
            case .BothMenus: self.leftEnabled = enabled; self.rightEnabled = enabled
        }
    }

    func enableMenuShadow(menu: MenuType, enabled:Bool){
        switch menu {
            case .LeftMenu: self.leftShadowEnabled = enabled
            case .RightMenu: self.rightShadowEnabled = enabled
            case .BothMenus: self.leftShadowEnabled = enabled; self.rightShadowEnabled = enabled
        }
    }

    func enableMenuPanning(menu: MenuType, enabled:Bool){
        switch menu {
            case .LeftMenu: self.leftPanningEnabled = enabled
            case .RightMenu: self.rightPanningEnabled = enabled
            case .BothMenus: self.leftPanningEnabled = enabled; self.rightPanningEnabled = enabled
        }
    }

    func limitPanningAccess(shouldLimit:Bool, leftRange: CGFloat, rightRange:CGFloat){
        self.panLimitedAccess = shouldLimit
        self.leftPanAccessRange = leftRange
        self.rightPanAccessRange = rightRange
    }
}

// MARK: Helper Methods

extension ESNavigationController {
    private func getMenuView(menu: MenuType) -> UIView{
        return (menu == .LeftMenu) ? self.leftMenuViewController.view : self.rightMenuViewController.view
    }
    private func getMenuRevealType(menu: MenuType) -> RevealType{
        return (menu == .LeftMenu) ? self.leftRevealType : self.rightRevealType
    }
    private func getMenuWidth(menu: MenuType) -> CGFloat{
        return (menu == .LeftMenu) ? self.leftWidth : self.rightWidth
    }
    private func getMenuAnimationSpeed(menu: MenuType) -> CGFloat{
        return (menu == .LeftMenu) ? self.leftAnimationSpeed : self.rightAnimationSpeed
    }
    private func isMenuEnabled(menu: MenuType) ->  Bool{
        return menu == .LeftMenu ? self.leftEnabled : self.rightEnabled
    }
    private func isMenuSet(menu: MenuType) ->  Bool{
        return menu == .LeftMenu ? self.leftMenuSet : self.rightMenuSet
    }
    private func isMenuPanningEnabled(menu: MenuType) ->  Bool{
        return menu == .LeftMenu ? self.leftPanningEnabled : self.rightPanningEnabled
    }
    private func getOppositeMenu(menu: MenuType) -> MenuType{
        return (menu == .LeftMenu) ? .RightMenu : .LeftMenu
    }
    private func getHorizontalConstraintForMenu(menu: MenuType) -> NSLayoutConstraint{
        return (menu == .LeftMenu) ? self.lefttrailingConstraint! : self.rightleadingConstraint!
    }
}

// MARK: Shadow Methods

extension ESNavigationController {

    private func updateShadow(){

        var mainViewSide: ViewSide = .NoSides
        if (self.rightRevealType == .SlideUnder && self.leftRevealType == .SlideUnder && self.leftShadowEnabled && self.rightShadowEnabled) { mainViewSide = .BothSides }
        if (self.rightRevealType == .SlideUnder && self.leftRevealType != .SlideUnder && self.rightShadowEnabled) { mainViewSide = .RightSide }
        if (self.rightRevealType != .SlideUnder && self.leftRevealType == .SlideUnder && self.leftShadowEnabled) { mainViewSide = .LeftSide }

        let leftViewSide: ViewSide = (self.leftRevealType == .SlideOver && self.leftShadowEnabled) ? .RightSide : .NoSides
        let rightViewSide: ViewSide = (self.rightRevealType == .SlideOver && self.rightShadowEnabled) ? .LeftSide : .NoSides

        // update the shaddows
        self.drawShadowForView(theView: self.view, side: mainViewSide)
        self.drawShadowForView(theView: self.leftMenuViewController.view, side: leftViewSide)
        self.drawShadowForView(theView: self.rightMenuViewController.view, side: rightViewSide)
    }

    private func drawShadowForView(theView: UIView, side: ViewSide){

        // get correct values
        let radius: CGFloat = (side == .BothSides) ? 8.0 : 4.0
        var xOffset: CGFloat = (side == .BothSides) ? 0.0 : 4.0
        if (side == .LeftSide) { xOffset = -4.0; }
        let opacity: Float = (side == .NoSides) ? 0.0 : 0.5

        // create shaddow
        theView.layer.shadowColor = UIColor.black.cgColor
        theView.layer.shadowRadius = radius
        theView.layer.shadowOpacity = opacity
        theView.layer.shadowOffset = CGSize.init(width: xOffset, height: 0)
    }
}

// MARK: Panning

extension ESNavigationController {

    @objc internal func panEventFired(gesureRecognizer: UIPanGestureRecognizer){

        // BEGAN
        if gesureRecognizer.state == .began {
            self.panStarted()
        }

        // get pan value
        let movement = gesureRecognizer.translation(in: gesureRecognizer.view).x
        var panValue = self.panChangePoint + movement
        let viewBeingMoved: MenuType = (panValue > 0) ? .LeftMenu : .RightMenu

        // move pan change point if pan has already fully expanded menu
        if panValue > self.leftWidth || panValue < -self.rightWidth{
            self.panChangePoint = (panValue > self.leftWidth) ? self.leftWidth - movement : -self.rightWidth - movement
            panValue = self.panChangePoint + movement
        }

        // setup and clean views
        if self.getMenuView(menu: viewBeingMoved).superview == nil { self.menuSetup(menu: viewBeingMoved) }
        self.menuCleanUp(menu: self.getOppositeMenu(menu: viewBeingMoved))

        // if old menu moved the main view, and the new view doesn't, make sure the main view is reset to its original position
        if !self.menuMovesMainView(menu: viewBeingMoved) && self.menuMovesMainView(menu: self.getOppositeMenu(menu: viewBeingMoved)) {
            self.moveMainView(menu: self.getOppositeMenu(menu: viewBeingMoved), percentage: 0)
        }

        // CHANGED
        if gesureRecognizer.state == .changed {
            self.panChanged(viewBeingMoved: viewBeingMoved, panValue: panValue)
        }

        // ENDED
        if gesureRecognizer.state == .ended {
            let velocity = gesureRecognizer.velocity(in: gesureRecognizer.view)
            self.panEnded(viewBeingMoved: viewBeingMoved, panValue: panValue, velocity: velocity)
        }
    }

    // MARK: Pan State Methods

    private func panStarted(){
        self.mainContentOverlay.isHidden = false
        if self.isMenuOpen(menu: .LeftMenu) { self.panChangePoint = self.leftWidth}
        else if self.isMenuOpen(menu: .RightMenu) { self.panChangePoint = -self.rightWidth}
        else { self.panChangePoint = 0 }
    }

    private func panChanged(viewBeingMoved: MenuType, panValue: CGFloat){

        // calculate percentage
        var percentage = self.isMenuEnabled(menu: viewBeingMoved) && self.isMenuSet(menu: viewBeingMoved) && self.isMenuPanningEnabled(menu: viewBeingMoved) ? abs(panValue / self.getMenuWidth(menu: viewBeingMoved)) : 0.0
        percentage = (self.panLimitedAccess && self.panAccessView != viewBeingMoved) ? 0 : percentage // disable pan to new view if in limited pan mode

        // make movements
        self.menuLayoutChanges(menu: viewBeingMoved, percentage: percentage)
        self.menuManualViewChanges(menu: viewBeingMoved, percentage: percentage)
    }

    private func panEnded(viewBeingMoved: MenuType, panValue: CGFloat, velocity: CGPoint){

        // get percentage based on point pan finished
        var percentage: CGFloat = (abs(panValue / self.getMenuWidth(menu: viewBeingMoved)) >= 0.5) ? 1.0 : 0.0

        // change percentage to be velocity based, if velocity was high enough
        if abs(velocity.x) > 1000 {
            let shouldShow: Bool = (panValue > 0) ? (velocity.x > 50) : (velocity.x < -50)
            percentage = (shouldShow) ? 1.0 : 0.0
        }
        percentage = self.isMenuEnabled(menu: viewBeingMoved) && self.isMenuSet(menu: viewBeingMoved) && self.isMenuPanningEnabled(menu: viewBeingMoved) ? percentage : 0.0
        percentage = (self.panLimitedAccess && self.panAccessView != viewBeingMoved) ? 0 : percentage // disable pan to new view if in limited pan mode

        // animate layout change
        self.animateLayoutChanges(menu: viewBeingMoved, percentage: percentage, speed: 0.25, completion: nil)
    }

    // MARK: UIPanGestureRecognizerDelegate

    // disable pan if needed
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {

        // don't pan if delegate said not too, or if not the root view controller
        if let delegate: EasySlideDelegate = self.visibleViewController! as? EasySlideDelegate{
            if delegate.easySlidePanAccessAvailable() == false { return false }
        } else {
            if !(self.viewControllers[0] == self.visibleViewController) { return false }
        }

        // only enable swipe when began on edge
        if(self.panLimitedAccess){

            // extract touch data
            let x = touch.location(in: self.view).x
            let viewWidth = self.view.frame.size.width

            // check if in zone
            let inRightZone = (x <= viewWidth && x >= viewWidth - self.rightPanAccessRange)
            let inLeftRone = (x <= self.leftPanAccessRange && x >= 0)
            self.panAccessView = (inRightZone) ? .RightMenu : self.panAccessView
            self.panAccessView = (inLeftRone) ? .LeftMenu : self.panAccessView
            return (inRightZone || inLeftRone) ? true : false
        }
        return !touch.view!.isKind(of: UISlider.self)
    }
}

// MARK: Movement Methods

extension ESNavigationController {

    // setup
    private func menuSetup(menu: MenuType){

        // general setup
        self.updateShadow()
        self.addMenuToWindow(menu: menu)
        self.getMenuView(menu: menu).alpha = 1.0

        // custom setup
        switch (self.getMenuRevealType(menu: menu)) {
        case .SlideAlong: self.moveMenu(menu: menu, percentage: 0.0)
        case .SlideUnder: self.moveMenu(menu: menu, percentage: 1.0)
        case .SlideOver: self.moveMenu(menu: menu, percentage: 0.0)
        }
    }

    // autolayout constraint changes
    private func menuLayoutChanges(menu: MenuType, percentage: CGFloat){
        switch (self.getMenuRevealType(menu: menu)) {
        case .SlideAlong: self.moveMenu(menu: menu, percentage: percentage)
        case .SlideUnder: break
        case .SlideOver: self.moveMenu(menu: menu, percentage: percentage)
        }
    }

    // manual changes
    private func menuManualViewChanges(menu: MenuType, percentage: CGFloat){
        switch (self.getMenuRevealType(menu: menu)) {
        case .SlideAlong: self.moveMainView(menu: menu, percentage: percentage)
        case .SlideUnder: self.moveMainView(menu: menu, percentage: percentage)
        case .SlideOver: break
        }
    }

    // cleanup
    private func menuCleanUp(menu: MenuType){
        self.getMenuView(menu: menu).removeFromSuperview()
    }

    // movement checks changes
    private func menuMovesMainView(menu: MenuType) -> Bool{
        switch (self.getMenuRevealType(menu: menu)) {
        case .SlideAlong: return true
        case .SlideUnder: return true
        case .SlideOver: return false
        }
    }
}

extension ESNavigationController {

    // moves the menu passed to given percentage
    private func moveMenu(menu: MenuType, percentage: CGFloat){
        let menuMultiplier: CGFloat = (menu == .LeftMenu) ? percentage : (-percentage)
        self.getHorizontalConstraintForMenu(menu: menu).constant =  menuMultiplier * self.getMenuWidth(menu: menu)
    }

    // offsets main menu by % of menu passed
    private func moveMainView(menu: MenuType, percentage: CGFloat){
        let movement = self.getMenuWidth(menu: menu)
        self.view.frame.origin.x = (menu == .LeftMenu) ? movement * percentage : -movement * percentage
        self.getMenuView(menu: menu).alpha = (0.4 * percentage) + 0.6
    }
}

// MARK: Custom Data Types

enum MenuType: Int {
    case LeftMenu = 0
    case RightMenu = 1
    case BothMenus = 2
}
enum RevealType: Int {
    case SlideAlong = 0
    case SlideOver = 1
    case SlideUnder = 2
}
private enum ViewSide: Int {
    case LeftSide = 0
    case RightSide = 1
    case BothSides = 2
    case NoSides = 3
}

// MARK: EasySlideDelegate Protocol

protocol EasySlideDelegate{
    func easySlidePanAccessAvailable() -> Bool
}
protocol MenuDelegate{
    var easySlideNavigationController: ESNavigationController? { get set }
}
