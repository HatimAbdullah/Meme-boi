//
//  ViewController.swift
//  Meme boi
//
//  Created by Fish on 01/10/2019.
//  Copyright © 2019 Fish. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: 2
    ]

    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var topBar: UINavigationBar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var topText: UITextField!
    
    var barItem: UINavigationItem?
    var shareButton: UIBarButtonItem?
    var cancelButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureTexts()
        configureKeyboardDismissall()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    @IBAction func pickAnImage(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takeAnImage(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            imagePickerControllerDidCancel(picker)
            toogleButtons()
        }
        
        imagePickerControllerDidCancel(picker)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func configureNavBar() {
        
        barItem = UINavigationItem()
        shareButton = UIBarButtonItem(title: "Share", style: .done, target: nil, action: #selector(shareMeme(_:)))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(killMeme(_:)))
        
        toogleButtons()
        
        barItem?.leftBarButtonItem = shareButton
        barItem?.rightBarButtonItem = cancelButton
        
        if let bar = barItem {
            topBar.pushItem(bar, animated: true)
        }
    }
    
    private func configureTexts() {
        topText.text = "Top"
        topText.textAlignment = .center
        topText.backgroundColor = .clear
        topText.defaultTextAttributes = memeTextAttributes
        topText.autocapitalizationType = .allCharacters
        
        bottomText.text = "Bottom"
        bottomText.textAlignment = .center
        bottomText.backgroundColor = .clear
        bottomText.defaultTextAttributes = memeTextAttributes
        bottomText.autocapitalizationType = .allCharacters
    }
    
    private func configureKeyboardDismissall() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func generateMemedImage() -> UIImage {
        
        toggleBars()
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toggleBars()
        
        return memedImage
    }
    
    @objc func killMeme(_ sender: Any) {
        
        imageView.image = nil
        topText.text = "Top"
        bottomText.text = "Bottom"
        toogleButtons()
    }
    
    @objc func shareMeme(_ sender: Any) {
        
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                return
            }
            self.save()
        }
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func save() {
        // Create the meme
        _ = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
    }
    
    func toogleButtons() {
        shareButton?.isEnabled.toggle()
        cancelButton?.isEnabled.toggle()
    }
    
    func toggleBars() {
        topBar.isHidden.toggle()
        bottomBar.isHidden.toggle()
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomText.isEditing {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}

