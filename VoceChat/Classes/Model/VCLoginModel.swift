//
//  VCLoginModel.swift
//
//
//  Created by JSONConverter on 2022/12/06.
//  Copyright © 2022年 JSONConverter. All rights reserved.
//

public class VCLoginModel: VCBaseModel {
    public var expired_in: Int = 0
    public var refresh_token: String?
    public var server_id: String?
    public var token: String?
    public var user: VCUserModel?
}
