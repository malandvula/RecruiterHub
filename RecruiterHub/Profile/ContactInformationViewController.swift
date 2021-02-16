//
//  ContactInformationViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/15/21.
//

import UIKit

public struct ContactInfoModel {
    let label: String
    let value: String
}

class ContactInformationViewController: UIViewController {

    private let user: RHUser
    
    var models: [ContactInfoModel] = []
    
    let tableView: UITableView = {
        let table = UITableView()
        table.layer.masksToBounds = true
        table.backgroundColor = .clear
        table.register(ContactInfoCell.self, forCellReuseIdentifier: ContactInfoCell.identifier)
        return table
    }()
//    let nameLabel: UILabel = {
//        let label = UILabel()
//        label.layer.borderWidth = 1
//        label.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
//        label.layer.cornerRadius = 10.0
//        label.font = .systemFont(ofSize: 40, weight: .bold)
//        label.numberOfLines = 1
//        return label
//    }()
//
//    let phoneLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Phone:    612-558-0124"
//        label.font = .systemFont(ofSize: 20, weight: .semibold)
//        label.numberOfLines = 1
//        return label
//    }()
//
//    let emailLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Email:    Ryanhelgeson14@gmail.com"
//        label.font = .systemFont(ofSize: 20, weight: .semibold)
//        label.numberOfLines = 1
//        return label
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient")!)
        configureModels()
        view.addSubview(tableView)
//        view.addSubview(nameLabel)
//        view.addSubview(emailLabel)
//        view.addSubview(phoneLabel)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
//        nameLabel.frame = CGRect(x: 20,
//                                 y: (navigationController?.navigationBar.bottom)! + 10,
//                                 width: view.width - 40,
//                                 height: 50)
//        nameLabel.textAlignment = .center
//        phoneLabel.frame = CGRect(x: 20,
//                                  y: nameLabel.bottom + 20,
//                                 width: view.width - 40,
//                                 height: 20)
//        phoneLabel.textAlignment = .left
//        emailLabel.frame = CGRect(x: 20,
//                                  y: phoneLabel.bottom + 20,
//                                 width: view.width - 40,
//                                 height: 20)
//        emailLabel.textAlignment = .left
    }
    
    init(user: RHUser) {
        self.user = user
//        nameLabel.text = "\(user.firstName) \(user.lastName)"
        super.init(nibName: nil, bundle: nil)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureModels() {
        // name, username, website, bio
        var model = ContactInfoModel(label: "Name", value: "\(user.firstName) \(user.lastName)")
        models.append(model)
        model = ContactInfoModel(label: "Username", value: "\(user.username)")
        models.append(model)
        model = ContactInfoModel(label: "Phone", value: "N/A")
        models.append(model)
        model = ContactInfoModel(label: "High School", value: "\(user.highShcool!)")
        models.append(model)
        model = ContactInfoModel(label: "State", value: "\(user.state!)")
        models.append(model)
        model = ContactInfoModel(label: "Height Feet", value: "\(user.heightFeet!)")
        models.append(model)
        model = ContactInfoModel(label: "Height Inches", value: "\(user.heightInches!)")
        models.append(model)
        model = ContactInfoModel(label: "Weight", value: "\(user.weight!)")
        models.append(model)
        model = ContactInfoModel(label: "Arm", value: "\(user.arm!)")
        models.append(model)
        model = ContactInfoModel(label: "Bats", value: "\(user.bats!)")
        models.append(model)
        model = ContactInfoModel(label: "GPA", value: "\(user.bats!)")
        models.append(model)
    }
}

extension ContactInformationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactInfoCell.identifier, for: indexPath) as! ContactInfoCell
        cell.configure(with: models[indexPath.row])
        return cell
    }
    
    
}
