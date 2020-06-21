//
//  ProfileViewController.swift
//  Occasion
//
//  Created by Emin Emini on 10.4.20.
//  Copyright © 2020 Emin Emini. All rights reserved.
//

import UIKit

var myEvents = [Events]()

class ProfileViewController: UIViewController {

    @IBOutlet var profilePhoto: UIImageView!
    @IBOutlet var myName: UILabel!
    @IBOutlet var myBio: UILabel!
    
    @IBOutlet weak var myEventsTableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        myEventsTableView.delegate = self
        myEventsTableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        // this is the replacement of implementing: "collectionView.addSubview(refreshControl)"
        myEventsTableView.refreshControl = refreshControl
        
        fetchData()
    }
        
        
    @objc func refresh(sender:AnyObject) {
        // Updating your data here...
        fetchData()
        self.myEventsTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.myEventsTableView.reloadData()
        
        previousViewIndex = 2
    }
    
    
    func fetchData() {
        
        let getEvents = APIRequest(request: "myEvents")

        getEvents.getEvents(completion: { result in
            switch result {
            case .success(let APIEvents):
                myEvents = APIEvents
            case .failure(let error):
                print("Error: \(error)")
            }

        })

        
        let getUserDeatails = APIRequest(request: "userdetails")
        
        getUserDeatails.getUserDetails(completion: { result in
            switch result {
            case .success(let userDetails):
                self.profilePhoto.image = UIImage(named: userDetails[0].photo)
                self.myName.text = userDetails[0].name
                self.myBio.text = "My name is \(userDetails[0].name), and I'm Computer Science and Engineering student. I have created \(myEvents.count) events"
                print("\(userDetails)")
            case .failure(let error):
                print("Error: \(error)")
            }

        })
        
       
    }

}

//MARK: - Table View
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventsCell", for: indexPath) as! EventTableViewCell
        
        
        
        
       
        
        //print("Events:\n \(events)")
        let event = myEvents[indexPath.item]
        
        cell.eventImage.image = UIImage(named: "\(event.photo)")
        cell.eventTitle.text = event.name
        cell.eventDate.text = "starts \(event.date)"
        cell.eventDescription.text = event.description
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let eventVC = storyboard.instantiateViewController(identifier: "EventViewController") as! EventViewController
        
        let eventVC: MyEventViewController =
            self.storyboard!.instantiateViewController(withIdentifier: "MyEventViewController") as! MyEventViewController
        
        let event = myEvents[indexPath.row]
        
        eventVC.eventID = event.id!
        eventVC.image = UIImage(named: "\(event.photo)")!
        eventVC.passTitle = event.name
        eventVC.passDescription = event.description
        eventVC.startDate = event.date
        eventVC.latitude = Double(event.latitude)!
        eventVC.longitude = Double(event.longitude)!
        
        indexPressed = indexPath.row
        
        tableView.deselectRow(at: indexPath, animated: true)
        //self.performSegue(withIdentifier: "selectedEvent", sender: indexPath)
        
        
        self.present(eventVC, animated: true, completion: nil)
    }
    
    
}
