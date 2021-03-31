//
//  GameLogViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/26/21.
//

import UIKit

class GameLogViewController: UIViewController {

    private let user: RHUser
    
    private var showPitcherLog = true
    
    private var pitcherGameLogs: [PitcherGameLog] = []
    
    private var batterGameLogs: [BatterGameLog] = []
    
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
    
    private let pitcherTableView: UITableView = {
        let table = UITableView()
        table.allowsSelection = false
        table.register(PitcherGameLogTableViewCell.self, forCellReuseIdentifier: PitcherGameLogTableViewCell.identifier)
        table.separatorStyle = .singleLine
        return table
    }()
    
    private let batterTableView: UITableView = {
        let table = UITableView()
        table.allowsSelection = false
        table.register(BatterGameLogTableViewCell.self, forCellReuseIdentifier: BatterGameLogTableViewCell.identifier)
        table.separatorStyle = .singleLine
        table.isHidden = true
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
        scrollView.addSubview(pitcherTableView)
        pitcherTableView.delegate = self
        pitcherTableView.dataSource = self
        pitcherTableView.reloadData()
        scrollView.addSubview(batterTableView)
        batterTableView.delegate = self
        batterTableView.dataSource = self
        batterTableView.reloadData()
        // Do any additional setup after loading the view.
        
        if user.safeEmail == UserDefaults.standard.value(forKey: "email") as? String {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        }
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        
        scrollView.contentSize = CGSize(width: view.width + 80, height: view.safeAreaInsets.bottom - view.safeAreaInsets.top)
        pitcherTableView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DatabaseManager.shared.getPitcherGameLogsForUser(user: user.safeEmail, completion: {
            [weak self] gameLogs in
            
            guard let gameLogs = gameLogs else {
                return
            }
            
            DispatchQueue.main.async {
                self?.pitcherGameLogs = gameLogs
                self?.pitcherTableView.reloadData()
            }
        })

        DatabaseManager.shared.getBatterGameLogsForUser(user: user.safeEmail, completion: {
            [weak self] gameLogs in
            
            guard let gameLogs = gameLogs else {
                return
            }
            
            DispatchQueue.main.async {
                self?.batterGameLogs = gameLogs
                self?.batterTableView.reloadData()
            }
        })
    }
    
    @objc private func didTapAddButton() {
        var vc: AddGameLogViewController
        if showPitcherLog {
            vc = AddGameLogViewController(type: .pitching)
        }
        else {
            vc = AddGameLogViewController(type: .batting)
        }
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension GameLogViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: 50))
        headerView.backgroundColor = .secondarySystemBackground
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: headerView.width / 2, height: headerView.height))
        button.setTitle("Batting", for: .normal)
        button.addTarget(self, action: #selector(didTapBatting), for: .touchUpInside)
        let pitchingButton = UIButton(frame: CGRect(x: headerView.width / 2, y: 0, width: headerView.width / 2, height: headerView.height))
        pitchingButton.setTitle("Pitching", for: .normal)
        pitchingButton.addTarget(self, action: #selector(didTapPitching), for: .touchUpInside)
        headerView.addSubview(button)
        headerView.addSubview(pitchingButton)
        return headerView
    }
    
    @objc private func didTapBatting() {
        pitcherTableView.isHidden = true
        batterTableView.isHidden = false
        showPitcherLog = false
        scrollView.contentSize = CGSize(width: view.width + 240, height: view.safeAreaInsets.bottom - view.safeAreaInsets.top)
        batterTableView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.height)
    }
    
    @objc private func didTapPitching() {
        pitcherTableView.isHidden = false
        batterTableView.isHidden = true
        showPitcherLog = true
        scrollView.contentSize = CGSize(width: view.width + 80, height: view.safeAreaInsets.bottom - view.safeAreaInsets.top)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == pitcherTableView {
            return pitcherGameLogs.count + 1
        }
        return batterGameLogs.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == pitcherTableView {
            let cell = pitcherTableView.dequeueReusableCell(withIdentifier: PitcherGameLogTableViewCell.identifier, for: indexPath) as! PitcherGameLogTableViewCell
            
            if indexPath.row == 0 {
                return cell
            }
            
            let model = pitcherGameLogs[indexPath.row - 1]
            
            cell.configure(game: model)
            return cell
        }
        else {
            let cell = batterTableView.dequeueReusableCell(withIdentifier: BatterGameLogTableViewCell.identifier, for: indexPath) as! BatterGameLogTableViewCell
            
            if indexPath.row == 0 {
                return cell
            }
            
            let model = batterGameLogs[indexPath.row - 1]
            
            cell.configure(game: model)
            return cell
        }
    }
}
