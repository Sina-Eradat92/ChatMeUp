//
//  LogInViewController.swift
//  ChatMeUp
//
//  Created by Sina Eradat on 2/13/25.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class LogInViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.keyboardType = .emailAddress
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .systemBackground
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .systemBackground
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.addTarget(nil, action: #selector(didTapLogin), for: .touchUpInside)
        return button
    }()
    
    private let googleSignInButton = GIDSignInButton()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Login"
        view.backgroundColor = .systemBackground
        
        //
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        //
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapScreen)))
        
        //
        googleSignInButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapGoogleSignIn)))
        
        // Add Subviews
        scrollView.addSubViews(imageView, emailField, passwordField, loginButton, googleSignInButton)
        view.addSubViews(scrollView)
        
        // Delegate
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (scrollView.width - size) / 2, y: 20, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 20, width: scrollView.width - 60, height: 52)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scrollView.width - 60, height: 52)
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom + 10, width: scrollView.width - 60, height: 52)
        googleSignInButton.frame = CGRect(x: 30, y: loginButton.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    @objc private func didTapScreen() {
        view.endEditing(true)
    }

    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapLogin() {
        if emailField.isFirstResponder || passwordField.isFirstResponder { view.endEditing(true) }
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            allertUserLoginError()
            return
        }
        
        // Firebase login
        Task {
            do {
                try await FirebaseAuth.Auth.auth().signIn(withEmail: email.lowercased(), password: password)
                navigationController?.dismiss(animated: true)
            } catch {
                print("Faild to login user: \(error)")
            }
        }
        
    }
    
    @objc func didTapGoogleSignIn() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self]  result, error in
            guard error == nil else { print("Google SignIn Error: \(error!)"); return }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { print("Error No User Found"); return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            guard let email = result?.user.profile?.email,
            let firstName = result?.user.profile?.givenName,
            let lastName = result?.user.profile?.familyName else { return }
            
            // Firebase login
            Task {
                do {
                    if await !DataBaseManager.shared.userExists(with: email) {
                        try DataBaseManager.shared.insertUser(with: ChatAppUser(first_name: firstName, last_name: lastName, email_address: email))
                    }
                    try await FirebaseAuth.Auth.auth().signIn(with: credential)
                    navigationController?.dismiss(animated: true)
                } catch {
                    print("Faild to login user: \(error)")
                }
            }
        }
    }
    
    private func allertUserLoginError() {
        let alert = UIAlertController(title:  "Bad Credentials", message: "Please enter all information to Login", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel ))
        present(alert, animated: true)
    }
}

extension LogInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            didTapLogin()
        }
        return true
    }
}
