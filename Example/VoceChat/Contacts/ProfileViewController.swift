//
//  ProfileViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/16.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class ProfileViewController: BaseViewController {
    
    var model = VCUserModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = model.name
        
//        VCManager.shared.sendMessage(uid: model.uid) {
//            debugPrint("发送消息成功")
//        } failure: { error in
//            debugPrint("发送消息失败:"+error)
//        }


    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let chatVC = ChatViewController()
        let chat = VCMessageModel()
        chat.from_uid = model.uid
        chatVC.chat = chat
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }

}
