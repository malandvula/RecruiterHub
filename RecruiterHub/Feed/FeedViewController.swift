//
//  FeedViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/30/21.
//

import UIKit

class FeedViewController: UIViewController {

    private var posts: [[String: String]] = []
    
    private let NUMBEROFCELLS = 4
    
    let tableView: UITableView = {
        let table = UITableView()
        table.allowsSelection = true
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FeedPostInfoCell.self, forCellReuseIdentifier: FeedPostInfoCell.identifier)
        
        tableView.register(FeedActionsCell.self, forCellReuseIdentifier: FeedActionsCell.identifier)
        
        tableView.register(FeedHeaderCell.self, forCellReuseIdentifier: FeedHeaderCell.identifier)
        
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.identifier)
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = view.height - 50
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        fetchPosts()
    }
    
    private func fetchPosts() {
        
        DatabaseManager.shared.getFeedPosts( completion: { [weak self] feedPosts in
            guard let feedPosts = feedPosts else {
                return
            }
            
            self?.posts = feedPosts
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        })
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = FeedHeaderView()
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.row % 3 == 0 {
            let model = posts[posts.count - (indexPath.row/3) - 1]
            
            guard let email = model["email"] else {
                return
            }
            
            DatabaseManager.shared.getDataForUser(user: email, completion: {
                [weak self] user in
                guard let user = user else {
                    return
                }
                
                let vc = OtherUserViewController(user: user)
                vc.title = "\(user.firstName) \(user.lastName)"
                self?.navigationController?.pushViewController(vc, animated: true)

            })
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count * 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        let model = posts[posts.count - (indexPath.row / 3) - 1]
        guard let urlString = model["url"] else {
            print("Failed to get url")
            return UITableViewCell()
        }
        
        guard let url = URL(string: urlString) as URL? else {
            return UITableViewCell()
        }
        
        guard let email = model["email"] else {
            return UITableViewCell()
        }
        if indexPath.row % 4 == 2 {
            print("Actions Cell")
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedActionsCell.identifier, for: indexPath) as! FeedActionsCell
            cell.delegate = self
            return cell
        }
        else if indexPath.row % 4 == 0 {
            print("Header Cell")
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedHeaderCell.identifier, for: indexPath) as! FeedHeaderCell
            DatabaseManager.shared.getDataForUser(user: email, completion: {
                user in
                guard let user = user else {
                    return
                }
                
                cell.configure( user: user)
                cell.delegate = self
            })
            return cell
        }
        else if indexPath.row % 4 == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostInfoCell.identifier, for: indexPath) as! FeedPostInfoCell
            return cell
            
        }
        else {
            print("Post Cell")
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.identifier, for: indexPath) as! FeedTableViewCell
            
            let post = Post(likes: [], title: "Post", url: url, number: indexPath.row )
            
            DatabaseManager.shared.getDataForUser(user: email, completion: {
                user in
                guard let user = user else {
                    return
                }
                
                cell.configure(post: post, user: user)
                cell.delegate = self
            })
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 4 == 3 {
            return 50
        }
        if indexPath.row % 4 == 2 {
            return 50
        }
        else if indexPath.row % 4 == 0 {
            return 50
        }
        else {
            return view.height - 50
        }
    }
}

extension FeedViewController: FeedTableViewCellDelegate {
    func didTapUsername(_ feedTableViewCell: FeedTableViewCell, user: RHUser) {
        print("TappedUsername")
        let vc = OtherUserViewController(user: user)
        vc.title = "\(user.firstName) \(user.lastName)"
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension FeedViewController: FeedHeaderCellDelegate {
    func didTapUsername(_ feedHeaderCell: FeedHeaderCell, user: RHUser) {
        print("TappedUsername")
        let vc = OtherUserViewController(user: user)
        vc.title = "\(user.firstName) \(user.lastName)"
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension FeedViewController: FeedActionsCellDelegate {
    func didTapLikeButton() {
        print("Tapped Like")
    }
    
    func didTapCommentButton() {
        
            print("Tapped comment")
    }
    
    func didTapSendButton() {
        
            print("Tapped Send")
    }
    
    
}