//
//  NetworkingService.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 16.04.2023.
//

import Foundation
import UIKit

typealias IsIINValid = (Swift.Result<Bool, DataError>) -> Void
typealias NameGetter = (Swift.Result<UserName, DataError>) -> Void
typealias LocationGetter = (Swift.Result<Location, DataError>) -> Void
typealias OrdersGetter = (Swift.Result<[Order], DataError>) -> Void
typealias OrdersSetter = (Swift.Result<ResponseOrder, DataError>) -> Void
typealias BuyDelivery = (Swift.Result<String, DataError>) -> Void
typealias TakeOrder = (Swift.Result<String, DataError>) -> Void

protocol NetworkingLogic {
    func isValidIIN(iin: String, completion: @escaping (IsIINValid))
    func getUserName(iin: String, completion: @escaping (NameGetter))
    func getLocation(at address: String, completion: @escaping (LocationGetter))
    func createOrder(with order: RequestOrder, completion: @escaping (OrdersSetter))
    func buyDelivery(id: Int, completion: @escaping (BuyDelivery))
    func takeOrder(id: Int, phone: String, iin: String, completion: @escaping (TakeOrder))
}

final class NetworkingService: NetworkingLogic {
    
    private let iinCheckerUrl = "http://185.164.173.104:8080/api/check/"
    private let nameGetterUrl = "http://185.164.173.104:8080/api/client/"
    
    func getUserName(iin: String, completion: @escaping (NameGetter)) {
        let url = nameGetterUrl + iin
        guard let url = URL(string: url) else { return }
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, urlResponse, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkingError(error.localizedDescription)))
                }
                return
            }
            
            if let safeData = data {
                
                let decoder = JSONDecoder()
                
                do {
                    
                    let decodedData = try decoder.decode(UserName.self, from: safeData)
                    
                    DispatchQueue.main.async {
                        completion(.success(decodedData))
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.networkingError(error.localizedDescription)))
                    }
                }
                
            }
        }
        
        task.resume()
    }
    
    func isValidIIN(iin: String, completion: @escaping (IsIINValid)) {
        let url = iinCheckerUrl + iin
        guard let url = URL(string: url) else { return }
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, urlResponse, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkingError(error.localizedDescription)))
                }
                return
            }
            
            if let safeData = data {
                
                let decoder = JSONDecoder()
                
                do {
                    
                    let decodedData = try decoder.decode(IINChecker.self, from: safeData)
                    
                    DispatchQueue.main.async {
                        completion(.success(decodedData.is_exists))
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.networkingError(error.localizedDescription)))
                    }
                }
                
            }
        }
        
        task.resume()
    }
    
    func getLocation(at address: String, completion: @escaping (LocationGetter)) {
        guard let url = URL(string: "http://185.164.173.104:8080/api/coordinates") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // "Kazakhstan, Astana, Qabanbay Batyr 53"
        let jsonBody = ["street": address]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody) else { return }
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { data, urlResponse, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkingError(error.localizedDescription)))
                }
                return
            }
            
            if let safeData = data {
                
                let decoder = JSONDecoder()
                
                do {
                    
                    let decodedData = try decoder.decode(Location.self, from: safeData)
                    
                    DispatchQueue.main.async {
                        completion(.success(decodedData))
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.networkingError(error.localizedDescription)))
                    }
                }
                
            }
        }
        task.resume()
    }
    
    func getOrders(completion: @escaping (OrdersGetter)) {
        guard let url = URL(string: "http://185.164.173.104:8080/api/orders") else { return }
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, urlResponse, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkingError(error.localizedDescription)))
                }
                return
            }
            
            if let safeData = data {
                
                let decoder = JSONDecoder()
                
                do {
                    
                    let decodedData = try decoder.decode(Orders.self, from: safeData)
                    
                    DispatchQueue.main.async {
                        completion(.success(decodedData.orders))
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.networkingError(error.localizedDescription)))
                    }
                }
                
            }
        }
        
        task.resume()
    }
    
    func createOrder(with order: RequestOrder, completion: @escaping (OrdersSetter)) {
        guard let url = URL(string: "http://185.164.173.104:8080/api/orders/create") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let jsonBody = ["requestId": Singletion.entity.requestID,
                        "iin": Singletion.entity.iin,
                        "branch": order.branch,
                        "deliveryService": order.deliveryService,
                        "firstName": order.firstName,
                        "lastName": order.lastName,
                        "middleName": order.middleName,
                        "address": order.address,
                        "phone": order.phone,
                        "additionalData": order.additionalData,
                        "trustedFaceIin": order.trustedFaceIin]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody) else { return }
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { data, urlResponse, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkingError(error.localizedDescription)))
                }
                return
            }
            
            if let safeData = data {
                
                let decoder = JSONDecoder()
                
                do {
                    
                    let decodedData = try decoder.decode(ResponseOrder.self, from: safeData)
                    
                    DispatchQueue.main.async {
                        completion(.success(decodedData))
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.networkingError(error.localizedDescription)))
                    }
                }
                
            }
        }
        task.resume()
    }
    
    func buyDelivery(id: Int, completion: @escaping (BuyDelivery)) {
        guard let url = URL(string: "http://185.164.173.104:8080/api/orders/confirm") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let jsonBody = ["orderId": id]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody) else { return }
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { data, urlResponse, error in
            
            if let httpResponse = urlResponse as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    // Request was successful
                    DispatchQueue.main.async {
                        completion(.success("ok"))
                    }
                } else {
                    // Request failed
                    DispatchQueue.main.async {
                        completion(.failure(.networkingError("")))
                    }
                }
            } else if let error = error {
                // Request failed with error
                DispatchQueue.main.async {
                    completion(.failure(.networkingError(error.localizedDescription)))
                }
            }
        }
        task.resume()
    }
    
    func takeOrder(id: Int, phone: String, iin: String, completion: @escaping (TakeOrder)) {
        guard let url = URL(string: "http://185.164.173.104:8080/api/orders/start-deliver") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let jsonBody: [String : Any] = ["orderId": id,
                                        "phone": phone,
                                        "iin": iin ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody) else { return }
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { data, urlResponse, error in
            
            if let httpResponse = urlResponse as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    // Request was successful
                    DispatchQueue.main.async {
                        completion(.success("ok"))
                    }
                } else {
                    // Request failed
                    DispatchQueue.main.async {
                        completion(.failure(.networkingError("")))
                    }
                }
            } else if let error = error {
                // Request failed with error
                DispatchQueue.main.async {
                    completion(.failure(.networkingError(error.localizedDescription)))
                }
            }
        }
        task.resume()
    }
}
