//
//  VCLoginConfigModel.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/15.
//

import UIKit

public class VCLoginConfigModel: VCBaseModel {
    public var github: Bool = false
    public var google: Bool = false
    public var guest: Bool = false
    public var magic_link: Bool = false
    public var metamask: Bool = false
    public var oidc = [VCLoginConfigModelOidc]()
    public var password: Bool = false
    public var third_party: Bool = false
    public var who_can_sign_up = ""
}

public class VCLoginConfigModelOidc: VCBaseModel {
    public var domain = ""
    public var enable: Bool = false
    public var favicon = ""
}

