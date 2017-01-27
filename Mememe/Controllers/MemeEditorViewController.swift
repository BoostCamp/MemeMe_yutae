//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//
import Foundation
import UIKit
import Photos

public protocol MemeEditorViewDelegate {
    func memeEditorViewController(saveImage image: UIImage)
}

class MemeEditorViewController: UIViewController {
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var memeView: UIView!
    
    @IBOutlet weak var fontCollectionView: UICollectionView!
    // Single ton Pattern
    let memeDataManager:MemeDataManager = MemeDataManager.shared
    let userDefaults:UserDefaults = UserDefaults.standard
    
    // Custom Delegation
//    var delegate:MemeEditorViewDelegate?
    
    let fontData = Constants.fontsAvailable
    // Defalut font Name 값.
    var fontDefaultName:String?
    var selectedCellIndexPath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fontCollectionView.delegate = self
        self.fontCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupEditor()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /*
            self.fontData.count 까지 범위 이므로 selectedCellIndexPath 존재하면
            fontData[indexPath.row] 값 존재
            UserDefaults에  기록
         */
        if let indexPath = selectedCellIndexPath {
            self.userDefaults.setValue(self.fontData[indexPath.row], forKey: Constants.UserDafaultsKey.fontName)
            self.userDefaults.synchronize()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 안전하게 완전히 사라진 후 Observer 제거
        self.unsubscribeFromKeyboardNotifications()
    }
    
    private func setupEditor() {
        // Add Observer KeyboardNotifications
        self.subscribeToKeyboardNotifications()
        
        // Setup Font Collection
        self.fontCollectionView.isHidden = true
        self.fontDefaultName = userDefaults.string(forKey: Constants.UserDafaultsKey.fontName)
        // Optional Binding
        if let fontName = self.fontDefaultName {
            if let index = self.fontData.index(of: fontName) {
                self.selectedCellIndexPath = IndexPath.init(row: index, section: 0)
            }
        }
        // Setup Text Fields
        self.setupTextFields([self.topTextField, self.bottomTextField])
    }
    
    func setupTextFields(_ textFields: [UITextField]) {
        for textField in textFields {
            textField.defaultTextAttributes = Constants.MemeDefaultsValue.textAttributes
            // Optional Binding
            if let fontName = self.fontDefaultName{
                textField.font = UIFont.init(name: fontName, size: 40.0)
            }
            textField.textAlignment = NSTextAlignment.center
            textField.delegate = self;
            switch textField {
            case self.topTextField:
                self.topTextField.text = Constants.MemeDefaultsValue.topTextFieldText
            case self.bottomTextField:
                self.bottomTextField.text = Constants.MemeDefaultsValue.bottomTextFieldText
            default:
                return
            }
        }
    }
    
    // 시간, 배터리 등 StatusBar 숨기기
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
        self.fontCollectionView.isHidden = !self.fontCollectionView.isHidden
    }
    @IBAction func doneAction(_ sender: Any) {
        // Optional Binding
        let image = generateMemedImage()
        if Constants.Permission.checkPhotoLibraryAndCameraPermission(.photoLibrary) {
            self.memeDataManager.save(image, completion: { (isSuccess) in
                if isSuccess {
                    self.showActivityViewController(image)
                }
            })
        }
        else {
            // 권한이 없을 경우 공유만
            self.showActivityViewController(image)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func refreshAction(_ sender: Any) {
        // 여기서만 사용하기 때문에 static 변수로 사용 안함.
        let alertTitle:String = "정말 원 상태로 돌아가시겠습니까?"
        let alertMessage:String = "확인을 누르시면 이 작업물은 앨범에 저장되지 않습니다."
        
        if #available(iOS 9.0, *) {
            let doneAlertAction: UIAlertAction = UIAlertAction.init(title: Constants.Alert.refreshButtonTitle, style: .default, handler: { (action) in
                // UI 이기 때문에 Main Thread 비동기 처리
                DispatchQueue.main.async {
                    // Refresh Text Fields
                    self.setupTextFields([self.topTextField, self.bottomTextField])
                }
            })
            Constants.Alert.show(self, title: Constants.Alert.refreshButtonTitle, message: alertMessage, alertAction: doneAlertAction)
        }
        // iOS 9.0 미만
        else {
            Constants.Alert.show(self, title: alertTitle, message: alertTitle, buttonTitle: Constants.Alert.refreshButtonTitle)
        }
    }
    
    private func showActivityViewController(_ image: UIImage){
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        // Air Drop 잘 안쓰기 때문에 생략.
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
        // 성공 실패 여부 상관없이 Completion Handler
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            self.dismiss(animated: true, completion: nil)
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: Notification Funtions 다른 곳에서 불려지지 않게 private
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: Keyboard Related Methods and Delegates
    func keyboardWillShow(notification: NSNotification) {
        if self.bottomTextField.isFirstResponder {
            // bottom Textfield 편집시 bottom tool bar hide
            self.bottomToolbar.isHidden = true
            self.view.frame.origin.y = -getKeyboardHeight(notification: notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        self.bottomToolbar.isHidden = false
    }
    
    private func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        // Optional Binding
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                return keyboardSize.cgRectValue.height
            }
        }
        return 0.0
    }
    
    func generateMemedImage() -> UIImage {
        // 원본에서 필요한방법으로 수정 (Tool Bar는 숨길 필요 없음.)
        self.fontCollectionView.isHidden = true
        /*
        UIGraphicsBeginImageContext(self.memeView.bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            self.memeView.layer.render(in: context)
        }
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
         */
        self.setToolbarHidden(true)
        UIGraphicsBeginImageContext(self.imageView.bounds.size)
        self.view.drawHierarchy(in: self.imageView.bounds, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.setToolbarHidden(false)
        return memedImage
    }
    
    func presentImagePickerWithSourType(_ sourceType: UIImagePickerControllerSourceType){
        // Permission Check!
        if Constants.Permission.checkPhotoLibraryAndCameraPermission(sourceType, viewController: self) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            self.present(imagePicker, animated: true, completion:nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MemeEditorViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Optional TypeCast Binding
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
    // 이전에 써져있는 글 지우기.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.topTextField && textField.text == Constants.MemeDefaultsValue.topTextFieldText {
            textField.text = ""
        } else if textField == self.bottomTextField && textField.text == Constants.MemeDefaultsValue.bottomTextFieldText {
            textField.text = ""
        }
    }
    
    // 대문자로 변경하기.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var text = textField.text as NSString?
        text = text!.replacingCharacters(in: range, with: string) as NSString?
        textField.text = text?.uppercased
        return false
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // return 키 눌렀을때
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 편집이 끝났을때 내용이 비어있을때
        if let textFieldIsEmpty = textField.text?.isEmpty {
            if textFieldIsEmpty {
                if textField == self.topTextField {
                    textField.text = Constants.MemeDefaultsValue.topTextFieldText
                } else if textField == self.bottomTextField {
                    textField.text = Constants.MemeDefaultsValue.bottomTextFieldText
                }
            }
        }
    }
}
// For iOS < 9
extension MemeEditorViewController: UIAlertViewDelegate {
    // alertView.tag 를 사용안하고 button title로 구별
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if let buttonTitle = alertView.buttonTitle(at: buttonIndex) {
            switch buttonTitle {
            case Constants.Alert.settingsButtonTitle:
                if let settingsUrl = Constants.Alert.settingsUrl {
                    UIApplication.shared.openURL(settingsUrl)
                }
            case Constants.Alert.refreshButtonTitle:
                self.setupTextFields([self.topTextField, self.bottomTextField])
            default:
                return
            }
        }
    }
}
