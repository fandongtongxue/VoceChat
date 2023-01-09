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
    
    private var selectedAssetIdentifiers = [String]()
    private var selectedAssetIdentifierIterator: IndexingIterator<[String]>?
    private var currentAssetIdentifier: String?
    
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var nameTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemGroupedBackground
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
                guard self.nameTF.text?.count ?? 0 > 0 else { return }
                VCManager.shared.updateUserName(name: self.nameTF.text!) { user in
                    //do nothing
                } failure: { error in
                    //do nothing
                }

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
        self.avatarImgView.image = originImage
        VCManager.shared.updateUserAvatar(image: originImage) {
            //do nothing
        } failure: { error in
            //do nothing
        }
    }
    
}

extension ProfileEditViewController: PHPickerViewControllerDelegate {
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

extension ProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        guard let originImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.setImage(originImage: originImage)
    }
}
