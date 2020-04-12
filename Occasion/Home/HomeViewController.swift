//
//  ViewController.swift
//  Occasion
//
//  Created by Emin Emini on 3.4.20.
//  Copyright © 2020 Emin Emini. All rights reserved.
//

import UIKit

var events: [Event] = {
    let event1 = Event(image: UIImage(named: "event1")!, title: "Best of Vienna Walking Tour", description: "We leave the big tour groups behind and explore the city in our own small team. Let's make it interactive.", startDate: "10:30am", latitude: 48.2082, longitude: 16.3738)
    
    let event2 = Event(image: UIImage(named: "event2")!, title: "Cooking party", description: "We leave the big tour groups behind and explore the city in our own small team. Let's make it interactive.", startDate: "10 May, 1:00pm", latitude: 38.73219, longitude: -9.13089)
    
    let event3 = Event(image: UIImage(named: "event3")!, title: "Belem Tour", description: "We leave the big tour groups behind and explore the city in our own small team. Let's make it interactive.", startDate: "12:00pm", latitude: 38.6916, longitude: -9.2160)
   
    
    return [event1, event2, event3]
}()

var indexPressed: Int?

class HomeViewController: UIViewController {

    
    @IBOutlet weak var eventsTableView: UITableView!
    
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        // this is the replacement of implementing: "collectionView.addSubview(refreshControl)"
        eventsTableView.refreshControl = refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventsTableView.reloadData()
        
        previousViewIndex = 0
    }
    
    @objc func refresh(sender:AnyObject) {
        // Updating your data here...

        self.eventsTableView.reloadData()
        self.refreshControl.endRefreshing()
    }


}

//MARK: - Table View
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventsCell", for: indexPath) as! EventTableViewCell
        
        
        let event = events[indexPath.item]
        
        cell.eventImage.image = event.image
        cell.eventTitle.text = event.title
        cell.eventDate.text = "starts \(event.startDate)"
        cell.eventDescription.text = event.description
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let eventVC = storyboard.instantiateViewController(identifier: "EventViewController") as! EventViewController
        
        let eventVC: EventViewController =
            self.storyboard!.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        
        let event = events[indexPath.row]
        
        eventVC.image = event.image
        eventVC.passTitle = event.title
        eventVC.passDescription = event.description
        eventVC.startDate = event.startDate
        eventVC.latitude = event.latitude
        eventVC.longitude = event.longitude
        
        
        
        print("Pressed: \(events[indexPath.row].image)")
        
        indexPressed = indexPath.row
        
        tableView.deselectRow(at: indexPath, animated: true)
        //self.performSegue(withIdentifier: "selectedEvent", sender: indexPath)
        
        
        self.present(eventVC, animated: true, completion: nil)
    }
    
    
}
