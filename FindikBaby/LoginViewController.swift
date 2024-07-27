

import UIKit
import FirebaseAuth


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIComponents()
        self.hideKeyboardWhenTappedAround()
        emailTextField.delegate = self
        passwordTextField.delegate = self

    }
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "logo.png")
        return imageView
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        textField.keyboardType = .emailAddress
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(white: 1, alpha:1).cgColor
        textField.attributedPlaceholder = NSAttributedString(string: "E-mail adresi giriniz", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        textField.textAlignment = .center
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        textField.isSecureTextEntry = true
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(white: 1, alpha:1).cgColor
        textField.attributedPlaceholder = NSAttributedString(string: "Parola giriniz", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        textField.textAlignment = .center
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitle("Giriş", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
        
    }()
    

    @objc func buttonAction(sender: UIButton!) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authData, error in
                if error != nil {
                    self.makeAlert(titleInput: "Hata", messageInput: "Sisteme giriş sırasında hata meydana geldi, bilgilerinizi kontrol ederek tekrar deneyiniz. Hata devam ederse yöneticinize danışınız.")
                } else {
                    self.navigationController?.pushViewController(TabBarController(), animated: true)
                }
            }
        } else {
            makeAlert(titleInput: "Hata", messageInput: "Kullanıcı Adı veya Parola eksik")
        }
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
    private func setupUIComponents() {
        view.backgroundColor = .cyan
        view.addSubview(logoImageView)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(registerButton)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height * 0.05),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9),
            logoImageView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.4),
            
            emailTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: view.frame.height * 0.02),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: view.frame.height * 0.02),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: view.frame.height * 0.12),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width * 0.35),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width * 0.35),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension LoginViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


