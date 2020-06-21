//
//  RegisterViewController.swift
//  Occasion
//
//  Created by Emin Emini on 08/06/2020.
//  Copyright © 2020 Emin Emini. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet var firstName: UITextField!
    @IBOutlet var pickedDate: UILabel!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBOutlet var PDSeparatorView: UIView!
    @IBOutlet weak var chooseDateView: UIView!
    @IBOutlet weak var pickerDate: UIDatePicker!
    @IBOutlet weak var chooseDateViewPosition: NSLayoutConstraint!
    
    
    //MARK: - Variables
       
       //iPhone size
       var iPhoneSize = CGFloat()
       
       var birthDate = ""
       var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        chooseDateView.dropShadow(color: .gray, opacity: 0.3, radius: 7, scale: true)
        setPickerViewPosition()
        PDSeparatorView.isHidden = true
        PDSeparatorView.alpha = 0
        
    }
    
    //Choose Date and Show Picker View
    @IBAction func chooseDate(_ sender: Any) {
        showPickerView(show: true)
    }
    
    @IBAction func cancelPickingDate(_ sender: Any) {
        showPickerView(show: false)
        
    }
    
    @IBAction func submitDate(_ sender: Any) {
        showPickerView(show: false)
        
        formatDate()
        pickedDate.text = birthDate
    }
    
    @IBAction func register(_ sender: Any) {
        
        guard let nameField = firstName.text, !nameField.isEmpty else {
            showAlert(title: "Write your name!", message: "Your name should not be empty, please write your name!")
            print("email should not be empty")
            return
        }
        
        let emailAddressValidationResult = isValidEmailAddress(emailAddressString: email.text!)
        
        guard let emailField = email.text, !emailField.isEmpty else {
            showAlert(title: "Write your email!", message: "Your email should not be empty, please write your email!")
            print("email should not be empty")
            return
        }
        
        if !emailAddressValidationResult {
            showAlert(title: "Invalid email!", message: "Your email is not valid, please write your valid email!")
            return
        }
        
        guard let passField = password.text, !passField.isEmpty else {
            showAlert(title: "Write your password!", message: "Your password should not be empty, please write your password!")
            print("password should not be empty")
            return
        }
        
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
                
                DispatchQueue.main.async {
                    self.showAlert(title: "Successfully Registered", message: "You created")
                }
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Failed to Register", message: "There is an erro, please try again later or make sure you filled everything correctlly.")
                }
            }
            
        })
        
        print()
    }
    
    @IBAction func signIn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
}


//MARK: - Picker Controller
extension RegisterViewController {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)
    }
    
    func formatDate() {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        birthDate = dateFormatter.string(from: pickerDate.date)
        self.view.endEditing(true)
    }
    
    func showPickerView(show: Bool) {
        if show {
            chooseDateViewPosition.constant = iPhoneSize
            PDSeparatorView.isHidden = false
            PDSeparatorView.alpha = 1.0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.chooseDateViewPosition.constant -= (self.chooseDateView.frame.size.height + iPhoneSize * 2)
            PDSeparatorView.alpha = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            PDSeparatorView.isHidden = true
        }
        
    }
    
    func setPickerViewPosition() {
        // Get main screen bounds
        let screenSize: CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        
        switch screenHeight {
        case 820...: //11 Pro Max
            iPhoneSize = 60
            //topConstraint.constant = 70
            //summaryIconConstraint.constant = 45
        case 812: //11 Pro
            iPhoneSize = 40
            //topConstraint.constant = 70
            //summaryIconConstraint.constant = 45
        case 737...811: //11
            iPhoneSize = 40
            //topConstraint.constant = 70
            //summaryIconConstraint.constant = 45
        case 736: //Plus
            iPhoneSize = 25
            //topConstraint.constant = 45
            //summaryIconConstraint.constant = 40
        case 667:
            iPhoneSize = 20
            //topConstraint.constant = 40
            //summaryIconConstraint.constant = 35
        default:
            iPhoneSize = 8
            //topConstraint.constant = 30
            //summaryIconConstraint.constant = 30
        }
        
        //chooseDateViewPosition.constant = iPhoneSize
        chooseDateViewPosition.constant -= (self.chooseDateView.frame.size.height + iPhoneSize * 2)
    }
    
}
