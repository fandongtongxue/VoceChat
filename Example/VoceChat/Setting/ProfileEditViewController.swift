//
//  ProfileEditViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/4.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import CDFInitialsAvatar
import VoceChat
import PhotosUI
import Photos
import MobileCoreServices

class ProfileEditViewController: BaseViewController {
    
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var nameTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let user = VCManager.shared.currentUser()?.user ?? VCUserModel()
        let avatar = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: 40, height: 40), fullName: user.name)
        avatar?.backgroundColor = .systemBlue
        avatarImgView.sd_setImage(with: URL(string: .ServerURL + .resource_avatar + "?uid=\(user.uid)" + "&t=\(user.avatar_updated_at)"), placeholderImage: avatar?.imageRepresentation)
        
        nameLabel.text = user.name
        setBtn.rx.tap.subscribe { element in
            self.addBtnAction()
        }.disposed(by: disposeBag)
        
        nameTF.text = user.name
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 44))
        nameTF.leftView = leftView
        nameTF.leftViewMode = .always
        
        nameTF.rx.controlEvent(.editingDidEndOnExit)
            .subscribe { element in
                
            }.disposed(by: disposeBag)
    }
    
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
            var config = PHPickerConfiguration()
            config.filter = PHPickerFilter.any(of: [.images])
            config.preferredAssetRepresentationMode = .current
            config.selectionLimit = 1
            let picker = PHPickerViewController(configuration: config)
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ProfileEditViewController: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard results.count > 0 else {
            return
        }
        let result = results.first
        let itemProvider = result?.itemProvider
        if itemProvider?.canLoadObject(ofClass: PHLivePhoto.classForCoder() as! any NSItemProviderReading.Type) ?? false {
            itemProvider?.loadObject(ofClass: PHLivePhoto.classForCoder() as! any NSItemProviderReading.Type, completionHandler: { object, error in
                guard let lpObj = object as? PHLivePhoto else { return }
                let url = lpObj.value(forKey: "imageURL") as! URL
                let image = UIImage(contentsOfFile: url.path)
                DispatchQueue.main.async {
                    self.avatarImgView.image = image!
                }
            })
        }else if itemProvider?.hasItemConformingToTypeIdentifier(kUTTypeImage as String) ?? false {
            itemProvider?.loadItem(forTypeIdentifier: kUTTypeImage as String, completionHandler: { item, error in
                guard let url = item as? URL else { return }
                let image = UIImage(contentsOfFile: url.path)
                DispatchQueue.main.async {
                    self.avatarImgView.image = image!
                }
            })
        }
    }
    
    
}

extension ProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        guard let originImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.avatarImgView.image = originImage
    }
}
