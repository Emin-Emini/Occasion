//
//  APIRequest.swift
//  Occasion
//
//  Created by Emin Emini on 08/06/2020.
//  Copyright © 2020 Emin Emini. All rights reserved.
//

import Foundation

enum APIError: Error {
    case responseProblem
    case decodingProblem
    case encodingProblem
}

var userToken = ""

struct APIRequest {
    let resourceURL: URL
    
    init(request: String) {
        let resoucreString = "http://192.168.1.81:8000/api/\(request)"
        guard let resourceURL = URL(string: resoucreString) else {print("Incorrect Pass");fatalError()}
        
        print(resourceURL)
        
        self.resourceURL = resourceURL
    }
    
    func login(_ user: User, completion: @escaping(Result<UserResponse, APIError>) -> Void) {
        
        do {
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Contant-Type")
            guard let body = try? JSONEncoder().encode([
                "email": user.email,
                "password": user.password
            ]) else {
                return
            }
            urlRequest.httpBody = body
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
                    
                    completion(.failure(.responseProblem))
                    return
                }
                
                if httpResponse.statusCode == 401 {
                    print("Wrong Pass!")
                }
                
                do {
                    let messageData = try JSONDecoder().decode(UserResponse.self, from: jsonData)
                    completion(.success(messageData))
                } catch {
                    completion(.failure(.decodingProblem))
                }
            }
            dataTask.resume()
            
        } catch {
            completion(.failure(.encodingProblem))
        }
        
    }
    
    
    
    func register(_ user: User, completion: @escaping(Result<UserResponse, APIError>) -> Void) {
        let body = [
            "name": user.name,
            "email": user.email,
            "photo": user.photo,
            "birthdate": user.birthdate,
            "password": user.password
        ]
    
        let session = URLSession.shared
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                //completion(nil, error)
                return
            }
            guard let data = data else {
                //completion(nil, NSError(domain: "dataNilError", code: -100001, userInfo: nil))
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as?[String: Any] else {
                    //completion(nil, NSError(domain: "invalidJSONTypeError", code: -100009, userInfo: nil))
                    return
                }
                print(json)
                //completion(json, nil)
            } catch let error {
                print(error.localizedDescription)
                //completion(nil, error)
            }
        })
        task.resume()
       
        
    }
    
    
    func getEvents(completion: @escaping(Result<[Events], APIError>) -> Void) {
        
        var urlRequest = URLRequest(url: resourceURL)
        
        urlRequest.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
                completion(.failure(.responseProblem))
                return
            }
            do {
                let decoder = JSONDecoder()
                //let eventsData = try JSONDecoder().decode(User.self, from: jsonData)
                let eventData = try decoder.decode([Events].self, from: jsonData)
                print(eventData)
                completion(.success(eventData))
            } catch {
                completion(.failure(.decodingProblem))
            }
        }
        dataTask.resume()
            
        
    }
    
    func createEvent(_ event: Events, completion: @escaping(Result<UserResponse, APIError>) -> Void) {
        let body = [
            "date": event.date,
            "description": event.description,
            "id": 0,
            "latitude": event.latitude,
            "longitude": event.longitude,
            "name": event.name,
            "photo": event.photo
            ] as [String : Any]
    
        let session = URLSession.shared
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                //completion(nil, error)
                return
            }
            guard let data = data else {
                //completion(nil, NSError(domain: "dataNilError", code: -100001, userInfo: nil))
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as?[String: Any] else {
                    //completion(nil, NSError(domain: "invalidJSONTypeError", code: -100009, userInfo: nil))
                    return
                }
                print(json)
                //completion(json, nil)
            } catch let error {
                print(error.localizedDescription)
                //completion(nil, error)
            }
        })
        task.resume()
    }
    
    func respondToEvent(_ event: EventRespond, completion: @escaping(Result<UserResponse, APIError>) -> Void) {
        let body = [
            "event_id": event.event_id,
            "status": event.status
            ] as [String : Any]
    
        let session = URLSession.shared
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                //completion(nil, error)
                return
            }
            guard let data = data else {
                //completion(nil, NSError(domain: "dataNilError", code: -100001, userInfo: nil))
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as?[String: Any] else {
                    //completion(nil, NSError(domain: "invalidJSONTypeError", code: -100009, userInfo: nil))
                    return
                }
                print(json)
                //completion(json, nil)
            } catch let error {
                print(error.localizedDescription)
                //completion(nil, error)
            }
        })
        task.resume()
    }
    
    
    func inviteFriend(_ invite: Invite, completion: @escaping(Result<UserResponse, APIError>) -> Void) {
        let body = [
            "email": invite.email,
            "event_id": invite.event_id
            ] as [String : Any]
    
        let session = URLSession.shared
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                //completion(nil, error)
                return
            }
            guard let data = data else {
                //completion(nil, NSError(domain: "dataNilError", code: -100001, userInfo: nil))
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as?[String: Any] else {
                    //completion(nil, NSError(domain: "invalidJSONTypeError", code: -100009, userInfo: nil))
                    return
                }
                print(json)
                //completion(json, nil)
            } catch let error {
                print(error.localizedDescription)
                //completion(nil, error)
            }
        })
        task.resume()
    }
    
    
    func getUserDetails(completion: @escaping(Result<[User], APIError>) -> Void) {
        
        var urlRequest = URLRequest(url: resourceURL)
        
        urlRequest.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
                completion(.failure(.responseProblem))
                return
            }
            do {
                let decoder = JSONDecoder()
                //let eventsData = try JSONDecoder().decode(User.self, from: jsonData)
                let userData = try decoder.decode([User].self, from: jsonData)
                print(userData)
                completion(.success(userData))
            } catch {
                completion(.failure(.decodingProblem))
            }
        }
        dataTask.resume()
            
        
    }
    
}


