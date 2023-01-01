//
//  VoceChat.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/4.
//

import Foundation

extension String {
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
    
    //User
    static let user = api+"/user"
    static let user_register = user+"/register"
    static let user_events = user+"/events"
    static let user_check_email = user+"/check_email"
    
    //Admin
    static let admin_login_config = api+"/admin/login/config"
    
    //Favorite
    static let favorite = api+"/favorite"
    static let favorite_attachment = favorite+"/attachment"
    
    //Group
    static let group = api+"/group"
    
    //Message
    static let message = api+"/message"
}

public extension Notification.Name {
    static let user_state = Notification.Name(rawValue: "user_state")
}
