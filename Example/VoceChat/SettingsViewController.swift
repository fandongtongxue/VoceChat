//
//  SettingsViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/12.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class SettingsViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        VCManager.shared.getFavorites {
            debugPrint("111")
        } failure: { error in
            debugPrint("111")
        }

    }

}
