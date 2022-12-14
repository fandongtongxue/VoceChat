//
//  VCUserModel.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/14.
//

public class VCUserModel: VCBaseModel {
    public var avatar_updated_at: Int = 0
    public var create_by: String?
    public var email: String?
    public var gender: Int = 0
    public var is_admin: Bool = false
    public var language: String?
    public var name: String?
    public var uid: Int = 0
}
