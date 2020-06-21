//
//  Event.swift
//  Occasion
//
//  Created by Emin Emini on 6.4.20.
//  Copyright © 2020 Emin Emini. All rights reserved.
//

import Foundation
import UIKit

struct Event: Decodable {
    var image: String
    var title: String
    var description: String
    var startDate: String
    var latitude: Double
    var longitude: Double
}

final class Events: Decodable {
    var id: Int?
    var name: String
    var date: String
    var description: String
    var latitude: String
    var longitude: String
    var photo: String
    
    init(name: String, date: String, description: String, latitude: String, longitude: String, photo: String) {
        self.name = name
        self.date = date
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.photo = photo
    }
}

final class EventRespond: Decodable {
    var event_id: Int
    var status: String
    
    init(event_id: Int, status: String) {
        self.event_id = event_id
        self.status = status
    }
}
