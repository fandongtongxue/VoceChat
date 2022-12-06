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

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        nameLabel.text = VCManager.serverInfo().name
        serverLabel.text = VCManager.serverInfo().serverURL
    }

    @IBAction func loginBtnAction(_ sender: UIButton) {
        VCManager.login(email: emailTF.text!, password: passTF.text!) { result in
            //do nothing
            let tabC = TabBarController()
            
        } failure: { error in
            //do nothing
        }
    }
    
    @IBAction func signUpBtnAction(_ sender: UIButton) {
        
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        loginBtn.isEnabled = emailTF.text?.count ?? 0 > 0 && passTF.text?.count ?? 0 > 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

