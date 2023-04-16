//
//  Orders.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 16.04.2023.
//

import Foundation

struct Orders: Codable {
    let orders: [Order]
}

struct Order: Codable {
    let id: Int
    let iin: String
    let requestId: String
    let serviceName: String
    let organizationCode: String
    let organizationName: String
    let recipientName: String
    let recipientSurname: String
    let recipientPhone: String
    let region: String
    let city: String
    let street: String
    let house: String
    let entrance: String
    let floor: String
    let corpus: String
    let courierPhone: String
    let additionalData: String
    let trustedFaceIin: String
    let deliveryServiceId: Int
    let deliveryPrice: Int
    let courierIin: String
    let status: String
}
