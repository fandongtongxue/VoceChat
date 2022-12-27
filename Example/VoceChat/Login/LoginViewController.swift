//
//  ViewController.swift
//  VoceChat
//
//  Created by 范东同学 on 12/04/2022.
//  Copyright (c) 2022 范东同学. All rights reserved.
//

import UIKit
import VoceChat

class LoginViewController: BaseViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var inviteLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        VCManager.shared.getLoginConfig { config in
            self.nameLabel.text = VCManager.shared.serverInfo().name
            self.serverLabel.text = VCManager.shared.serverInfo().serverURL
            let ret = config.who_can_sign_up == "EveryOne"
            self.signUpView.isHidden = !ret
            self.inviteLabel.isHidden = ret
        } failure: { error in
            //do nothing
        }
    }

    @IBAction func loginBtnAction(_ sender: UIButton) {
        view.endEditing(true)
        VCManager.shared.login(email: emailTF.text, password: passTF.text) { result in
            //do nothing
            let tabC = TabBarController()
            UIApplication.shared.keyWindow?.rootViewController = tabC
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

