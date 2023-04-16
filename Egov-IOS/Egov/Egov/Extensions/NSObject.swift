//
//  NSObject.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 15.04.2023.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}
