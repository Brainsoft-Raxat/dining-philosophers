//
//  CourierViewModel.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 16.04.2023.
//

import Foundation
import UIKit
import Combine

final class CourierViewModel: ObservableObject {
    
    @Published private(set) var orders: [Order] = []
    @Published public var error: Error?
    public var channelsRequests = Set<AnyCancellable>()
    
    private let networkingService = NetworkingService()
    
    func getOrders() {
        networkingService.getOrders { [weak self] result in
            switch result {
            case .success(let orders):
                self?.orders = orders
            case .failure(let error):
                self?.error = error
            }
        }
    }
    
}
