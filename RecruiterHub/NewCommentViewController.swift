//
//  NewCommentViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/28/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class NewCommentViewController: UIViewController {

    private let email: String
    
    private let url: String
    
    private var comments: [[String:String]]?
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = "New Comment..."
        textView.textColor = .lightGray
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.label.cgColor
        textView.layer.cornerRadius = 10
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainer.lineBreakMode = .byWordWrapping
        
        textView.textContainer.heightTracksTextView = true
        textView.returnKeyType = .send
        return textView
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(CommentsCell.self, forCellReuseIdentifier: CommentsCell.identifier)
        return table
    }()
    
    init(email: String, url: String) {
        self.email = email
        self.url = url
        
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            
        self.tabBarController?.tabBar.isHidden = true
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tapgesture)
        view.addSubview(tableView)
        view.addSubview(textView)
        tableView.delegate = self
        tableView.dataSource = self
        textView.delegate = self
    }
    
    @objc private func didTap() {
        textView.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0, y:  view.safeAreaInsets.top , width: view.width , height: view.height - 100)
        textView.frame = CGRect( x: 10, y: view.bottom - 100, width: view.width - 20 , height: 100)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if  notification.name == UIResponder.keyboardWillShowNotification {
                if view.frame.origin.y == 0 {
                    
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    private func fetchComments() {
        
        guard let email = email as String? else {
            return
        }
        
        DatabaseManager.shared.getAllUserPosts(with: email, completion: { [weak self]
            posts in
            guard let posts = posts else {
                return
            }
            
            var index = 0
            for post in posts {
                guard let postUrl = post["url"] as? String else {
                    return
                }
                
                if postUrl == self?.url {
                    print("Found url")
                    break
                }
                else {
                    index += 1
                }
            }
            
            DatabaseManager.shared.getComments(with: email, index: index, completion: { [weak self] comments in
                guard let comments = comments else {
                    return
                }
                
                self?.comments = comments
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
        })
    }
}

extension NewCommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let comments = comments else {
            return 0
        }
        
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let comments = comments else {
            return UITableViewCell()
        }
        
        let model = comments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentsCell.identifier, for: indexPath) as! CommentsCell
        
        guard let email = model["email"] else {
            return UITableViewCell()
        }
        
        guard let comment = model["comment"] else {
            return UITableViewCell()
        }
        
        cell.configure(email: email, comment: comment)
        return cell
    }
}

extension NewCommentViewController: UITextViewDelegate, UITextInputDelegate {
    func selectionWillChange(_ textInput: UITextInput?) {
        
    }
    
    func selectionDidChange(_ textInput: UITextInput?) {
        
    }
    
    func textWillChange(_ textInput: UITextInput?) {
        
    }
    
    func textDidChange(_ textInput: UITextInput?) {
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "New Comment..."
            textView.textColor = UIColor.lightGray
        }
        textView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if(text == "\n") {
                textView.resignFirstResponder()

                guard let newComment = textView.text else {
                    return false
                }

                guard let email = email as String? else {
                    return false
                }
                
                guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                    return false
                }

                let newElement = [
                    "email": currentEmail,
                    "comment": newComment
                ]

                comments?.append(newElement)

                tableView.reloadData()

                textView.text = "New Comment..."
                textView.textColor = .lightGray

                DatabaseManager.shared.getAllUserPosts(with: email, completion: { [weak self]
                    posts in
                    guard let posts = posts else {
                        return
                    }
                    
                    var index = 0
                    for post in posts {
                        guard let postUrl = post["url"] as? String else {
                            return
                        }
                        
                        if postUrl == self?.url {
                            print("Found url")
                            break
                        }
                        else {
                            index += 1
                        }
                    }
                    
                    DatabaseManager.shared.newComment(email: email, commenterEmail: currentEmail, comment: newComment, index: index )
                })
                return false
            }
            return true
        }
}


