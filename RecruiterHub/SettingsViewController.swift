//
//  SettingsViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/26/21.
//

import SafariServices
import UIKit

struct SettingCellModel {
    let title:String
    let handler:(() -> Void)
}

class SettingsViewController: UIViewController {

    private let table:UITableView = {
        let tableView = UITableView (frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var data = [[SettingCellModel]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        view.backgroundColor = .systemBackground
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    private func configureModels() {
        data.append([
            SettingCellModel(title: "Edit Profile") { [weak self] in
                self?.didTapEditProfile()
            },
            SettingCellModel(title: "Invite Friends") { [weak self] in
                self?.didTapInviteFriends()
            },
            SettingCellModel(title: "Save Original Posts") { [weak self] in
                self?.didTapSaveOriginalPosts()
            }
        ])

        data.append([
            SettingCellModel(title: "Terms of Service") { [weak self] in
                self?.openURL(type: .terms)
            },
            SettingCellModel(title: "Privacy Policy") { [weak self] in
                self?.openURL(type: .privacy)
            },
            SettingCellModel(title: "Help / Feedback") { [weak self] in
                self?.openURL(type: .help)
            }
        ])
        
        data.append([
            SettingCellModel(title: "Log Out") { [weak self] in
                self?.didTapLogOut()
            }
        ])
    }
    
    private func didTapEditProfile() {
        let vc = UIViewController()
        vc.title = "Edite Profile"
        vc.view.backgroundColor = .blue
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func didTapInviteFriends() {
        
    }
    
    private func didTapSaveOriginalPosts() {
        
    }
    
    enum SettingsURLType {
        case terms, privacy, help
    }
    
    private func openURL(type: SettingsURLType) {
        let urlString: String
        switch type {
            case .terms:
                urlString = "https://www.instagram.com/about/legal/terms/before-january-19-2013/"
                break
            case .privacy:
                urlString = "https://help.instagram.com/519522125107875"
                break
            case .help:
                urlString = "https://help.instagram.com/"
                break
        }
        guard let url = URL(string: urlString) else {
            return
        }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)

    }

    
    private func didTapLogOut() {
        let actionSheet = UIAlertController(title: "Log Out",
                                            message: "Are you sure you want to log out?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            AuthManager.shared.logout( completion: { success in
                DispatchQueue.main.async {
                    if success {
                        // present log in
                        let loginVc = LoginViewController()
                        loginVc.modalPresentationStyle = .fullScreen
                        self.present(loginVc, animated: true) {
                            self.navigationController?.popToRootViewController(animated: false)
                            self.tabBarController?.selectedIndex = 0
                        }
                    }
                    else {
                        // Error Occurred
                        fatalError("Could not log out user")
                    }
                }
                
            })
        }))
        
        actionSheet.popoverPresentationController?.sourceView = table
        actionSheet.popoverPresentationController?.sourceRect = table.bounds
        
        present(actionSheet, animated: true, completion: nil)

    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        guard section == 1 else {
//            return nil
//        }
//        return "Private Information"
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.section][indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.section][indexPath.row].handler()
    }
    
}
