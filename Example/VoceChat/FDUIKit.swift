//
//  FDUIKit.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

extension UIButton {
    class func createBtn(title: String? = "", titleColor: UIColor? = .systemBlue, image: UIImage? = nil, backgroundColor: UIColor? = .systemBackground, font: UIFont? = .systemFont(ofSize: 15)) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setImage(image, for: .normal)
        btn.setTitleColor(titleColor, for: .normal)
        btn.backgroundColor = backgroundColor
        btn.titleLabel?.font = font ?? UIFont.systemFont(ofSize: 15, weight: .regular)
        return btn
    }
}
