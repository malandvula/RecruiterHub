//
//  OtherUserViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/26/21.
//

import UIKit
import SwiftUI
import FirebaseAuth

class OtherUserViewController: UIViewController {

    private var collectionView: UICollectionView?
    
    private var user: RHUser
    
    private var posts: [[String:String]]?
    
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
    
    init(user: RHUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .done, target: self, action: #selector(didTapBack))
        
        collectionView?.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        
        collectionView?.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.identifier)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        guard let collectionView = collectionView else {
            return
        }
        view.addSubview(collectionView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
        fetchPosts()
    }
    
    private func fetchPosts() {
        
        DatabaseManager.shared.getAllUserPosts(with: user.emailAddress.safeDatabaseKey(), completion: { [weak self] fetchedPosts in
            self?.posts = fetchedPosts
            
            DispatchQueue.main.async {
                self?.collectionView!.reloadData()
            }
        })
    }
    
    @objc private func didTapBack() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension OtherUserViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let posts = posts else {
            return
        }
        guard let url = URL(string: posts[indexPath.row]["url"]!) as URL? else {
            return
        }
        let post = Post(title: "Post", url: url)
        
        print("Selected Item at \(indexPath.row)")
        let vc = ViewPostViewController(post: post)
        let navVC = UINavigationController(rootViewController: vc)
        
        vc.title = "Post"
        navVC.modalPresentationStyle = .fullScreen
        vc.navigationItem.largeTitleDisplayMode = .never
        
        present(navVC, animated: true)
    }
}

extension OtherUserViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let posts = posts else {
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
        cell.configure(with: URL(string: urlString)!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeader.identifier, for: indexPath) as! ProfileHeader
        profileHeader.delegate = self
        profileHeader.configure(user: user)
        return profileHeader
    }
    
}

extension OtherUserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: view.height/2)
    }
    
    
}

extension OtherUserViewController: ProfileHeaderDelegate {
    func didTapContactInfo(_ header: ProfileHeader) {
        let vc = ContactInformationViewController()
        vc.title = "Contact Information"
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
    
    func didTapReload(_ header: ProfileHeader) {
        fetchPosts()
    }
}

