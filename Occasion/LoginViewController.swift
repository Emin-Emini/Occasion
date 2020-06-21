//
//  LoginViewController.swift
//  Occasion
//
//  Created by Emin Emini on 07/06/2020.
//  Copyright © 2020 Emin Emini. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

    }
    
    @IBAction func signIn(_ sender: Any) {
        
        /*
        guard let emailField = emailTextField.text, !emailField.isEmpty else {
            let alert = UIAlertController(title: "Write your email!", message: "Your email should not be empty, please write your email!", preferredStyle: .alert)
            self.present(alert, animated: true)
            print("email should not be empty")
            return
        }
        
        guard let passField = passwordTextField.text, !passField.isEmpty else {
         let alert = UIAlertController(title: "Write your password!", message: "Your password should not be empty, please write your password!", preferredStyle: .alert)
         self.present(alert, animated: true)
            print("password should not be empty")
            return
        }*/
        
        
        login()
        
        
    }
    
    func login() {
        let user = User(name: "", email: "emin@gmail.com", photo: "1111", birthdate: "", password: "")
        
        let myEmail = /*emailTextField.text!*/ "emin@gmail.com"
        let myPass = /*passwordTextField.text!*/ "1111"
        
        print("login?email=\(myEmail)&password=\(myPass)")
        
        let postRequest = APIRequest(request: "login?email=\(myEmail)&password=\(myPass)")
        
        postRequest.login(user, completion: { result in
            switch result {
            case .success(let user):
//                let HomeVC = HomeViewController() //your view controller
//                self.present(HomeVC, animated: true, completion: nil)
                print("Token: \(user.token), Message: \(user.message)")
                userToken = user.token!
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goToHome", sender: self)
                }
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: "Error while trying to login", preferredStyle: .alert)
                self.present(alert, animated: true)
                print("Error: \(error)")
            }
            
        })
    }
    

}


extension LoginViewController: UITextFieldDelegate {
    //MARK: Textfield Delegate
    // When user press the return key in keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
    print("textFieldShouldReturn")
    textField.resignFirstResponder()
    return true
    }

    // It is called before text field become active
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.backgroundColor = UIColor.lightGray
        return true
    }

    // It is called when text field activated
    func textFieldDidBeginEditing(textField: UITextField) {
        print("textFieldDidBeginEditing")
    }

    // It is called when text field going to inactive
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.backgroundColor = UIColor.white
        return true
    }

    // It is called when text field is inactive
    func textFieldDidEndEditing(textField: UITextField) {
        print("textFieldDidEndEditing")
    }

    // It is called each time user type a character by keyboard
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        print(string)
        return true
    }
}
