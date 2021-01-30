//
//  NewConversationViewController.swift
//  ChatApp
//
//  Created by Ryan Helgeson on 10/14/20.
//  Copyright © 2020 Ryan Helgeson. All rights reserved.
//

import UIKit

class SearchUserViewController: UIViewController {

    public var completion: ((SearchResult) -> (Void))?
    
    private var users = [[String: String]]()
    
    private var results = [SearchResult]()
    
    private var hasFetched = false
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Searching for Users.. "
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(SearchUsersTableViewCell.self, forCellReuseIdentifier: SearchUsersTableViewCell.identifier)
       
        return table
    }()
    
//    private let noResultsLabel: UILabel = {
//        let label = UILabel()
//        label.isHidden = true
//        label.text = "No results.. "
//        label.textAlignment = .center
//        label.textColor = .green
//        label.font = .systemFont(ofSize: 21, weight: .medium)
//        return label
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self

        view.addSubview(searchBar)
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: 40)
        
        tableView.frame = CGRect(x: 0,
                                 y: searchBar.bottom,
                                 width: view.width,
                                 height: view.height - searchBar.height)
//        noResultsLabel.frame = CGRect(x: view.width / 4, y: (view.height-200) / 2, width: view.width / 2, height: 200)
    }
    
}

extension SearchUserViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        
        searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        //Check if array has firebase result
        if hasFetched {
            //if it does: filter
            filterUsers(with: query)
        }
        else {
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let userCollection):
                    self?.hasFetched = true
                    self?.users = userCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            })
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        results = []
        searchBar.text = ""
        searchBar.resignFirstResponder()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func filterUsers(with term: String) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let results: [SearchResult] = users.filter( {
            guard let email = $0["email"], email != safeEmail else {
                return false
            }
            
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.contains(term.lowercased())
        }).compactMap({
            guard let email = $0["email"], let name = $0["name"] else {
                return nil
            }
            
            return SearchResult(name: name, email: email)
        })
        self.results = results
        
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
//            noResultsLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
//            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

struct SearchResult {
    let name: String
    let email: String
}

extension SearchUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchUsersTableViewCell.identifier, for: indexPath) as! SearchUsersTableViewCell
        print(model)
        cell.nameLabel.text = model.name
        cell.usernameLabel.text = model.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Start Conversation
        let targetUserData  = results[indexPath.row]
        DatabaseManager.shared.getDataForUser(user: targetUserData.email.safeDatabaseKey(), completion: { [weak self] snapshot in
            
            guard let snapshot = snapshot else {
                return
            }
            let vc = OtherUserViewController(user: snapshot)
            vc.title = targetUserData.email
            self?.navigationController?.pushViewController(vc, animated: false)
        })

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
        
    }
}

