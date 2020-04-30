//
//  LocationPickerViewController.swift
//  Occasion
//
//  Created by Emin Emini on 13.4.20.
//  Copyright © 2020 Emin Emini. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationPickerViewController: UIViewController {

    //MARK: - Outlets
    //Map View
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pickedLocationView: UIView!
    @IBOutlet weak var pickedLocationLabel: UILabel!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var doneView: UIView!
    
    //Constraints
    @IBOutlet weak var pickedLocationViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneViewConstraint: NSLayoutConstraint!
    
    
    //MARK: - Variables
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    
    var currentLatitude: Float = 0.0
    var currentLongitude: Float = 0.0
    
    
    
    //MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setShadows()
        
        
        
        mapView.layoutMargins.top = 60
        mapView.layoutMargins.right = 4
        mapView.layoutMargins.bottom = -20
        mapView.layoutMargins.left = 4
        // Do any additional setup after loading the view.
        checkLocationServices()
        
        
        pickedLocationViewConstraint.constant = -(pickedLocationView.frame.size.height + 20)
        doneViewConstraint.constant = -(doneView.frame.size.height + 20)
        pinImage.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, animations: {
            //self.locationsView.isHidden = true
            
            self.pickedLocationViewConstraint.constant += (self.pickedLocationView.frame.size.height + 20)
            self.doneViewConstraint.constant += (self.doneView.frame.size.height + 20)
            self.pinImage.isHidden = false
            self.view.layoutIfNeeded()
            print("Showing Map!")
        })
    }
    
    //MARK: - Actions
    
    @IBAction func cancelPickingLocation(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Done Button
    @IBAction func choosePickedLocation(_ sender: Any) {
        
        /*
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: myLocations)
        userDefaults.set(encodedData, forKey: "myLocations")
        userDefaults.synchronize()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)*/
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}


//MARK: - Setup Location
extension LocationPickerViewController {
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTackingUserLocation()
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            startTackingUserLocation()
            break
        @unknown default:
            break
        }
    }
    
    
    func startTackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

//MARK: - Location Manager Func
extension LocationPickerViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

//MARK: - Map Func
extension LocationPickerViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let _ = error {
                //TODO: Show alert informing the user
                return
            }
            
            guard let placemark = placemarks?.first else {
                //TODO: Show alert informing the user
                return
            }
            
            let city = placemark.locality ?? ""
            let country = placemark.country ?? ""
            let countryCode = placemark.isoCountryCode ?? ""
            
            var locationText = "Picked Location"
            
            if city.isEmpty {
                locationText = "\(country)"
            } else if !city.isEmpty {
                locationText = "\(city), \(countryCode)"
            }
            
            if city.isEmpty && country.isEmpty {
                locationText = "Picked Location"
            }
            
            DispatchQueue.main.async {
                self.pickedLocationLabel.text = "\(locationText)"
            }
            
            self.currentLatitude = Float(center.coordinate.latitude)
            self.currentLongitude = Float(center.coordinate.longitude)
            
            print("\(self.currentLatitude) \(self.currentLongitude)")
            
            self.pinImage.alpha = 1.0
            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pinImage.alpha = 0.5
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        pinImage.alpha = 0.5
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //pinImage.alpha = 1.0
    }
}

//MARK: - Functions
extension LocationPickerViewController {

    func setShadows() {
        let color = UIColor.gray
        let opacity: Float = 0.6
        
        pickedLocationView.dropShadow(color: color, opacity: opacity, radius: 10)
        doneView.dropShadow(color: color, opacity: opacity, radius: 10)
    }
    
}

