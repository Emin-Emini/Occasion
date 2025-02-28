//
//  AddEventViewController.swift
//  Occasion
//
//  Created by Emin Emini on 8.4.20.
//  Copyright © 2020 Emin Emini. All rights reserved.
//

import UIKit

var previousViewIndex = 0

var selectedLatitude = ""
var selectedLongitude = ""

class AddEventViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {

    
    //MARK: - Outlets
    @IBOutlet weak var closeButton: UIButton!
    
    //Data
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventDescription: UITextField!
    @IBOutlet weak var pickedDate: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var doneButtonBG: UIImageView!
    
    //Date Pickerview
    @IBOutlet weak var PDSeparatorView: UIView!
    @IBOutlet weak var chooseDateView: UIView!
    @IBOutlet weak var pickerDate: UIDatePicker!
    @IBOutlet weak var chooseDateViewPosition: NSLayoutConstraint!
    
    
    
    //MARK: - Variables
    
    //iPhone size
    var iPhoneSize = CGFloat()
    
    var eventDate = ""
    var imagePicker = UIImagePickerController()
    
    //Gestures
    private var pan: UIPanGestureRecognizer!
    let darknessThreshold: CGFloat = 0.2
    let dismissThreshold: CGFloat = 100.0 * UIScreen.main.nativeScale
    var dismissFeedbackTriggered = false
    //After view is dissmised
    var interactor: Interactor? = nil
    
    
    
    //MARK: - View Did Load & Appear
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        chooseDateView.dropShadow(color: .gray, opacity: 0.3, radius: 7, scale: true)
        setPickerViewPosition()
        PDSeparatorView.isHidden = true
        PDSeparatorView.alpha = 0
        
        self.eventName.delegate = self
        self.eventDescription.delegate = self
        
        // Gestures
        self.pan = UIPanGestureRecognizer(target: self, action: #selector(self.panAction))
        self.pan.delegate = self
        self.pan.maximumNumberOfTouches = 1
        self.pan.cancelsTouchesInView = true
        closeButton.addGestureRecognizer(self.pan)
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.tabBarController?.selectedIndex = previousViewIndex
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.hidesBottomBarWhenPushed = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.switchBasedNextTextField(textField)
        
        return true
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
       switch textField {
        case eventName:
            self.eventDescription.becomeFirstResponder()
        case eventDescription:
            self.view.endEditing(true)
            showPickerView(show: true)
        default:
            self.view.endEditing(true)
        }
    }
    
    
    //MARK: - Actions
    
    //Dismiss View
    @IBAction func dismissView() {
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "eventDismiss"), object: nil)
        }
    }
    
    @IBAction func uploadPhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
        }
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
        pickedDate.text = eventDate
    }
    
    //Submit Event
    @IBAction func submitEvent(_ sender: Any) {
        formatDate()
        
        let eName = eventName.text!
        let eDescription = eventDescription.text!
        
        
        let getEvents = APIRequest(request: "createEvent")

        let event = Events(name: eName, date: eventDate, description: eDescription, latitude: selectedLatitude, longitude: selectedLongitude, photo: "default_photo")
        
        let postRequest = APIRequest(request: "createEvent")
        
        getEvents.createEvent(event, completion: { result in
            switch result {
            case .success(let event):
                print("Print: \(event)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                print("Error: \(error)")
            }

        })
        
        //let eventToAdd = Event(image: "event1"/*eventImage.image!*/, title: eventName.text!, description: eventDescription.text!, startDate: "\(eventDate)", latitude: 38.73219, longitude: -9.2160)
        
        //print(eventToAdd)
        //events.append(eventToAdd)
        
        
    }
    
}


//MARK: - Picker Controller
extension AddEventViewController {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)

        eventImage.image = image
    }
    
    func formatDate() {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        eventDate = dateFormatter.string(from: pickerDate.date)
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



// MARK: - Gesture recognizers
extension AddEventViewController {
    

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.pan {
            return limitPanAngle(self.pan, degreesOfFreedom: 45.0, comparator: .greaterThan)
        }

        return true
    }
    
    private func updatePresentedViewForTranslation(_ yTranslation: CGFloat) {
        let translation: CGFloat = rubberBandDistance(yTranslation, dimension: self.view.frame.height, constant: 0.55)

        self.view.transform = CGAffineTransform(translationX: 0, y: max(translation, 0.0))
    }
    
    @objc private func panAction(gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.isEqual(self.pan) else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)

        case .changed:
            let translation = gestureRecognizer.translation(in: self.view)

            self.updatePresentedViewForTranslation(translation.y)

            if translation.y > self.dismissThreshold, !self.dismissFeedbackTriggered {
                self.dismissFeedbackTriggered = true
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        case .ended, .failed:
            let translation = gestureRecognizer.translation(in: self.view)

            if translation.y > self.dismissThreshold {
                self.dismissView()
                return
            }

            self.dismissFeedbackTriggered = false

            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           usingSpringWithDamping: 0.75,
                           initialSpringVelocity: 1.5,
                           options: .preferredFramesPerSecond60,
                           animations: {
                            self.self.view.transform = .identity
            })
            
        case .cancelled:
            UIView.animate(withDuration: 0.1, animations: {
            })

        default: break
        }
    }
}
