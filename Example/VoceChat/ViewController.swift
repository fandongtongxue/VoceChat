//
//  ViewController.swift
//  VoceChat
//
//  Created by 范东同学 on 12/04/2022.
//  Copyright (c) 2022 范东同学. All rights reserved.
//

import UIKit
import VoceChat

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        VCManager.login(email: "admin@fandong.me", password: "!@19910529Xx") { result in
            //do nothing
        } failure: { error in
            //do nothing
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

