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
    
    //API
    static let api = "/api"
    
    //系统
    static let system_organization = api+"/system/organization"
    static let system_initialized = api+"/system/initialized"
    
    //Auth
    static let google_auth_config = api+"/google_auth/config"
    static let github_auth_config = api+"/github_auth/config"
    static let login_config = api+"/login/config"
    
    //license
    static let license = api+"/license"
    static let license_check = api+"/license/check"
    
    //Token
    static let token_login = api+"/token/login"
    static let user = api+"/user"
}
