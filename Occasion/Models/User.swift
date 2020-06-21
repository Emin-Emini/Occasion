//
//  User.swift
//  Occasion
//
//  Created by Emin Emini on 12/06/2020.
//  Copyright © 2020 Emin Emini. All rights reserved.
//

import Foundation

final class User: Codable {
    var id: Int?
    var name: String
    var email: String
    var photo: String
    var birthdate: String
    var password: String
    
    
    init(name: String, email: String, photo: String, birthdate: String, password: String) {
        self.name = name
        self.email = email
        self.photo = photo
        self.birthdate = birthdate
        self.password = password
    }
}

struct UserResponse: Codable {
    let message: String
    let token: String?
}
