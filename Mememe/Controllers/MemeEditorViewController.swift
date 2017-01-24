//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit
import Photos

//public protocol MemeEditorViewDelegate {
//    func memeEditorViewControllerImageDidEdit(image: UIImage)
//    func memeEditorViewViewControllerDidCancel()
//}

class MemeEditorViewController: UIViewController {
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var topToolbar: UIToolbar!

    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var memeView: UIView!
    
    @IBOutlet weak var fontCollectionView: UICollectionView!
    // Single ton Pattern
    
    let memePhotoAlbum = MemeDataManager.shared
    // Custom Delegate
//    var delegate:MemeEditorViewDelegate?
    
    let fontData = AppModel.fontsAvailable
    
    // Defalut 이름 값.
//    var selectedFontName = "HelveticaNeue-CondensedBlack"
    var selectedCellIndexPath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fontCollectionView.delegate = self
        self.fontCollectionView.dataSource = self
//        setupImageViewTapEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
        self.configureUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 안전하게 완전히 사라진 후 Observer 제거
        self.unsubscribeFromKeyboardNotifications()
    }
    /*
    private func setupImageViewTapEvent(){
        let tapGesture = UIGestureRecognizer(target: self.imageView, action: #selector(self.imageViewTapped(_:)))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(tapGesture)
    }
    
    func imageViewTapped( _ : UIGestureRecognizer){
        print("Tap!!!")
        // 항상 self.fontCollectionView 숨기기.
        self.fontCollectionView.isHidden = true
        
        // 이미 숨겨져 있는 상태일땐 다시 보여주기.
        if self.topToolbar.isHidden {
            self.setToolbarHidden(false)
        } else {
            self.setToolbarHidden(true)
        }
    }
 */
    
    private func configureUI() {
        self.fontCollectionView.isHidden = true
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
    /*
    private func setToolbarHidden(_ isHidden: Bool) {
        self.topToolbar.isHidden = isHidden
        self.bottomToolbar.isHidden = isHidden
    }
     */
    
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
        memePhotoAlbum.save(image)
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        // Air Drop 잘 안쓰기 때문에 생략.
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
        // 성공 실패 여부 상관없이 Completion Handler
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            self.dismiss(animated: true, completion: nil)
        }
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
            // bottom Textfield 편집시 bottom tool bar hide
            self.bottomToolbar.isHidden = true
            view.frame.origin.y = -getKeyboardHeight(notification: notification)
        }
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
        self.bottomToolbar.isHidden = false
    }
    
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {
        // 원본에서 필요한방법으로 수정 (Tool Bar 숨길 필요 없음.)
        UIGraphicsBeginImageContext(self.memeView.bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            self.memeView.layer.render(in: context)
        }
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return memedImage
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
    // 이전에 써져있는 글 지우기.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == topTextField && textField.text == AppModel.defaultTopTextFieldText {
            
            textField.text = ""
            
        } else if textField == bottomTextField && textField.text == AppModel.defaultBottomTextFieldText {
            
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
        if textField == self.topTextField && textField.text!.isEmpty {
            textField.text = AppModel.defaultTopTextFieldText;
        } else if textField == self.bottomTextField && textField.text!.isEmpty {
            textField.text = AppModel.defaultBottomTextFieldText;
        }
    }

}
