//
//  MessageListCell.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/2.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat
import CDFInitialsAvatar
import SDWebImage
import SwiftDate

class MessageListCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(avatarImgView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(containerView)
        avatarImgView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.avatarImgView.snp.right).offset(10)
            make.top.equalTo(self.avatarImgView)
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(self.nameLabel.snp.right).offset(10)
            make.right.lessThanOrEqualToSuperview().offset(-10)
            make.centerY.equalTo(self.nameLabel)
        }
        containerView.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(5)
            make.left.equalTo(self.nameLabel)
            make.right.bottom.equalToSuperview().offset(-10)
        }
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
            timeLabel.text = DateInRegion(milliseconds: newValue.created_at).toString(.dateTime(.short))
        }
        get{
            return _model
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    lazy var avatarImgView: UIImageView = {
        let avatarImgView = UIImageView(frame: .zero)
        avatarImgView.contentMode = .scaleAspectFill
        avatarImgView.clipsToBounds = true
        avatarImgView.layer.cornerRadius = 20
        return avatarImgView
    }()
    
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel(frame: .zero)
        nameLabel.textColor = .cyan
        nameLabel.font = .systemFont(ofSize: 17)
        return nameLabel
    }()
    
    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel(frame: .zero)
        timeLabel.textColor = .systemGray
        timeLabel.font = .systemFont(ofSize: 13, weight: .medium)
        return timeLabel
    }()
    
    lazy var containerView: UIView = {
        let containerView = UIView(frame: .zero)
        return containerView
    }()

}
