//
//  TitleView.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/4.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat
import CDFInitialsAvatar

class TitleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.imgView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    var _chat : VCMessageModel!
    public var chat : VCMessageModel!{
        set{
            _chat = newValue
            //设置数据
            let user = VCManager.shared.getUserFromTable(uid: newValue.from_uid)
            let avatar = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: 40, height: 40), fullName: user.name)
            avatar?.backgroundColor = .systemBlue
            imgView.sd_setImage(with: URL(string: .ServerURL + .resource_avatar + "?uid=\(newValue.from_uid)" + "&t=\(user.avatar_updated_at)"), placeholderImage: avatar?.imageRepresentation)
            titleLabel.text = user.name
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
            imgView.sd_setImage(with: URL(string: .ServerURL + .resource_group_avatar + "?uid=\(newValue.gid)" + "&t=\(newValue.avatar_updated_at)"), placeholderImage: avatar?.imageRepresentation)
            titleLabel.text = newValue.name
        }
        get{
            return _channel
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var imgView: UIImageView = {
        let imgView = UIImageView(frame: .zero)
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 20
        return imgView
    } ()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .darkText
        return titleLabel
    }()

}
