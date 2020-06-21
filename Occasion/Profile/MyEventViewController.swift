//
//  MyEventViewController.swift
//  Occasion
//
//  Created by Emin Emini on 21/06/2020.
//  Copyright © 2020 Emin Emini. All rights reserved.
//

import UIKit
import MapKit

class MyEventViewController: UIViewController, UIGestureRecognizerDelegate {

    //MARK: - Outlets
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var inviteFriends: UITextField!
    
    //MARK: - Variables
    var eventID = Int()
    var image = UIImage()
    var passTitle = String()
    var passDescription = String()
    var startDate = String()
    var latitude = Double()
    var longitude = Double()
    
    
    //Gestures
    private var pan: UIPanGestureRecognizer!
    let darknessThreshold: CGFloat = 0.2
    let dismissThreshold: CGFloat = 100.0 * UIScreen.main.nativeScale
    var dismissFeedbackTriggered = false
    //After view is dissmised
    var interactor: Interactor? = nil
    
    
    //MARK: - Did Load & Appear
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        showEventData()
        
        
        // Gestures
        self.pan = UIPanGestureRecognizer(target: self, action: #selector(self.panAction))
        self.pan.delegate = self
        self.pan.maximumNumberOfTouches = 1
        self.pan.cancelsTouchesInView = true
        closeButton.addGestureRecognizer(self.pan)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showEventData()
        
        initiateMap()
    }
    
    
    func showEventData() {
        eventImage.image = image
        eventTitle.text = passTitle
        eventDate.text = startDate
        eventDescription.text = passDescription
    }
    

    
    //MARK: - Actions
    @IBAction func dismissView() {
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "eventDismiss"), object: nil)
        }
    }
    
    @IBAction func getLocationDirections(_ sender: Any) {
        getDirections()
    }
    
    @IBAction func inviteFriend(_ sender: Any) {
        let emailAddressValidationResult = isValidEmailAddress(emailAddressString: inviteFriends.text!)
        
        guard let field = inviteFriends.text, !field.isEmpty else {
            showAlert(title: "Write email!", message: "The email of your friend should not be empty, please write their email!")
            print("email should not be empty")
            return
        }
        
        if !emailAddressValidationResult {
            showAlert(title: "Invalid email!", message: "The email is not valid, please write a valid email!")
            return
        }
        
        inviteFriend(eventID: eventID, email: inviteFriends.text!)
    }
    
    
    func inviteFriend(eventID id: Int, email: String) {
        let invite = Invite(event_id: id, email: email)
        
        let postRequest = APIRequest(request: "invite")
        
        postRequest.inviteFriend(invite, completion: { result in
            switch result {
            case .success(let inviteResponse):
                print("Message: \(inviteResponse.message)")
            case .failure(let error):
                print("Error: \(error)")
            }
            
        })
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


//MARK: - MapView
extension MyEventViewController {
    func initiateMap() {
        // Set initial location in Honolulu
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        mapView.centerToLocation(initialLocation, regionRadius: 10000)
        
        setPinUsingMKPointAnnotation(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
    /*
    func setPinUsingMKPlacemark(location: CLLocationCoordinate2D) {
       let pin = MKPlacemark(coordinate: location)
       let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
       mapView.setRegion(coordinateRegion, animated: true)
       mapView.addAnnotation(pin)
    }*/
    
    func setPinUsingMKPointAnnotation(location: CLLocationCoordinate2D) {
       let annotation = MKPointAnnotation()
       annotation.coordinate = location
       annotation.title = passTitle
       annotation.subtitle = startDate
       let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
       mapView.setRegion(coordinateRegion, animated: true)
       mapView.addAnnotation(annotation)
    }
    
    func getDirections() {
        let actionSheet = UIAlertController(title: "Get Directions", message: "Get directions to the location of event.", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { (action: UIAlertAction) in
            self.openInMaps()
        }))
        actionSheet.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { (action: UIAlertAction) in
            self.openInGoogleMaps()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func openInMaps() {
        let regionDistance:CLLocationDistance = 100
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = passTitle
        mapItem.openInMaps(launchOptions: options)
    }
    
    
    func openInGoogleMaps() {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string:
                "comgooglemaps://?center=\(latitude),\(longitude)&zoom=15&views=traffic")!)
        } else {
            let alert = UIAlertController(title: "Google Maps Can't Open", message: "Make sure you install Google Maps and then you can open.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Install", style: .default, handler: { (action: UIAlertAction) in
                UIApplication.shared.openURL(URL(string:
                    "https://itunes.apple.com/us/app/google-maps-gps-navigation/id585027354?mt=8")!)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            print("Can't use comgooglemaps://");
        }
    }
}

// MARK: - Gesture recognizers
extension MyEventViewController {
    

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

