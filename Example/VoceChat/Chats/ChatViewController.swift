//
//  ChatViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/26.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat
import RxCocoa
import RxSwift
import CDFInitialsAvatar
import VoceChat
import PhotosUI
import Photos
import MobileCoreServices

class ChatViewController: BaseViewController {
    
    private var selectedAssetIdentifiers = [String]()
    
    var messageVC: MessageViewController!
    var chat = VCMessageModel()
    var channel = VCChannelModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        navigationItem.title = user.name
        let titleView = TitleView(frame: CGRect(x: 0, y: 0, width: .screenW - 88, height: .navigationBarHeight))
        if chat.from_uid > 0 {
            titleView.chat = chat
        }else if channel.gid > 0 {
            titleView.channel = channel
        }
        navigationItem.titleView = titleView
        
        messageVC = MessageViewController()
        messageVC.chat = chat
        messageVC.channel = channel
        view.addSubview(messageVC.view)
        messageVC.view.frame = CGRect(x: 0, y: 0, width: .screenW, height: .screenH - .tabBarHeight)
        addChildViewController(messageVC)
        
        view.addSubview(inputBar)
        
        NotificationCenter.default.rx.notification(.UIKeyboardWillShow)
            .subscribe { noti in
                let userInfo = noti.element?.userInfo
                let keyboardFrame = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let duration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
                let keyboardH = keyboardFrame.height
                UIView.animate(withDuration: TimeInterval(duration)) {
                    self.inputBar.frame.origin.y = .screenH - keyboardH - self.inputBar.bounds.height
                    self.messageVC.view.frame.origin.y = -keyboardH + .safeAreaBottomHeight
                }
            }
            .disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(.UIKeyboardWillHide)
            .subscribe { noti in
                let userInfo = noti.element?.userInfo
                let duration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
                UIView.animate(withDuration: TimeInterval(duration)) {
                    if self.inputBar.textView.text.count == 0 {
                        self.inputBar.bounds.size.height = .tabBarHeight - .safeAreaBottomHeight
                    }
                    self.inputBar.frame.origin.y = .screenH - self.inputBar.bounds.height - .safeAreaBottomHeight
                    self.messageVC.view.frame.origin.y = 0
                }
            }
            .disposed(by: disposeBag)
        
        inputBar.textView.rx.text.orEmpty.asObservable()
            .subscribe(onNext: { text in
                let size = self.inputBar.textView.contentSize
                let currentBarHeight = self.inputBar.bounds.height
                var futureBarHeight = max(size.height + 10, .tabBarHeight - .safeAreaBottomHeight)
                if futureBarHeight >= 100 {
                    futureBarHeight = min(futureBarHeight, 100)
                }
                let compareHeight = currentBarHeight > futureBarHeight ? currentBarHeight - futureBarHeight : futureBarHeight - currentBarHeight
                self.inputBar.frame = CGRect(x: 10, y: self.inputBar.frame.minY - compareHeight, width: self.inputBar.bounds.width, height: futureBarHeight)
            })
            .disposed(by: disposeBag)
        
        let sendAble = inputBar.textView.rx.text.orEmpty.map{ $0.count > 0 }.share(replay: 1)
        sendAble.bind(to: inputBar.sendBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        inputBar.sendBtn.rx.tap.subscribe(onNext: {
            self.messageVC.sendTextMsg(text: self.inputBar.textView.text)
            self.inputBar.textView.text = ""
            self.inputBar.textView.resignFirstResponder()
        })
        .disposed(by: disposeBag)
        
        inputBar.addBtn.rx.tap.subscribe(onNext: {
            self.addBtnAction()
        }).disposed(by: disposeBag)
        //被踢出群组
        NotificationCenter.default.rx.notification(.kick_from_group).subscribe { noti in
            let model = noti.element?.object as! VCSSEEventModel
            UIApplication.shared.keyWindow?.makeToast(model.reason)
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    
    lazy var inputBar: InputBar = {
        let inputBar = InputBar(frame: CGRect(x:10, y: .screenH - .tabBarHeight, width: .screenW - 20, height: .tabBarHeight - .safeAreaBottomHeight))
        return inputBar
    }()
    
    func addBtnAction(){
        view.endEditing(true)
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            presentPicker()
        }else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { authStatus in
                if authStatus == .authorized{
                    DispatchQueue.main.async {
                        self.presentPicker()
                    }
                }else{
                    DispatchQueue.main.async {
                        self.presentAccessAlert()
                    }
                }
            }
        }else if status == .denied {
            presentAccessAlert()
        }
    }
    
