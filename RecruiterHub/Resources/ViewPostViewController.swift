//
//  ViewPostViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/22/21.
//

import UIKit
import AVFoundation

class ViewPostViewController: UIViewController {

    private var post: Post
    private let user: RHUser
    
    private var comments: [[String:String]]?
    
    // Like button
    private let likeButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "heart", withConfiguration: config)
        button.tintColor = .label
        button.setImage(image, for: .normal)
        return button
    }()
    
    // Comment button
    private let commentButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "message", withConfiguration: config)
        button.tintColor = .label
        button.setImage(image, for: .normal)
        return button
    }()
    
    // Likes label
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        tableView.register(CommentsCell.self, forCellReuseIdentifier: CommentsCell.identifier)
        return tableView
    }()
    
    // Player
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    
    // Occurs then the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Add like button function call
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)

        let asset = AVAsset(url: post.url)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        // AVPlayer Layer Configuration
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        
        // Add subviews and layers
        view.layer.addSublayer(playerLayer)
        view.addSubview(likeButton)
        view.addSubview(commentButton)
        view.addSubview(likesLabel)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Configure likes label
        likesLabel.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLikesLabel))
        likesLabel.addGestureRecognizer(gesture)
        configureLikesLabel()
        
        // Fetch Comments
        fetchComments()
        
        // Add player and start playing
        playerLayer.player = player
        player?.play()
    }
    
    // Design layout
    override func viewDidLayoutSubviews() {
        
        // Place player layer
        playerLayer.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height / 2)
        
        // Place like button
        likeButton.frame = CGRect(x: 10,
                                  y: view.safeAreaInsets.top + playerLayer.frame.height + 5,
                                  width: 40,
                                  height: 40)
        // Place comment button
        commentButton.frame = CGRect(x: likeButton.right + 10,
                                  y: view.safeAreaInsets.top + playerLayer.frame.height + 5,
                                  width: 40,
                                  height: 40)
        
        // Place likes label
        likesLabel.frame = CGRect(x: 10, y: likeButton.bottom + 10, width: view.width - 20, height: 20)
        tableView.frame = CGRect(x: 0, y: likesLabel.bottom + 10, width: view.width , height: view.height - likesLabel.bottom - 10)
    }
    
    /// ViewPostViewController initializer, sets the post, user, and postnumber
    init(post: Post, user: RHUser) {
        self.post = post
        self.user = user
        super.init(nibName: nil, bundle: nil)
        self.title = title
        
    }
    
    // Required init function
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fetchComments() {
        
        guard let email = user.safeEmail as String? else {
            return
        }
        
        DatabaseManager.shared.getAllUserPosts(with: email, completion: { [weak self]
            posts in
            guard let posts = posts else {
                return
            }

            guard let url = self?.post.url.absoluteString else {
                return
            }
            
            let index = DatabaseManager.findPost(posts: posts, url: url)
            
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
    
    // Function that is called when the like button is tapped
    @objc private func didTapLike() {
        print("Tapped Like")
        
        // Cast the user info to Strings
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentUsername = UserDefaults.standard.value(forKey: "username") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String
        else {
            print("Failed to get User Defaults")
            return
        }
        
        // Create Post Like
        let postLike = PostLike(username: currentUsername, email: currentEmail.safeDatabaseKey(), name: currentName)
        
        // Update the like status
        DatabaseManager.shared.like(with: user.emailAddress.safeDatabaseKey(), likerInfo: postLike, postNumber: post.number, completion: { [weak self] in
            
            guard let postEmail = self?.user.safeEmail else {
                print("Failed to get User Defaults")
                return
            }
            
            DatabaseManager.shared.getAllUserPosts(with: postEmail, completion: {
                [weak self] posts in
                guard let posts = posts else {
                    return
                }
                
                guard let url = self?.post.url.absoluteString else {
                    return
                }
                
                let index = DatabaseManager.findPost(posts: posts, url: url)
                
                if posts.count <= index {
                    print("Post doesnt exist")
                    return
                }
                
                DatabaseManager.shared.getLikes(with: postEmail, index: index, completion: {
                    [weak self] likes in
                    if let likes = likes {
                        DispatchQueue.main.async {
                            self?.likesLabel.text = "\(likes.count) likes"
                        }
                    }
                })
            })
        })
        
        toggleLike()
    }
    
    private func toggleLike() {
        if likeButton.tintColor.accessibilityName == UIColor.label.accessibilityName {
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
            let image = UIImage(systemName: "heart.fill", withConfiguration: config)
            self.likeButton.setImage(image, for: .normal)
            self.likeButton.tintColor = .red
        }
        else {
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
            let image = UIImage(systemName: "heart", withConfiguration: config)
            self.likeButton.setImage(image, for: .normal)
            self.likeButton.tintColor = .label
        }
    }
    
    // Function that is called when the like button is tapped
    @objc private func didTapComment() {
        let newCommentVC = NewCommentViewController(email: user.safeEmail, url: post.url.absoluteString)
        newCommentVC.title = "Add Comment"
        navigationController?.pushViewController(newCommentVC, animated: true)
    }
    
    
    // Configure the like button
    private func configureLikesLabel() {
        let numberOfLikes = post.likes.count
        likesLabel.text = "\(numberOfLikes) likes"

        
        DatabaseManager.shared.getAllUserPosts(with: user.safeEmail, completion: {
            [weak self] posts in
            guard let posts = posts else {
                return
            }
            
            guard let url = self?.post.url.absoluteString else {
                return
            }
            
            let index = DatabaseManager.findPost(posts: posts, url: url)
            
            if posts.count <= index {
                print("Post doesnt exist")
                return
            }
            
            guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String
            else {
                print("Failed to get User Defaults")
                return
            }
            
            guard let postEmail = self?.user.safeEmail else {
                print("Failed to get User Defaults")
                return
            }
            
            DatabaseManager.shared.getLikes(with: postEmail, index: index, completion: {
                [weak self] likes in
                guard let likes = likes else {
                    return
                }
                
                for like in likes {
                    if like["email"] == currentEmail {
                        self?.toggleLike()
                    }
                }
            })
        })
    }
    
    // Callback for like label interaction
    @objc private func didTapLikesLabel() {
        var likes: [[String:String]] = []
        for like in post.likes {
            let newElement = ["email":like.email]
            likes.append(newElement)
        }
        let vc = ListsViewController(data: likes)
        vc.title = "Likes"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewPostViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: view.width - 20 , height: 10))
        label.text = comments![indexPath.row]["comment"]!
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label.height + 10
    }
}

// Structure that holds all information related to a post
struct Post {
    let likes: [PostLike]
    let title: String
    let url: URL
    let number: Int
}

public struct PostLike: Equatable {
    let username: String
    let email: String
    let name: String
}
