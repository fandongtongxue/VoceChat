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
    static let descKey = "DescKey"
    
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
    static let license_check = api+"/license/check"
    
    //Token
    static let token_login = api+"/token/login"
    static let token_logout = api+"/token/logout"
    static let token_device_token = api+"/token/device_token"
    
    //User
    static let user = api+"/user"
    static let user_register = user+"/register"
}