    // 相册权限提示框
    func presentAccessAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Tip", comment: ""), message: NSLocalizedString("You need to open the access to library", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .destructive, handler: { action in
            DispatchQueue.main.async {
                let app = UIApplication.shared
                let url = URL(string: UIApplicationOpenSettingsURLString)
                app.open(url!, options: [:], completionHandler: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func presentPicker() {
        if #available(iOS 14.0, *) {
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            
            // Set the filter type according to the user’s selection.
            configuration.filter = PHPickerFilter.images
            // Set the mode to avoid transcoding, if possible, if your app supports arbitrary image/video encodings.
            configuration.preferredAssetRepresentationMode = .current
            // Set the selection behavior to respect the user’s selection order.
            if #available(iOS 15.0, *) {
                configuration.selection = .ordered
            } else {
                // Fallback on earlier versions
            }
            // Set the selection limit to enable multiselection.
            configuration.selectionLimit = 1
            // Set the preselected asset identifiers with the identifiers that the app tracks.
            if #available(iOS 15.0, *) {
                configuration.preselectedAssetIdentifiers = selectedAssetIdentifiers
            } else {
                // Fallback on earlier versions
            }
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            // Fallback on earlier versions
            let picker = UIImagePickerController()
            picker.mediaTypes = ["public.image"]
            picker.sourceType = .photoLibrary
            picker.delegate = self
            present(picker, animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    
    func setImage(originImage: UIImage){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths.first ?? ""
        let filePath = path+"/\(Date().timeIntervalSince1970).jpg"
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: UIImageJPEGRepresentation(originImage, 1))
        }
        
        messageVC.sendImageMsg(imageURL: URL(fileURLWithPath: filePath))
    }
    
}

extension ChatViewController: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard results.count > 0 else {
            return
        }
        let result = results.first
        guard let itemProvider = result?.itemProvider else {
            return
        }
        if itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
            _ = itemProvider.loadObject(ofClass: PHLivePhoto.self) { [weak self] livePhoto, error in
                DispatchQueue.main.async {
                    self?.handleCompletion(object: livePhoto, error: error)
                }
            }
        }
        else if itemProvider.canLoadObject(ofClass: UIImage.self) {
            _ = itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    self?.handleCompletion(object: image, error: error)
                }
            }
        } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            _ = itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                do {
                    guard let url = url, error == nil else {
                        throw error ?? NSError(domain: NSFileProviderErrorDomain, code: -1, userInfo: nil)
                    }
                    let localURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                    try? FileManager.default.removeItem(at: localURL)
                    try FileManager.default.copyItem(at: url, to: localURL)
                    DispatchQueue.main.async {
                        self?.handleCompletion(object: localURL)
                    }
                } catch let catchedError {
                    DispatchQueue.main.async {
                        self?.handleCompletion(object: nil, error: catchedError)
                    }
                }
            }
        } else {
            
        }
    }
    
    func handleCompletion(object: Any?, error: Error? = nil) {
        if let livePhoto = object as? PHLivePhoto {
//            displayLivePhoto(livePhoto)
        } else if let image = object as? UIImage {
            self.setImage(originImage: image)
        } else if let url = object as? URL {
//            displayVideoPlayButton(forURL: url)
        } else if let error = error {
            print("error: \(error)")
//            displayErrorImage()
        } else {
//            displayUnknownImage()
        }
    }
    
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        guard let originImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.setImage(originImage: originImage)
    }
}
