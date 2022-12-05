//
//  VoceChatManager.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/4.
//

import Foundation
import Alamofire

public class VCManager: NSObject {
    
    
    /// 服务器URL
    /// - Parameter serverUrl: 服务器URL
    public class func register(serverUrl: String) {
        //存储服务器URL
        UserDefaults.standard.set(serverUrl, forKey: .serverURLKey)
        UserDefaults.standard.synchronize()
        //获取系统组织信息
        VCNetwork.get(url: .system_organization, param: nil) { result in
            debugPrint(result)
        } failure: { error in
            debugPrint(error)
        }
        
        VCNetwork.get(url: .system_initialized, param: nil) { result in
            debugPrint(result)
        } failure: { error in
            debugPrint(error)
        }
        
        VCNetwork.get(url: .login_config, param: nil) { result in
            debugPrint(result)
        } failure: { error in
            debugPrint(error)
        }


    }
    
    public class func login(email: String, password: String, success: @escaping ((Any)->()), failure: @escaping ((String)->())) {
        let credential = ["email":email,"password":password,"type":"password"]
        let device = UIDevice.current.model
        VCNetwork.post(url: .token_login, param: ["credential":credential, "device": device]) { result in
            debugPrint(result)
        } failure: { error in
            debugPrint(error)
        }

    }
}
