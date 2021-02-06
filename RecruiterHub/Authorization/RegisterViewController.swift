//
//  RegisterViewController.swift
//  Instagram
//
//  Created by Ryan Helgeson on 11/24/20.
//

import UIKit

class RegisterViewController: UIViewController {

    
    
    struct Constants {
        static let cornerRadius:CGFloat = 8.0
    }
    
    let positionData: [String] = ["RHP", "LHP", "OF", "3B", "1B", "2B", "SS", "C", "UTIL" ]
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let emailField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email Address..."
        textField.returnKeyType = .next
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let usernameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username..."
        textField.returnKeyType = .next
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let firstNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Firstname..."
        textField.returnKeyType = .next
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let lastNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Lastname..."
        textField.returnKeyType = .next
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
//    private let highSchoolField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "High School..."
//        textField.returnKeyType = .next
//        textField.leftViewMode = .always
//        textField.autocapitalizationType = .none
//        textField.autocorrectionType = .no
//        textField.layer.masksToBounds = true
//        textField.layer.cornerRadius = Constants.cornerRadius
//        textField.backgroundColor = .secondarySystemBackground
//        textField.layer.borderWidth = 1.0
//        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
//        return textField
//    }()
    
//    private let stateField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "State..."
//        textField.returnKeyType = .next
//        textField.leftViewMode = .always
//        textField.autocapitalizationType = .none
//        textField.autocorrectionType = .no
//        textField.layer.masksToBounds = true
//        textField.layer.cornerRadius = Constants.cornerRadius
//        textField.backgroundColor = .secondarySystemBackground
//        textField.layer.borderWidth = 1.0
//        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
//        return textField
//    }()
    
//    private let weightField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Weight..."
//        textField.returnKeyType = .next
//        textField.leftViewMode = .always
//        textField.autocapitalizationType = .none
//        textField.autocorrectionType = .no
//        textField.layer.masksToBounds = true
//        textField.layer.cornerRadius = Constants.cornerRadius
//        textField.backgroundColor = .secondarySystemBackground
//        textField.layer.borderWidth = 1.0
//        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
//        return textField
//    }()
//
//    private let heightInchesField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Height in inches..."
//        textField.returnKeyType = .next
//        textField.leftViewMode = .always
//        textField.autocapitalizationType = .none
//        textField.autocorrectionType = .no
//        textField.layer.masksToBounds = true
//        textField.layer.cornerRadius = Constants.cornerRadius
//        textField.backgroundColor = .secondarySystemBackground
//        textField.layer.borderWidth = 1.0
//        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
//        return textField
//    }()
//
//    private let heightfeetField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Height in feet..."
//        textField.returnKeyType = .next
//        textField.leftViewMode = .always
//        textField.autocapitalizationType = .none
//        textField.autocorrectionType = .no
//        textField.layer.masksToBounds = true
//        textField.layer.cornerRadius = Constants.cornerRadius
//        textField.backgroundColor = .secondarySystemBackground
//        textField.layer.borderWidth = 1.0
//        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
//        return textField
//    }()
//
//    private let gradYearField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Grad Year..."
//        textField.returnKeyType = .next
//        textField.leftViewMode = .always
//        textField.autocapitalizationType = .none
//        textField.autocorrectionType = .no
//        textField.layer.masksToBounds = true
//        textField.layer.cornerRadius = Constants.cornerRadius
//        textField.backgroundColor = .secondarySystemBackground
//        textField.layer.borderWidth = 1.0
//        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
//        return textField
//    }()
//
//    private let armField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Arm..."
//        textField.returnKeyType = .next
//        textField.leftViewMode = .always
//        textField.autocapitalizationType = .none
//        textField.autocorrectionType = .no
//        textField.layer.masksToBounds = true
//        textField.layer.cornerRadius = Constants.cornerRadius
//        textField.backgroundColor = .secondarySystemBackground
//        textField.layer.borderWidth = 1.0
//        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
//        return textField
//    }()
//
//    private let batsField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Bats..."
//        textField.returnKeyType = .next
//        textField.leftViewMode = .always
//        textField.autocapitalizationType = .none
//        textField.autocorrectionType = .no
//        textField.layer.masksToBounds = true
//        textField.layer.cornerRadius = Constants.cornerRadius
//        textField.backgroundColor = .secondarySystemBackground
//        textField.layer.borderWidth = 1.0
//        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
//        return textField
//    }()
    
    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password..."
        textField.returnKeyType = .continue
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.isSecureTextEntry = true
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        button.backgroundColor = .systemGreen
        return button
    }()
    
    private let picker: UIPickerView = {
        let picker = UIPickerView()
        
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .done, target: self, action: #selector(didTapBack))
        

        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tapGesture)
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
//        picker.delegate = self
//        picker.dataSource = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(usernameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
//        scrollView.addSubview(highSchoolField)
        scrollView.addSubview(registerButton)
//        scrollView.addSubview(picker)
//        scrollView.addSubview(stateField)
        scrollView.addSubview(lastNameField)
//        scrollView.addSubview(weightField)
//        scrollView.addSubview(heightfeetField)
//        scrollView.addSubview(heightInchesField)
        scrollView.addSubview(firstNameField)
//        scrollView.addSubview(gradYearField)
//        scrollView.addSubview(armField)
//        scrollView.addSubview(batsField)
        view.backgroundColor = .systemBackground
        
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        
        imageView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.width, height: view.height * 1.75)
        imageView.frame = CGRect(x: view.width/3, y: scrollView.top + 50, width: view.width/3, height: view.width/3)
        imageView.layer.cornerRadius = imageView.width/2
        
        firstNameField.frame = CGRect(x: 20,
                                     y: imageView.bottom + 10,
                                     width: view.width - 40,
                                     height: 52)
        lastNameField.frame = CGRect(x: 20,
                                     y: firstNameField.bottom + 10,
                                     width: view.width - 40,
                                     height: 52)
