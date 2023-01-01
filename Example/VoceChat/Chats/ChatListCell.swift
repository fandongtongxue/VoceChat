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
import SwiftDate

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
            let avatar = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: 40, height: 40), fullName: "\(newValue.from_uid)")
            avatar?.backgroundColor = .systemBlue
            avatarImgView.sd_setImage(with: URL(string: .ServerURL + .resource_avatar + "?uid=\(newValue.from_uid)"), placeholderImage: avatar?.imageRepresentation)
            nameLabel.text = "\(newValue.from_uid)"
            contentLabel.text = newValue.detail.content
            timeLabel.text = "\(newValue.created_at)"
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
