//
//  ProfileViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/14/21.
//

import UIKit
import SwiftUI
import FirebaseAuth

class ProfileViewController: UIViewController {

    private var collectionView: UICollectionView?
    
    private var user: RHUser = RHUser()
    
    private var posts: [[String:Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
        let size = (view.width - 4)/3
        layout.itemSize = CGSize(width: size, height: size)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEditButton))
    
        guard let collectionView = collectionView else {
            return
        }
        
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.identifier)
        
        collectionView.register(ProfileTabs.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileTabs.identifier)
        
        collectionView.register(ProfileConnections.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileConnections.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        print("Fetching posts..")
        navigationController?.navigationBar.barTintColor = .systemBackground
        tabBarController?.tabBar.barTintColor = .systemBackground
        fetchPosts()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNotAuthenticated()
    }
    
    func handleNotAuthenticated() {
        print("HandleAuthenticated")
        if Auth.auth().currentUser == nil {
            // Show Log In
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height - view.safeAreaInsets.top)
    }
    
    @objc private func didTapEditButton() {
        let vc = SettingsViewController(user: user)
        vc.title = "Settings"
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func fetchPosts() {
        
        guard let isLoggedIn = UserDefaults.standard.value(forKey: "isLoggedIn") as? String,
              isLoggedIn == "Yes" else {
            print("Is not logged in")
            return
        }
        print("Is logged in")
        guard var email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("failed")
            return
        }
        email = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllUserPosts(with: email, completion: { [weak self] fetchedPosts in
            self?.posts = fetchedPosts
            
            DatabaseManager.shared.getDataForUser(user: email.safeDatabaseKey(), completion: {
                [weak self] user in
                guard let user = user else {
                    return
                }
                self?.user = user
                
                
                self?.collectionView!.reloadData()
                
            })
        })
    }
}

extension ProfileViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("Selected Item")
        guard let posts = posts else {
            return
        }
        guard let url = URL(string: posts[indexPath.row]["url"]! as! String) as URL? else {
            return
        }
        var postLikes :[PostLike] = []
        if let likes = posts[indexPath.row]["likes"] as? [[String:String]] {
            for like in likes {
                let postLike = PostLike(username: like["username"]!, email: like["email"]!, name: like["name"]!)
                postLikes.append(postLike)
            }
        }
        else {
            postLikes = []
        }
        
        let post = Post(likes: postLikes, title: "Post", url: url, number: indexPath.row)
        
        let vc = ViewPostViewController(post: post, user: user)
        
        vc.title = "Post"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let posts = posts else {
            return 0
        }
        
        if section != 2 {
            return 0
        }
        
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let posts = posts else {
            return UICollectionViewCell()
        }
        let urlString = posts[indexPath.row]["thumbnail"]!
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell
        cell.configure(with: URL(string: urlString as! String)!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // Check that the kind is of section header
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        if indexPath.section == 1 {
            let profileTabs = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileTabs.identifier, for: indexPath) as! ProfileTabs
            profileTabs.delegate = self
            return profileTabs
        }
        
        if indexPath.section == 2 {
            let profileConnections = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileConnections.identifier, for: indexPath) as! ProfileConnections
            profileConnections.delegate = self
            return profileConnections
        }
        
        // Dequeue reusable view of type ProfileHeader
        let profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeader.identifier, for: indexPath) as! ProfileHeader
        profileHeader.delegate = self
        
        if let email = UserDefaults.standard.value(forKey: "email") as? String {
           
                DatabaseManager.shared.getDataForUser(user: email.safeDatabaseKey(), completion: {
                    result in
                    guard let result = result else {
                        return
                    }
                    
                    profileHeader.configure(user: result)
                })
        
        }
        return profileHeader
    }
    
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
       
        if section == 1 {
            return CGSize(width: view.width, height: 50)
        }
        
        if section == 2 {
            return CGSize(width: view.width, height: 70)
        }
        
        return CGSize(width: view.width, height: view.height/2)
    }
    
}

extension ProfileViewController: ProfileHeaderDelegate {
    func didTapFollowButton(_ header: ProfileHeader) {
        print("Tapped Follow")
        guard let email =  UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        DatabaseManager.shared.follow(email: user.emailAddress.safeDatabaseKey(), followerEmail: email.safeDatabaseKey())
    }
    
    func didTapReload(_ header: ProfileHeader) {
        print("Reload Tapped")
        fetchPosts()
    }
}

extension ProfileViewController: ProfileTabsDelegate {
    func didTapGridButtonTab() {
        print("Tapped the grid")
        let vc = ContactInformationViewController(user: user)
        vc.title = "Contact Information"
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func didTapTaggedButtonTab() {
        
    }
}

extension ProfileViewController: ProfileConnectionsDelegate {
    func didTapFollowingButton(_ profileConnections: ProfileConnections) {
        print("Did tap following")
        DatabaseManager.shared.getUserFollowing(email: user.emailAddress.safeDatabaseKey(), completion: { [weak self] followers in
            var data:[[String:String]] = []
            if let followers = followers {
                    data = followers
            }
            let vc = ListsViewController(data: data)
            vc.title = "Following"
            self?.navigationController?.pushViewController(vc, animated: false)
            return
        })
    }
    
    func didTapFollowersButton(_ profileConnections: ProfileConnections) {
        DatabaseManager.shared.getUserFollowers(email: user.emailAddress.safeDatabaseKey(), completion: { [weak self] followers in
            var data:[[String:String]] = []
            if let followers = followers {
                    data = followers
            }
            let vc = ListsViewController(data: data)
            vc.title = "Followers"
            self?.navigationController?.pushViewController(vc, animated: false)
            return
        })
    }
    
    func didTapConnectionsButton(_ profileConnections: ProfileConnections) {
        
    }
    
    
}
