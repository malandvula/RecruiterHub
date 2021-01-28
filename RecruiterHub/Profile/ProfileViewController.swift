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
    
    private var user: RHUser = RHUser(username: "username",
                                      firstName: "firstname",
                                      lastName: "lastname",
                                      emailAddress: "emailaddress",
                                      positions: [],
                                      highShcool: nil,
                                      state: nil,
                                      gradYear: nil,
                                      heightFeet: nil,
                                      heightInches: nil,
                                      weight: nil,
                                      arm: nil,
                                      bats: nil)
    
    private var posts: [[String:Any]]?
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gradient")
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: nil)
    
        collectionView?.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        
        collectionView?.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.identifier)
        collectionView?.register(ProfileTopBar.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileTopBar.identifier)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        guard let collectionView = collectionView else {
            return
        }
        view.addSubview(collectionView)
        print("Fetching posts..")
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
    
    private func fetchPosts() {
        guard var email = UserDefaults.standard.value(forKey: "email") as! String? else {
            return
        }
        
        email = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllUserPosts(with: email, completion: { [weak self] fetchedPosts in
            self?.posts = fetchedPosts
            
            DispatchQueue.main.async {
                self?.collectionView!.reloadData()
            }
        })
    }
}

extension ProfileViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let posts = posts else {
            return
        }
        guard let url = URL(string: posts[indexPath.row]["url"]! as! String) as URL? else {
            return
        }
        guard let likes = posts[indexPath.row]["likes"] as? [String] else {
            return
        }
        
        let post = Post(likes: likes, title: "Post", url: url)
        
        let vc = ViewPostViewController(post: post, user: user, postNumber: indexPath.row)
        let navVC = UINavigationController(rootViewController: vc)
        
        vc.title = "Post"
        navVC.modalPresentationStyle = .fullScreen
        vc.navigationItem.largeTitleDisplayMode = .never
        
        present(navVC, animated: true)
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let posts = posts else {
            return 0
        }
        
        if section == 0 {
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
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        if indexPath.section == 0 {
            let topBar = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileTopBar.identifier, for: indexPath) as! ProfileTopBar
            topBar.delegate = self
            return topBar
        }
        
        let profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeader.identifier, for: indexPath) as! ProfileHeader
        profileHeader.delegate = self
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return UICollectionReusableView()
        }
        DatabaseManager.shared.getDataForUser(user: email.safeDatabaseKey(), completion: {
            result in
            guard let result = result else {
                return
            }
            
            profileHeader.configure(user: result )
        })
        return profileHeader
    }
    
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            return CGSize(width: view.width, height: 30)
        }
        return CGSize(width: view.width, height: view.height/2)
    }
    
    
}

extension ProfileViewController: ProfileHeaderDelegate {
    
    func didTapContactInfo(_ header: ProfileHeader) {
        let vc = ContactInformationViewController(user: user)
        vc.title = "Contact Information"
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
    func didTapReload(_ header: ProfileHeader) {
        fetchPosts()
    }
}

extension ProfileViewController: ProfileTopBarDelegate {
    func didTapSettingsButton(_ profileTopBar: ProfileTopBar) {
        
        let vc = SettingsViewController()
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = "Settings"
        vc.modalTransitionStyle = .crossDissolve
        navVC.modalPresentationStyle = .formSheet
        present(navVC, animated: true, completion: nil)
    }
    
    
}
