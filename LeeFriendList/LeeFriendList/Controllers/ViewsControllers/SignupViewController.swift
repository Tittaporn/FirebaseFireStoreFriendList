//
//  SignupViewController.swift
//  LeeFriendList
//
//  Created by Lee McCormick on 3/16/21.
//

import UIKit

class SignupViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var signupFirstNameTextField: UITextField!
    @IBOutlet weak var signupLastNameTextField: UITextField!
    @IBOutlet weak var signupEmailTextField: UITextField!
    @IBOutlet weak var signupPasswordTextField: UITextField!
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPassWordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        guard let firstName = signupFirstNameTextField.text, !firstName.isEmpty,
              let lastName = signupLastNameTextField.text, !lastName.isEmpty,
              let email = signupEmailTextField.text, !email.isEmpty,
              let password = signupPasswordTextField.text, !password.isEmpty else {return}
        
        UserController.shared.signupNewUserAndCreateNewContactWith(firstName: firstName, lastName: lastName, email: email, password: password) { (results) in
            switch results {
            case .success(let user):
                print("=================SUCESSFULLY SIGNING USER :\(user.firstName)===================")
                self.gotoTappedBarController()
            case .failure(let error):
                print("ERROR SIGNING UP USER : \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        guard let email = loginEmailTextField.text, !email.isEmpty,
              let password = loginPassWordTextField.text, !password.isEmpty else {return}
        
        UserController.shared.loginWith(email: email, password: password) { (results) in
            switch results {
            case .success(let results):
                print("This is email of loggin user : \(results)")
                self.gotoTappedBarController()
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
        
    }
    
    
    // MARK: - Helper Fuctions
    func gotoTappedBarController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let  vc = storyboard.instantiateViewController(identifier: "tabbarStoryboardID")
        vc.modalPresentationStyle = .pageSheet
        self.present( vc, animated: true, completion: nil)
    }
}
