//
//  RequestOrder.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 16.04.2023.
//

import Foundation

struct RequestOrder: Codable {
    let requestId: String
    let iin: String
    let branch: String
    let deliveryService: String
    let firstName: String
    let lastName: String
    let middleName: String
    let address: String
    let phone: String
    let additionalData: String
    let trustedFaceIin: String
}
