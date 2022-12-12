//
//  VoceChatManager.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/4.
//

import Foundation
import HandyJSON

public class VCManager: NSObject {
    
    /// 服务器URL
    /// - Parameter serverUrl: 服务器URL
    public class func register(serverUrl: String) {
        //存储服务器URL
        UserDefaults.standard.set(serverUrl, forKey: .serverURLKey)
        UserDefaults.standard.synchronize()
        //获取系统组织信息
        VCNetwork.get(url: .system_organization) { result in
            let info = VCOrganizationModel.deserialize(from: result as? NSDictionary) ?? VCOrganizationModel()
            UserDefaults.standard.set(info.name, forKey: .nameKey)
            UserDefaults.standard.set(info.description, forKey: .descKey)
            UserDefaults.standard.synchronize()
        } failure: { error in
            debugPrint(error)
        }
    }
    
    public class func serverInfo() -> VCOrganizationModel{
        let name = UserDefaults.standard.string(forKey: .nameKey)
        let desc = UserDefaults.standard.string(forKey: .descKey)
        let serverURL = UserDefaults.standard.string(forKey: .serverURLKey)
        let info = VCOrganizationModel()
        info.name = name
        info.description = desc
        info.serverURL = serverURL
        return info
    }
    
    public class func login(email: String, password: String, success: @escaping ((VCLoginModel)->()), failure: @escaping ((String)->())) {
        let credential = ["email":email,"password":password,"type":"password"]
        let device = UIDevice.current.model
        VCNetwork.post(url: .token_login, param: ["credential":credential, "device": device]) { result in
            let model = VCLoginModel.deserialize(from: result as? NSDictionary) ?? VCLoginModel()
            success(model)
        } failure: { error in
            failure(error)
        }
    }
}
