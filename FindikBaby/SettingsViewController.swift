//
//  SettingsViewController.swift
//  FindikBabyApp
//
//  Created by Rüstem Ali Niyaz on 2.06.2024.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIComponents()
    }
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitle("Oturumu ve Uygulamayı Kapat", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = button.titleLabel?.font.withSize(20)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.lineBreakMode = .byClipping
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
        return button
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Bu uygulama FındıkBaby® firmasına özel tasarlanmıştır. Uygulama giriş bilgileri firma yetkilisi tarafından verilir. Sorularınız için Mahigül Hasan ile iletişime geçebilirsiniz."
        label.numberOfLines = 0
        return label
        
    }()
    
    
    @objc func logoutAction() {
        do {
            try Auth.auth().signOut()
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
            DispatchQueue.main.async {
                UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = LoginViewController()
                UIApplication.shared.windows.first { $0.isKeyWindow }?.makeKeyAndVisible()
                exit(0)
            }
            
        } catch {
            print("Sign Out is not working as expected")
        }
    }

    
    
    private func setupUIComponents() {
        view.backgroundColor = .systemBackground
        view.addSubview(logoutButton)
        view.addSubview(infoLabel)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
       
        
        infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        infoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        infoLabel.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -50).isActive = true
    }

}
