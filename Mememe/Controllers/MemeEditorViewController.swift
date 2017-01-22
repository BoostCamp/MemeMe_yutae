//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit
import Photos

public protocol MemeEditorViewDelegate {
    func memeEditorViewControllerImageDidEdit(image: UIImage)
    func memeEditorViewViewControllerDidCancel()
}

class MemeEditorViewController: UIViewController {
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var topToolbar: UIToolbar!

    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var memeView: UIView!
    
    // Single ton Pattern
//    let memePhotoAlbum = MemePhotoAlbum.shared
    
    // Custom Delegate
    var delegate:MemeEditorViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 안전하게 완전히 사라진 후 Observer 제거
        unsubscribeFromKeyboardNotifications()
    }
    
    private func configureUI() {
        self.setupTextFields(self.topTextField, text: AppModel.defaultTopTextFieldText)
        self.setupTextFields(self.bottomTextField, text: AppModel.defaultBottomTextFieldText)
    }
    
    private func setupTextFields(_ textField: UITextField, text: String) {
        textField.defaultTextAttributes = AppModel.memeTextAttributes
        textField.text = text
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self;
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setToolbarHidden(_ isHidden: Bool) {
        self.topToolbar.isHidden = isHidden
        self.bottomToolbar.isHidden = isHidden
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        self.presentImagePickerWithSourType(UIImagePickerControllerSourceType.camera)
    }

    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        self.presentImagePickerWithSourType(UIImagePickerControllerSourceType.photoLibrary)
    }
    
    @IBAction func setFontAction(_ sender: Any) {
    }
    
    @IBAction func doneAction(_ sender: Any) {
    }
    
    @IBAction func cancelAction(_ sender: Any) {
    }
    
    // MARK: Notification Funtions
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: Keyboard Related Methods and Delegates
    func keyboardWillShow(notification: NSNotification) {
        if self.bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification: notification)
        }
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    
    func presentImagePickerWithSourType(_ sourceType: UIImagePickerControllerSourceType){
//        if self.checkPhotoLibraryPermission(){
            // 2단 안전 장치
//            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = sourceType
                self.present(imagePicker, animated: true, completion:nil)
//            }
//        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension MemeEditorViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Permission Check
    public func checkPhotoLibraryPermission() -> Bool{
        var isAuthorized = false
        let status = PHPhotoLibrary.authorizationStatus()
        if status != .authorized {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status != .authorized {
                    self.openSetting(UIImagePickerControllerSourceType.photoLibrary)
                }
            })
            
        } else {
            isAuthorized = true
        }
        return isAuthorized
    }
    
    public func openSetting(_ sourceType:UIImagePickerControllerSourceType){
        var alertContent : AppModel.PermissionAlert!
        switch sourceType {
        case .camera :
            alertContent = AppModel.PermissionAlert.init(type: "카메라")
        case .photoLibrary :
            alertContent = AppModel.PermissionAlert.init(type: "앨범")
        default:
            print("Defalut")
        }
        
        if #available(iOS 9.0, *) {
            let alert = UIAlertController(title: alertContent.title, message: alertContent.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "설정", style: .default, handler: { (action:UIAlertAction) -> Void in
                let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(settingsUrl!)
                }
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            // 9.0 미만
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Optional Binding TypeCast
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = image
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MemeEditorViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == topTextField && textField.text == AppModel.defaultTopTextFieldText {
            
            textField.text = ""
            
        } else if textField == bottomTextField && textField.text == AppModel.defaultBottomTextFieldText {
            
            textField.text = ""
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var text = textField.text as NSString?
        text = text!.replacingCharacters(in: range, with: string) as NSString?
        textField.text = text?.uppercased
        return false
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == topTextField && textField.text!.isEmpty {
            
            textField.text = AppModel.defaultTopTextFieldText;
            
        }else if textField == bottomTextField && textField.text!.isEmpty {
            
            textField.text = AppModel.defaultBottomTextFieldText;
        }
    }

}
