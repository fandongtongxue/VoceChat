//
//  VCNetwork.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/4.
//

import Foundation
import Alamofire
import Toast_Swift

class VCNetwork: NSObject {
    class func get(url: String , param: Parameters?, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        http(url: url, method: .get, param: param, success: success, failure: failure)
    }
    
    class func post(url: String , param: Parameters?, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        http(url: url, method: .post, param: param, success: success, failure: failure)
    }
    
    class func put(url: String , param: Parameters?, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        http(url: url, method: .put, param: param, success: success, failure: failure)
    }
    
    class func delete(url: String , param: Parameters?, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        http(url: url, method: .delete, param: param, success: success, failure: failure)
    }
    
    private class func http(url: String, method: HTTPMethod, param: Parameters?, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        let serverURL = UserDefaults.standard.string(forKey: .serverURLKey) ?? ""
        AF.request(serverURL + url, method: method, parameters: param,  encoding: JSONEncoding.default, headers: ["Refer":serverURL]).responseJSON { responseJSON in
            switch responseJSON.result {
            case .success(let result):
                success(result)
                break
            case .failure(let error):
                failure(error.errorDescription ?? "")
                break
            }
        }
    }
}
