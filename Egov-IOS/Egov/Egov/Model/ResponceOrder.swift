//
//  ResponceOrder.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 16.04.2023.
//

import Foundation

struct ResponseOrder: Codable {
    let orderId: Int
    let branchName: String
    let price: Int
    let time: Int
    let distance: Int
}
