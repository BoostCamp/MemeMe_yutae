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
        
        // View 사라지려 할 때 Observer 제거
        self.unsubscribeFromKeyboardNotifications()
        /*
            self.fontData.count 까지 범위 이므로 selectedCellIndexPath 존재하면
            fontData[indexPath.row] 값 존재
            UserDefaults에  기록
         */
        if let indexPath = selectedCellIndexPath {
            self.userDefaults.setValue(self.fontData[indexPath.row], forKey: Constants.UserDefaultsKey.fontName)
            self.userDefaults.synchronize()
        }
    }
    
    private func setupEditor() {
        // Add Observer KeyboardNotifications
        self.subscribeToKeyboardNotifications()
        
        // Setup Font Collection
        self.fontCollectionView.isHidden = true
        self.fontDefaultName = userDefaults.string(forKey: Constants.UserDefaultsKey.fontName)
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
        if AppModel.Permission.checkPhotoLibraryAndCameraPermission(.photoLibrary) {
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
        if #available(iOS 9.0, *) {
            let doneAlertAction: UIAlertAction = UIAlertAction.init(title: Constants.Alert.refreshButtonTitle, style: .default, handler: { (action) in
                // UI 이기 때문에 Main Thread 비동기 처리
                DispatchQueue.main.async {
                    // Refresh Text Fields
                    self.setupTextFields([self.topTextField, self.bottomTextField])
                }
            })
            AppModel.Alert.show(self, title: Constants.Alert.refreshAlertTitle, message: Constants.Alert.refreshAlertMessage, alertAction: doneAlertAction)
        }
        // iOS 9.0 미만
        else {
            AppModel.Alert.show(self, title: Constants.Alert.refreshAlertTitle, message: Constants.Alert.refreshAlertMessage, buttonTitle: Constants.Alert.refreshButtonTitle)
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
        // NotificationCenter Observer 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        // NotificationCenter 제거
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
        // 시뮬레이션에서 Keypad 사용 안할때 대비 Editing End
        self.view.endEditing(true)
        self.fontCollectionView.isHidden = true
        self.setToolbarHidden(true)
        // frame 대신 bounds 를 사용한 이유 - bounds 는 x,y 가 자신이 기준이 되기 때문 <-> frame 은 부모 View 기준
        UIGraphicsBeginImageContext(self.memeView.bounds.size)
        self.memeView.drawHierarchy(in: self.memeView.bounds, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.setToolbarHidden(false)
        return memedImage
    }
    
    func presentImagePickerWithSourType(_ sourceType: UIImagePickerControllerSourceType){
        // Permission Check!
        if AppModel.Permission.checkPhotoLibraryAndCameraPermission(sourceType, viewController: self) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            self.present(imagePicker, animated: true, completion:nil)
        }
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
