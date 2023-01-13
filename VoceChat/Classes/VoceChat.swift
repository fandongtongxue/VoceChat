//
//  VoceChat.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/4.
//

import Foundation

public extension String {
    //存储相关
    static let serverURLKey = "serverURLKey"
    static let nameKey = "nameKey"
    static let descKey = "descKey"
    
    static let userKey = "userKey"
    
    static let emailKey = "emailKey"
    static let passwordKey = "passwordKey"
    
    //Network
    static let cookieKey = "cookieKey"
    
    //API
    static let api = "/api"
    
    //系统
    static let system_organization = api+"/admin/system/organization"
    static let system_initialized = api+"/admin/system/initialized"
    
    //Auth
    static let google_auth_config = api+"/admin/google_auth/config"
    static let github_auth_config = api+"/admin/github_auth/config"
    static let login_config = api+"/admin/login/config"
    
    //license
    static let license = api+"/license"
    static let license_check = license+"/check"
    
    //Token
    static let token = api+"/token"
    static let token_login = token+"/login"
    static let token_logout = token+"/logout"
    static let token_device_token = token+"/device_token"
    static let login_guest = token+"/login_guest"
    static let token_renew = token+"/renew"
    
    //User
    static let user = api+"/user"
    static let user_register = user+"/register"
    static let user_events = user+"/events"
    static let user_check_email = user+"/check_email"
    static let user_avatar = user+"/avatar"
    static let user_delete = user+"/delete"
    
    //Admin
    static let admin = api+"/admin"
    static let admin_system = api+"/admin/system"
    static let admin_login_config = admin+"/login/config"
    static let admin_system_organization = admin_system+"/organization"
    static let admin_system_organization_logo = admin_system_organization+"/logo"
    
    //Favorite
    static let favorite = api+"/favorite"
    static let favorite_attachment = favorite+"/attachment"
    
    //Group
    static let group = api+"/group"
    static let group_create_reg_magic_link = group+"/create_reg_magic_link"
    
    //Message
    static let message = api+"/message"
    
    //Resource
    static let resource = api+"/resource"
    static let resource_avatar = resource+"/avatar"
    static let resource_group_avatar = resource+"/group_avatar"
    static let resource_organization_logo = resource+"/organization/logo"
    static let resource_file = resource+"/file"
    static let resource_file_prepare = resource_file+"/prepare"
    static let resource_file_upload = resource_file+"/upload"
}

public extension Notification.Name {
    static let user_state = Notification.Name(rawValue: "user_state")
    static let users_state_changed = Notification.Name(rawValue: "users_state_changed")
    static let chat = Notification.Name(rawValue: "chat")
    static let ready = Notification.Name(rawValue: "ready")
    static let kick = Notification.Name(rawValue: "kick")
    static let joined_group = Notification.Name(rawValue: "joined_group")
}
