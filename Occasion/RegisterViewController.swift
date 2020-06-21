//
//  RegisterViewController.swift
//  Occasion
//
//  Created by Emin Emini on 08/06/2020.
//  Copyright © 2020 Emin Emini. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("register")
        
    }
    
    @IBAction func register(_ sender: Any) {
        
        print("register is pressed")
        
        let myName = firstName.text as! String
        let myEmail = email.text as! String
        let myPass = password.text as! String
        
        let user = User(name: myName, email: myEmail, photo: "htttps://wefwef", birthdate: "1998-01-01", password: myPass)
        
        let postRequest = APIRequest(request: "register")
        
        postRequest.register(user, completion: { result in
            switch result {
            case .success(let userResponse):
                print("Token: \(userResponse.token ?? ""), Message: \(userResponse.message)")
            case .failure(let error):
                print("Error: \(error)")
            }
            
        })
        
        print()
    }
    
}
