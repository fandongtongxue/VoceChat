//
//  TabBarController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViewControllers()
    }
    

    func setupViewControllers() {
        let chatsVC = ChatsViewController()
        let chatsNav = UINavigationController(rootViewController: chatsVC)
        chatsNav.tabBarItem = UITabBarItem(title: NSLocalizedString("Chats", comment: ""), image: nil, tag: 0)
        
        let contactsVC = ContactsViewController()
        let contactsNav = UINavigationController(rootViewController: contactsVC)
        contactsNav.tabBarItem = UITabBarItem(title: NSLocalizedString("Contacts", comment: ""), image: nil, tag: 1)
        
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: NSLocalizedString("Settings", comment: ""), image: nil, tag: 2)
        
        viewControllers = [chatsNav, contactsNav, settingsNav]
    }
