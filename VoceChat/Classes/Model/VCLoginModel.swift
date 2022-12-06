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
    public var user: VCLoginModelUser?
}

public class VCLoginModelUser: VCBaseModel {
    public var avatar_updated_at: Int = 0
    public var create_by: String?
    public var email: String?
    public var gender: Int = 0
    public var is_admin: Bool = false
    public var language: String?
    public var name: String?
    public var uid: Int = 0
}
