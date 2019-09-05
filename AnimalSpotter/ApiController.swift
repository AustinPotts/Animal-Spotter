//
//  ApiController.swift
//  AnimalSpotter
//
//  Created by Austin Potts on 9/4/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

enum HTTPMethod: String{
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    
}

enum NetworkError: Error{
    case ecodingError
    case responseError
    case otherError(Error)
    case noData
    case noDecode
    case noToken
}

//Model Controller. Model Controllers are always classes
class APIController {
    
    let baseURL = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    
    var bearer: Bearer?
    
    // The Error? in completion closure lets us return an error to the view controller for further error handling.
    func signUp(with user: User, completion: @escaping (NetworkError?) -> Void){
        
        let signUpURL = baseURL.appendingPathComponent("users")
            .appendingPathComponent("signup")
        
        var request = URLRequest(url: signUpURL)
        request.httpMethod = HTTPMethod.post.rawValue
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let encoder = JSONEncoder()
        
        do{
            let userData = try encoder.encode(user)
            request.httpBody = userData
            
        } catch {
            NSLog("Error encoding user: \(error)")
            completion(.ecodingError)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.responseError)
                return
            }
            
            if let error = error{
                NSLog("Error Creating User on Server: \(error)")
                completion(.otherError(error))
                return
            }
            completion(nil)
            
            }.resume() //Resuming the data task
        
    }
    
    func login(with user: User, completion: @escaping (NetworkError?) -> Void) {
        
        //Set up URL
        
        let loginURL = baseURL.appendingPathComponent("users")
            .appendingPathComponent("login")
        
        //Set up a request
        
        var request = URLRequest(url: loginURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        
        do{
            request.httpBody = try encoder.encode(user)
            
        } catch {
            NSLog("Error: \(error)")
            completion(.ecodingError)
            return
            
        }
        
        
        //Perform the request
        
        URLSession.shared.dataTask(with: request) {(data, response, error)  in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.responseError)
                return
            }
            
            
            
            //Handle Errors
            if let error = error {
                NSLog("Error \(error)")
                completion(.otherError(error))
                return
            }
            
            guard let data = data else{
                completion(.noData)
                return
            }
            
            do{
                let bearer = try JSONDecoder().decode(Bearer.self, from: data)
                
                self.bearer = bearer
            } catch {
                completion(.noDecode)
                return
            }
            completion(nil)
            
            }.resume()
    }
                                        //Enum type(Result = String else Error)
    func getAllAnimalNames(completion: @escaping (Result<[String], NetworkError>) -> Void) {
        
        guard let bearer = bearer else {
            completion(.failure(.noToken))
            return
        }
        
        let requestURL = baseURL.appendingPathComponent("animals")
            .appendingPathComponent("all")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request){(data,response,error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.responseError))
                return
            }
            
            if let error = error {
                NSLog("Error getting animal names: \(error)")
                completion(.failure(.otherError(error)))
                return
            }
            
            
            guard let data = data else{
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let animalNames = try decoder.decode([String].self, from: data)
                completion(.success(animalNames))
            } catch {
                NSLog("Error decoding animals name: \(error)")
                completion(.failure(.noDecode))
                return
                
                
            }
            
        }.resume()
    }
    
    func getAnimal(with name: String, completion: @escaping (Result<Animal, NetworkError>) -> Void) {
        
        guard let bearer = bearer else {
            completion(.failure(.noToken))
            return
        }
        
        let requestURL = baseURL.appendingPathComponent("animals")
            .appendingPathComponent(name)
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request){(data,response,error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.responseError))
                return
            }
            
            if let error = error {
                NSLog("Error getting animal details: \(error)")
                completion(.failure(.otherError(error)))
                return
            }
            
            
            guard let data = data else{
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let animal = try decoder.decode(Animal.self, from: data)
                completion(.success(animal))
            } catch {
                NSLog("Error decoding animal: \(error)")
                completion(.failure(.noDecode))
                return
                
                
            }
            
            }.resume()
        
    }
    
}
