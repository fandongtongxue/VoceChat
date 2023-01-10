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
    class func get(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((Int)->())){
        http(url: url, method: .get, param: param, success: success, failure: failure)
    }
    
    class func post(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((Int)->())){
        http(url: url, method: .post, param: param, success: success, failure: failure)
    }
    
    class func put(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((Int)->())){
        http(url: url, method: .put, param: param, success: success, failure: failure)
    }
    
    class func delete(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((Int)->())){
        http(url: url, method: .delete, param: param, success: success, failure: failure)
    }
    
    class func getRaw(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((Int)->())){
        httpRaw(url: url, method: .get, param: param, success: success, failure: failure)
    }
    
    class func postRaw(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((Int)->())){
        httpRaw(url: url, method: .post, param: param, success: success, failure: failure)
    }
    
    class func putRaw(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((Int)->())){
        httpRaw(url: url, method: .put, param: param, success: success, failure: failure)
    }
    
    class func deleteRaw(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((Int)->())){
        httpRaw(url: url, method: .delete, param: param, success: success, failure: failure)
    }
    
    private class func http(url: String, method: HTTPMethod = .get, param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((Int)->())){
        if NetworkReachabilityManager()?.isReachable ?? false {
            cookieLoad()
            let serverURL = UserDefaults.standard.string(forKey: .serverURLKey) ?? ""
            var newUrl = serverURL + url
            var newParam: Parameters? = nil
            if method == .get {
                if VCManager.shared.currentUser()?.token.count ?? 0 > 0 {
                    newUrl.append("?api-key=")
                    newUrl.append(VCManager.shared.currentUser()?.token ?? "")
                }
                param?.keys.forEach({ key in
                    newUrl.append("&")
                    newUrl.append(key)
                    newUrl.append("=")
                    newUrl.append("\(param?[key] ?? "")")
                })
            }else{
                newParam = param
                newParam?["api-key"] = VCManager.shared.currentUser()?.token
            }
            AF.request(newUrl, method: method, parameters: newParam,  encoding: JSONEncoding.default, headers: ["x-api-key":VCManager.shared.currentUser()?.token ?? "", "Referer":serverURL+"/"]).responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let result):
                    if responseJSON.response?.statusCode != 200 {
                        failure(responseJSON.response?.statusCode ?? -1)
                    }else {
                        success(result)
                    }
                    break
                case .failure(let error):
                    failure(responseJSON.response?.statusCode ?? -1)
                    break
                }
            }
        }else {
            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("No network", comment: ""))
        }
        
    }
    
    private class func httpRaw(url: String, method: HTTPMethod = .get, param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((Int)->())){
        if NetworkReachabilityManager()?.isReachable ?? false {
            cookieLoad()
            let serverURL = UserDefaults.standard.string(forKey: .serverURLKey) ?? ""
            var newUrl = serverURL + url
            var newParam: Parameters? = nil
            if method == .get {
                if VCManager.shared.currentUser()?.token.count ?? 0 > 0 {
                    newUrl.append("?api-key=")
                    newUrl.append(VCManager.shared.currentUser()?.token ?? "")
                }
                param?.keys.forEach({ key in
                    newUrl.append("&")
                    newUrl.append(key)
                    newUrl.append("=")
                    newUrl.append("\(param?[key] ?? "")")
                })
            }else{
                newParam = param
                newParam?["api-key"] = VCManager.shared.currentUser()?.token
            }
            AF.request(newUrl, method: method, parameters: newParam,  encoding: JSONEncoding.default, headers: ["x-api-key":VCManager.shared.currentUser()?.token ?? "", "Referer":serverURL+"/"]).response { response in
                switch response.result {
                case .success(let result):
                    if response.response?.statusCode != 200 {
                        failure(response.response?.statusCode ?? -1)
                    }else {
                        success(result)
                    }
                    break
                case .failure(let error):
                    failure(response.response?.statusCode ?? -1)
                    break
                }
            }
        }else {
            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("No network", comment: ""))
        }
        
    }
    
    public class func httpBody(url: String, method: HTTPMethod = .get, param: Parameters? = nil, body: String?, Content_Type: String, mid: Int, success: @escaping ((Any)->()), failure: @escaping ((Int)->())){
        if NetworkReachabilityManager()?.isReachable ?? false {
            cookieLoad()
            let serverURL = UserDefaults.standard.string(forKey: .serverURLKey) ?? ""
            var newUrl = serverURL + url
            var newParam: Parameters? = nil
            if method == .get {
                if VCManager.shared.currentUser()?.token.count ?? 0 > 0 {
                    newUrl.append("?api-key=")
                    newUrl.append(VCManager.shared.currentUser()?.token ?? "")
                }
                param?.keys.forEach({ key in
                    newUrl.append("&")
                    newUrl.append(key)
                    newUrl.append("=")
                    newUrl.append("\(param?[key] ?? "")")
                })
            }else{
                newParam = param
                newParam?["api-key"] = VCManager.shared.currentUser()?.token
            }
            do {
                var request = try URLRequest(url: newUrl, method: method)
                request.setValue(VCManager.shared.currentUser()?.token, forHTTPHeaderField: "x-api-key")
                request.setValue(serverURL+"/", forHTTPHeaderField: "Referer")
                request.setValue(Content_Type, forHTTPHeaderField: "Content-Type")
                
                var json = ""
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(["cid":mid])
                json = String(data: jsonData, encoding: .utf8)!
                let finalStr = json.data(using: .utf8)?.base64EncodedString()
                
                request.setValue(finalStr, forHTTPHeaderField: "X-Properties")
                
                var newBody = body
                if Content_Type == "vocechat/file"{
                    let bodyData = try jsonEncoder.encode(["path":body])
                    newBody = String(data: bodyData, encoding: .utf8)!
                    newBody = json.data(using: .utf8)?.base64EncodedString()
                }
                request.httpBody = newBody?.data(using: .utf8)
                AF.request(request).response { response in
                    switch response.result {
                    case .success(let result):
                        if response.response?.statusCode != 200 {
                            failure(response.response?.statusCode ?? -1)
                        }else {
                            success(result)
                        }
                        break
                    case .failure(let error):
                        failure(response.response?.statusCode ?? -1)
                        break
                    }
                }
            } catch {
                
            }
        }else {
            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("No network", comment: ""))
        }
        
    }
    
    class func uploadAvatar(url: String, image: UIImage, param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((Int)->())) {
        if NetworkReachabilityManager()?.isReachable ?? false {
            cookieLoad()
            let serverURL = UserDefaults.standard.string(forKey: .serverURLKey) ?? ""
            let newUrl = serverURL + url
            do {
                var request = try URLRequest(url: newUrl, method: .post)
                request.setValue(VCManager.shared.currentUser()?.token, forHTTPHeaderField: "x-api-key")
                request.setValue(serverURL+"/", forHTTPHeaderField: "Referer")
                request.setValue("image/png", forHTTPHeaderField: "Content-Type")
                //上传头像
                AF.upload(UIImageJPEGRepresentation(image, 0.5)!, with: request).response { response in
                    switch response.result {
                    case .success(let result):
                        if response.response?.statusCode != 200 {
                            failure(response.response?.statusCode ?? -1)
                        }else {
                            success(result)
                        }
                        break
                    case .failure(let error):
                        failure(response.response?.statusCode ?? -1)
                        break
                    }
                }
            }catch {
                
            }
        }else {
            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("No network", comment: ""))
        }
    }
    
    class func uploadImage(url: String, file_id: String, imageURL: URL, param: Parameters? = nil, success: @escaping ((VCUploadImageModel)->()), failure: @escaping ((Int)->())) {
        guard file_id != nil && imageURL != nil else {
            return
        }
        if NetworkReachabilityManager()?.isReachable ?? false {
            cookieLoad()
            let serverURL = UserDefaults.standard.string(forKey: .serverURLKey) ?? ""
            let newUrl = serverURL + url
            do {
                var request = try URLRequest(url: newUrl, method: .post)
                request.setValue(VCManager.shared.currentUser()?.token, forHTTPHeaderField: "x-api-key")
                request.setValue(serverURL+"/", forHTTPHeaderField: "Referer")
                request.setValue("image/png", forHTTPHeaderField: "Content-Type")
                //发送图片
                let fileData = try Data(contentsOf: imageURL)
                uploadImageFile(file_id: file_id, fileData: fileData, request: request) { result in
                    let resultDict = result as? NSDictionary
                    let model = VCUploadImageModel.deserialize(from: resultDict) ?? VCUploadImageModel()
                    if model.path.count > 0 {
                        success(model)
                    }
                } failure: { error in
                    failure(error)
                }
            }catch {
                
            }
        }else {
            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("No network", comment: ""))
        }
    }
    
    class func uploadImageFile(file_id: String, fileData: Data, request: URLRequest, success: @escaping ((Any)->()), failure: @escaping ((Int)->())) {
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(file_id.data(using: .utf8)!, withName: "file_id")
            multipartFormData.append(fileData, withName: "chunk_data")
//                    multipartFormData.append(true, withName: "chunk_is_last")
        }, with: request)
        .responseJSON { responseJSON in
            switch responseJSON.result {
            case .success(let result):
                if responseJSON.response?.statusCode != 200 {
                    failure(responseJSON.response?.statusCode ?? -1)
                }else {
                    success(result)
                }
                break
            case .failure(let error):
                failure(responseJSON.response?.statusCode ?? -1)
                break
            }
        }
    }
    
    class func cookieLoad() {
        let data = UserDefaults.standard.object(forKey: .cookieKey)
        if data != nil {
            let cookieData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
            guard let cookies = cookieData as? [HTTPCookie] else{
                return
            }
            let cookieStorage = HTTPCookieStorage.shared
            for cookie in cookies {
                cookieStorage.setCookie(cookie)
            }
        }
    }
}
