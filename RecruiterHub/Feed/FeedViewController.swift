//
//  FeedViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/30/21.
//

import UIKit
import AVFoundation

class FeedViewController: UIViewController {

    private var posts: [[String: String]] = []
    
    private var ultimatePosts: [FeedPost] = []
    
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
        
            
        })
        
        DatabaseManager.shared.newGetFeedPosts( completion: { [weak self] feedPosts in
            guard let feedPosts = feedPosts else {
                return
            }
            print(feedPosts)
            self?.ultimatePosts = feedPosts
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
        
        if indexPath.row % 4 == 0 {
            let model = posts[posts.count - (indexPath.row/4) - 1]
            
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
        else if indexPath.row % 4 == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! FeedTableViewCell
            tableView.deselectRow(at: indexPath, animated: false)
            cell.play()
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count * 4

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = posts[posts.count - (indexPath.row / 4) - 1]
        guard let urlString = model["url"] else {
            print("Failed to get url")
            return UITableViewCell()
        }
        
//        guard let url = URL(string: urlString) as URL? else {
//            return UITableViewCell()
//        }
        
        guard let email = model["email"] else {
            return UITableViewCell()
        }
        if indexPath.row % 4 == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedActionsCell.identifier, for: indexPath) as! FeedActionsCell
            cell.delegate = self
            return cell
        }
        else if indexPath.row % 4 == 0 {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedHeaderCell.identifier, for: indexPath) as! FeedHeaderCell
            let temp = ultimatePosts[posts.count - (indexPath.row / 4) - 1]
            
            cell.configure( email: temp.email)
            cell.delegate = self

            return cell
        }
        else if indexPath.row % 4 == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostInfoCell.identifier, for: indexPath) as! FeedPostInfoCell
            cell.configure(email: email, url: urlString)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.identifier, for: indexPath) as! FeedTableViewCell
            
            
            let temp = ultimatePosts[posts.count - (indexPath.row / 4) - 1]
            cell.configure(url: temp.url)
            cell.delegate = self
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
            return view.height * 3.0 / 4.0
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

public struct FeedPost {
    var email: String
    let url: AVPlayer
    let image: String
}
