//
//  LeftViewController.swift
//  NavigationDrawerSwift
//
//  Created by Fitzgerald Afful on 13/12/2019.
//  Copyright © 2019 Fitzgerald Afful. All rights reserved.
//

import UIKit

class LeftMenuViewController: UIViewController, MenuDelegate, UITableViewDataSource, UITableViewDelegate {

    var easySlideNavigationController: ESNavigationController?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableCell")

        switch indexPath.item {
            case 0: cell?.textLabel!.text = "Home"
            case 1: cell?.textLabel!.text = "Second Controller"
        default:
            break
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController = UIViewController();

        // get the new view controller
        switch indexPath.item {
        case 0: viewController = storyboard.instantiateViewController(withIdentifier: "HomeController")
        case 1: viewController = storyboard.instantiateViewController(withIdentifier: "SecondController")
        default: break
        }

        // present next view
        if let slideController = self.easySlideNavigationController{
            slideController.setBodyViewController(viewController: viewController, closeOpenMenu: true, ignoreClassMatch: true)
        }
    }
}
