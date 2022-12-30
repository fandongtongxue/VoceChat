//
//  ChatViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/26.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class ChatViewController: BaseViewController {
    
    var messageVC: MessageViewController!
    var model = VCUserModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messageVC = MessageViewController()
        messageVC.model = model
        view.addSubview(messageVC.view)
        messageVC.view.frame = CGRect(x: 0, y: 0, width: .screenW, height: .screenH - .tabBarHeight)
        addChildViewController(messageVC)
        
        view.addSubview(inputBar)

    }
    

    lazy var inputBar: InputBar = {
        let inputBar = InputBar(frame: CGRect(x: 0, y: .screenH - .topHeight, width: .screenW, height: .tabBarHeight - .safeAreaBottomHeight))
        return inputBar
    }()

}
