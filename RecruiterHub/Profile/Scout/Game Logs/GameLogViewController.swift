//
//  GameLogViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/26/21.
//

import UIKit

class GameLogViewController: UIViewController {

    private let user: RHUser
    
    private var gameLogs: [PitcherGameLog] = []
    
    private let opponentLabel: UILabel = {
        let label = UILabel()
        label.text = "Opponent"
        label.textColor = .label
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.textColor = .label
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.allowsSelection = false
        table.register(GameLogTableViewCell.self, forCellReuseIdentifier: GameLogTableViewCell.identifier)
        table.separatorStyle = .singleLine
        return table
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        return scrollView
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
        title = "Game Logs"
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        // Do any additional setup after loading the view.
        
        if user.safeEmail == UserDefaults.standard.value(forKey: "email") as? String {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        }
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        
        scrollView.contentSize = CGSize(width: view.width + 100, height: view.safeAreaInsets.bottom - view.safeAreaInsets.top)
        tableView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DatabaseManager.shared.getPitcherGameLogsForUser(user: user.safeEmail, completion: {
            [weak self] gameLogs in
            
            guard let gameLogs = gameLogs else {
                return
            }
            
            DispatchQueue.main.async {
                self?.gameLogs = gameLogs
                self?.tableView.reloadData()
            }
        })
    }
    
    @objc private func didTapAddButton() {
        let vc = AddGameLogViewController()
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension GameLogViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameLogs.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GameLogTableViewCell.identifier, for: indexPath) as! GameLogTableViewCell
        
        if indexPath.row == 0 {
            return cell
        }
        
        let model = gameLogs[indexPath.row - 1]
        
        cell.configure(game: model)
        return cell
    }
}
