//
//  InformationModel.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 15.04.2023.
//

import Foundation

struct InformationModel {
    let text: String
    let details: String
    let image: String
    let price: Int?
    
    init(text: String, details: String, image: String, price: Int? = nil) {
        self.text = text
        self.details = details
        self.image = image
        self.price = price
    }
}
