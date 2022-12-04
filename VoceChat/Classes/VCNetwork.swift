//
//  VCNetwork.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/4.
//

import Foundation
import Alamofire

class VCNetwork: NSObject {
    class func get(url: String , param: Parameters?){
        http(url: url, method: .get, param: param)
    }
    
    class func post(url: String , param: Parameters?){
        http(url: url, method: .post, param: param)
    }
    
    class func put(url: String , param: Parameters?){
        http(url: url, method: .put, param: param)
    }
    
    class func delete(url: String , param: Parameters?){
        http(url: url, method: .delete, param: param)
    }
    
    private class func http(url: String, method: HTTPMethod, param: Parameters?){
        let serverURL = UserDefaults.standard.string(forKey: .serverURLKey) ?? ""
        AF.request(serverURL + url, method: method, parameters: param,  encoding: JSONEncoding.default, headers: ["Refer":serverURL]).responseJSON { responseJSON in
            switch responseJSON.result {
            case .success(let result):
                debugPrint(result)
                break
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}
