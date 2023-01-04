//
//  InviteViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/4.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class InviteViewController: BaseViewController {

    @IBOutlet weak var codeImgView: UIImageView!
    @IBOutlet weak var linkLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = NSLocalizedString("Invite New User", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction))
        
        VCManager.shared.generateInviteLink { result in
            DispatchQueue.global().async {
                let filter = CIFilter(name: "CIQRCodeGenerator")
                filter?.setDefaults()
                let data = result.data(using: .utf8)
                filter?.setValue(data, forKeyPath: "inputMessage")
                guard let outputImage = filter?.outputImage else { return }
                let image = UIImage(ciImage: outputImage, scale: 20.0, orientation: .up)
                DispatchQueue.main.async {
                    self.linkLabel.text = result
                    self.codeImgView.image = image
                }
            }
        } failure: { error in
            //do nothing
        }
        
    }
    
    @objc private func closeAction() {
        dismiss(animated: true)
    }

    @IBAction func shareInviteLinkAction(_ sender: UIButton) {
        guard linkLabel.text?.count ?? 0 > 0 else {
            return
        }
        let url = URL(string: linkLabel.text!)
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activity, animated: true)
    }
    
    @IBAction func shareCodeAction(_ sender: UIButton) {
        guard let image = codeImgView.image else { return }
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activity, animated: true)
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
