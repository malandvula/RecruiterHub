//
//  NewPostViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/19/21.
//

import UIKit
import AVFoundation
import AVKit

class NewPostViewController: UIViewController {

    private let testingButton: UIButton = {
        let button = UIButton()
        button.setTitle("New Video", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4.0
        button.backgroundColor = .systemGreen
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testingButton.addTarget(self, action: #selector(didTapTest), for: .touchUpInside)
        
        view.addSubview(testingButton)
        
        // Adding Navigation title
        title = "Post"
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        testingButton.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 10, width: view.width - 40, height: 52)
    }
    
    @objc private func didTapTest() {
        
        let actionSheet = UIAlertController(title: "Attach Video", message: "Where would you like to attach a photo from?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {  _ in
            
        }))
        
        present(actionSheet, animated: true)
    }
}

extension NewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print("Attempt video upload")

        if let videoUrl = info[.mediaURL] as? URL {
            guard let fileName = createVideoId() as String? else {
                return
            }
            var video:Data
            do {
                video = try Data(contentsOf: videoUrl)
            }
            catch {
                return
            }
            
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }
            
            let vc = AddCaptionViewController(email: email, data: video, filename: fileName)
            navigationController?.pushViewController(vc, animated: false)
//            StorageManager.shared.uploadVideo(with: video, email: email, filename: fileName, completion: { result in
//
//                switch result {
//                case .success(let urlString):
//                    guard var email = UserDefaults.standard.value(forKey: "email") as! String? else {
//                        return
//                    }
//                    email = email.replacingOccurrences(of: "@", with: "-").replacingOccurrences(of: ".", with: "-")
//                    DatabaseManager.shared.insertNewPost(with: email, url: urlString)
//                case .failure(let error):
//                    print(error)
//                }
//            })
        }
    }
    
    private func createVideoId() -> String? {
        // Date, other UserEmail, senderEmail, RandomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(safeCurrentEmail)_\(dateString)"
        print("Created message id: \(newIdentifier)")
        return newIdentifier
    }
}
 
