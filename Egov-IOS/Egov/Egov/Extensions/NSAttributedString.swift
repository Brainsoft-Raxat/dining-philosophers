//
//  NSAttributedString.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 15.04.2023.
//

import Foundation
import UIKit

extension NSAttributedString {
    
    private func apply(_ attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let mutable = NSMutableAttributedString(string: self.string, attributes: self.attributes(at: 0, effectiveRange: nil))
        let range = NSRange(location: 0, length: (self.string as NSString).length)
        mutable.addAttributes(attributes, range: range)
        return mutable
    }
    
    func textStyle(size: CGFloat, font: String = "default", color: UIColor = .black) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: size)
        
        return self.apply([.foregroundColor: color, .font: font])
    }
    
}
