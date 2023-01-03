//
//  ChatListCell.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/1.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat
import CDFInitialsAvatar
import SDWebImage

class ChatListCell: UITableViewCell {

    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var onlineView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var _model : VCMessageModel!
    public var model : VCMessageModel!{
        set{
            _model = newValue
            //设置数据
            let user = VCManager.shared.getUserFromTable(uid: newValue.from_uid)
            let avatar = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: 40, height: 40), fullName: user.name)
            avatar?.backgroundColor = .systemBlue
            avatarImgView.sd_setImage(with: URL(string: .ServerURL + .resource_avatar + "?uid=\(newValue.from_uid)" + "&t=\(user.avatar_updated_at)"), placeholderImage: avatar?.imageRepresentation)
            nameLabel.text = user.name
            contentLabel.text = newValue.detail.content
            
            timeLabel.text = newValue.created_at.updateTimeToCurrennTime()
            onlineView.backgroundColor = newValue.online ? .systemGreen : .systemGray
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
