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
    
    var _chat : VCMessageModel!
    public var chat : VCMessageModel!{
        set{
            _chat = newValue
            //设置数据
            let user = VCManager.shared.getUserFromTable(uid: newValue.from_uid)
            let avatar = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: 40, height: 40), fullName: user.name)
            avatar?.backgroundColor = .systemBlue
            avatarImgView.sd_setImage(with: URL(string: .ServerURL + .resource_avatar + "?uid=\(newValue.from_uid)" + "&t=\(user.avatar_updated_at)"), placeholderImage: avatar?.imageRepresentation)
            nameLabel.text = user.name
            contentLabel.text = newValue.detail.content
            
            timeLabel.text = newValue.created_at.translateTimestamp()
            onlineView.backgroundColor = newValue.online ? .systemGreen : .systemGray
        }
        get{
            return _chat
        }
    }
    
    var _channel : VCChannelModel!
    public var channel : VCChannelModel!{
        set{
            _channel = newValue
            //设置数据
            let avatar = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: 40, height: 40), fullName: newValue.name)
            avatar?.backgroundColor = .systemGray
            avatarImgView.sd_setImage(with: URL(string: .ServerURL + .resource_group_avatar + "?uid=\(newValue.gid)" + "&t=\(newValue.avatar_updated_at)"), placeholderImage: avatar?.imageRepresentation)
            nameLabel.text = newValue.name
            contentLabel.text = newValue.pinned_messages.first?.content
            onlineView.isHidden = true
            timeLabel.text = ""
        }
        get{
            return _channel
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
