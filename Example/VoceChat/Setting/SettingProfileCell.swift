//
//  SettingProfileCell.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat
import CDFInitialsAvatar

class SettingProfileCell: UITableViewCell {

    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var _model : VCUserModel!
    public var model : VCUserModel!{
        set{
            _model = newValue
            //设置数据
            let avatar = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: 40, height: 40), fullName: newValue.name)
            avatarImgView.image = avatar?.imageRepresentation
            nameLabel.text = newValue.name
            emailLabel.text = newValue.email
        }
        get{
            return _model
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
