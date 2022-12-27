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
        VCManager.shared.getHistoryMessage(uid: model.uid, limit: 100) { messages in
            debugPrint("获取历史消息成功")
        } failure: { error in
            debugPrint("获取历史消息失败:"+error)
        }


    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
