//
//  MessageImageCell.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/5.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class MessageImageCell: MessageListCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        containerView.addSubview(imgView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var model : VCMessageModel!{
        set{
            _model = newValue
            super.model = newValue
            //设置数据
            imgView.sd_setImage(with: URL(string: .ServerURL + .resource_file + "?file_path=" + model.detail.content + "&thumbnail=" + "true"))
            if newValue.from_uid == VCManager.shared.currentUser()?.user.uid {
                imgView.snp.makeConstraints { make in
                    make.right.top.bottom.equalToSuperview()
                    make.left.greaterThanOrEqualToSuperview()
                }
            }else {
                imgView.snp.makeConstraints { make in
                    make.left.top.bottom.equalToSuperview()
                    make.right.lessThanOrEqualToSuperview()
                }
            }
        }
        get{
            return _model
        }
    }
    
    lazy var imgView: UIImageView = {
        let imgView = UIImageView(frame: .zero)
        imgView.contentMode = .scaleAspectFit
        return imgView
    } ()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
