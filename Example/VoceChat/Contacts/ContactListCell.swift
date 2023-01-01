//
//  ContactListCell.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/15.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat
import CDFInitialsAvatar

class ContactListCell: UITableViewCell {

    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var onlineView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
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
            nameLabel.text = newValue.name + (newValue.name == VCManager.shared.currentUser()?.user.name ? NSLocalizedString("(you)", comment: "") : "")
            onlineView.backgroundColor = (newValue.online || newValue.name == VCManager.shared.currentUser()?.user.name) ? .systemGreen : .systemGray
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
