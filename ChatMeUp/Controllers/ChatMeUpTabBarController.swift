//
//  ChatMeUpTabBarController.swift
//  ChatMeUp
//
//  Created by Sina Eradat on 2/13/25.
//

import UIKit
import FirebaseAuth

class ChatMeUpTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LogInViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func setup() {
        let conversationVc = ConversationsViewController()
        conversationVc.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(systemName: "message.circle"), tag: 0)
        
        let profileVc = ProfileViewController()
        profileVc.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 1)
        
        let tabs = [UINavigationController(rootViewController: conversationVc),
                    UINavigationController(rootViewController: profileVc)]
        tabs.forEach { $0.navigationBar.prefersLargeTitles = true }
        
        setViewControllers(tabs, animated: true)
    }

}
