//
//  ContactInformationViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/15/21.
//

import UIKit

class ContactInformationViewController: UIViewController {

    private let user: RHUser
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.layer.borderWidth = 1
        label.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.layer.cornerRadius = 10.0
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "Phone:    612-558-0124"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email:    Ryanhelgeson14@gmail.com"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient")!)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(phoneLabel)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameLabel.frame = CGRect(x: 20,
                                 y: 15,
                                 width: view.width - 40,
                                 height: 50)
        nameLabel.textAlignment = .center
        phoneLabel.frame = CGRect(x: 20,
                                  y: nameLabel.bottom + 20,
                                 width: view.width - 40,
                                 height: 20)
        phoneLabel.textAlignment = .left
        emailLabel.frame = CGRect(x: 20,
                                  y: phoneLabel.bottom + 20,
                                 width: view.width - 40,
                                 height: 20)
        emailLabel.textAlignment = .left
    }
    
    init(user: RHUser) {
        self.user = user
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
