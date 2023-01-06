//
//  TabBarController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat
import RxCocoa
import RxSwift

class TabBarController: UITabBarController {
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViewControllers()
        
        NotificationCenter.default.rx.notification(.kick).subscribe { noti in
            VCManager.shared.logout {
                let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
                UIApplication.shared.keyWindow?.rootViewController = vc
            } failure: { error in
                if error == 401 {
                    self.view.makeToast(NSLocalizedString("Illegal token", comment: ""))
                }
            }
        }.disposed(by: disposeBag)
    }
    
    
    func setupViewControllers() {
        let chatsVC = ChatsViewController()
        let chatsNav = BaseNavigationController(rootViewController: chatsVC)
        chatsNav.tabBarItem = UITabBarItem(title: NSLocalizedString("Chats", comment: ""), image: UIImage(systemName: "bubble.left"), tag: 0)
        
        let contactsVC = ContactsViewController()
        let contactsNav = BaseNavigationController(rootViewController: contactsVC)
        contactsNav.tabBarItem = UITabBarItem(title: NSLocalizedString("Contacts", comment: ""), image: UIImage(systemName: "person.3.sequence.fill"), tag: 1)
        
        let settingsVC = SettingsViewController()
        let settingsNav = BaseNavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: NSLocalizedString("Settings", comment: ""), image: UIImage(systemName: "gearshape.fill"), tag: 2)
        
        viewControllers = [chatsNav, contactsNav, settingsNav]
    }
}