//        stateField.frame = CGRect(x: 20,
//                                     y: lastNameField.bottom + 10,
//                                     width: view.width - 40,
//                                     height: 52)
//        highSchoolField.frame = CGRect(x: 20,
//                                  y: stateField.bottom + 10,
//                                  width: view.width - 40,
//                                  height: 52)
//        weightField.frame = CGRect(x: 20,
//                                  y: highSchoolField.bottom + 10,
//                                  width: view.width - 40,
//                                  height: 52)
//        heightfeetField.frame = CGRect(x: 20,
//                                  y: weightField.bottom + 10,
//                                  width: view.width - 40,
//                                  height: 52)
//        heightInchesField.frame = CGRect(x: 20,
//                                  y: heightfeetField.bottom + 10,
//                                  width: view.width - 40,
//                                  height: 52)
//        armField.frame = CGRect(x: 20,
//                                  y: heightInchesField.bottom + 10,
//                                  width: view.width - 40,
//                                  height: 52)
//        batsField.frame = CGRect(x: 20,
//                                  y: armField.bottom + 10,
//                                  width: view.width - 40,
//                                  height: 52)
//        gradYearField.frame = CGRect(x: 20,
//                                  y: batsField.bottom + 10,
//                                  width: view.width - 40,
//                                  height: 52)
//
        usernameField.frame = CGRect(x: 20,
                                     y: lastNameField.bottom + 10,
                                     width: view.width - 40,
                                     height: 52)
        emailField.frame = CGRect(x: 20,
                                  y: usernameField.bottom + 10,
                                  width: view.width - 40,
                                  height: 52)
        passwordField.frame = CGRect(x: 20,
                                     y: emailField.bottom + 10,
                                     width: view.width - 40,
                                     height: 52)
//        picker.frame = CGRect(x: 20,
//                              y: passwordField.bottom + 10,
//                              width: view.width - 40,
//                              height: 100)
        registerButton.frame = CGRect(x: 20,
                                      y: passwordField.bottom + 10,
                                      width: view.width - 40,
                                      height: 52)
    }
    
    /// Handles a general tap on the view
    @objc private func didTap() {
        view.endEditing(true)
    }
    
    /// Handles a profile image button
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        } ) )
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    /// Presents the camera to take a photo
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    /// Presents the photo library to select a photo
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @objc func didTapRegisterButton() {
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        usernameField.resignFirstResponder()
        
        guard let email = emailField.text, !email.isEmpty,
              let firstname = firstNameField.text, !firstname.isEmpty,
              let lastname = lastNameField.text, !lastname.isEmpty,
//              let state = stateField.text, !state.isEmpty,
//              let highschool = highSchoolField.text, !highschool.isEmpty,
//              let arm = armField.text, !arm.isEmpty,
//              let bats = batsField.text, !bats.isEmpty,
//              let gradYear = gradYearField.text, !gradYear.isEmpty,
//              let weight = weightField.text, !weight.isEmpty,
//              let heightInches = heightInchesField.text, !heightInches.isEmpty,
//              let heightFeet = heightfeetField.text, !heightFeet.isEmpty,
              let password = passwordField.text, !password.isEmpty, password.count >= 8,
              let username = usernameField.text, !username.isEmpty else {
            return
        }
        
        let user = RHUser(username: username,
                          firstName: firstname,
                          lastName: lastname,
                          emailAddress: email,
                          positions: ["RHP", "OF", "1B"],
                          highShcool: "N/A",
                          state: "N/A",
                          gradYear: 0,
                          heightFeet: 0,
                          heightInches: 0,
                          weight: 0,
                          arm: "N/A",
                          bats: "N/A",
                         
//                          highShcool: highschool,
//                          state: state,
//                          gradYear: Int(gradYear),
//                          heightFeet: Int(heightFeet),
//                          heightInches: Int(heightInches),
//                          weight: Int(weight),
//                          arm: arm,
//                          bats: bats,
                          profilePicUrl: "N/A")
        
        AuthManager.shared.registerNewUser(username: username, email: email, password: password, user: user) { [weak self] registered in
            if registered {
                // Good to go
                guard let data = self?.imageView.image?.pngData() else {
                    return
                }
                
                let fileName = DatabaseManager.safeEmail(emailAddress: email)
                    
                StorageManager.shared.uploadProfilePic(with: data, filename: fileName, completion: { [weak self] result in
                    switch result {
                    case .success(let urlString):
                        DatabaseManager.shared.setProfilePic(with: email, url: urlString)
                    case .failure(let error):
                        print(error)
                    }
                    
                    self?.dismiss(animated: true, completion: nil)
                    
                    UserDefaults.standard.setValue(email, forKey: "email")
                    UserDefaults.standard.setValue(user.username, forKey: "username")
                    UserDefaults.standard.setValue("\(user.firstName) \(user.lastName)", forKey: "name")
                    UserDefaults.standard.setValue("Yes", forKey: "isLoggedIn")
                    
                })
            }
            else {
                // Failed
            }
        }
    }
    
    @objc private func didTapBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            didTapRegisterButton()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resignFirstResponder()
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        imageView.image = selectedImage
    }
}

extension RegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        positionData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return positionData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(positionData[row])
    }
}
