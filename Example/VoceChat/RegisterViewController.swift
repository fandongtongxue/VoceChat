//
//  RegisterViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class RegisterViewController: BaseViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameLabel.text = VCManager.serverInfo().name
        serverLabel.text = VCManager.serverInfo().serverURL
    }
    
    @IBAction func closeBtnAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func signUpBtnAction(_ sender: UIButton) {
        
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        signUpBtn.isEnabled = emailTF.text?.count ?? 0 > 0 && passTF.text?.count ?? 0 > 0 && passTF.text?.count ?? 0 > 0 && passTF.text == confirmTF.text
    }

}
