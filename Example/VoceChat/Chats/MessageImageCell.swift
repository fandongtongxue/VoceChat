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
            let realImageHeight = CGFloat(model.detail.properties.height) * (.screenW - 80) / CGFloat(model.detail.properties.width) / 3
            let realImageWidth = realImageHeight * CGFloat(model.detail.properties.width) / CGFloat(model.detail.properties.height)
            if newValue.from_uid == VCManager.shared.currentUser()?.user.uid {
                imgView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                    make.width.equalTo(realImageWidth)
                }
            }else {
                imgView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                    make.width.equalTo(realImageWidth)
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
