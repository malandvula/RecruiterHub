//
//  FeedViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/30/21.
//

import UIKit

class FeedViewController: UIViewController {

    private var posts: [[String: String]] = []
    
    let tableView: UITableView = {
        let table = UITableView()
        table.allowsSelection = true
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let model = posts[posts.count - indexPath.row - 1]
        
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
            self?.navigationController?.pushViewController(vc, animated: false)

        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = posts[posts.count - indexPath.row - 1]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.identifier, for: indexPath) as! FeedTableViewCell
        
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

extension FeedViewController: FeedTableViewCellDelegate {
    func didTapUsername(_ feedTableViewCell: FeedTableViewCell, user: RHUser) {
        print("TappedUsername")
        let vc = OtherUserViewController(user: user)
        vc.title = "\(user.firstName) \(user.lastName)"
        navigationController?.pushViewController(vc, animated: false)
    }
    
    
}
