//
//  GreenDotAnnotationView.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 15.04.2023.
//

import UIKit
import MapKit

final class ShippingBoxAnnotationView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            let pinImage = UIImage(systemName: "shippingbox.circle")?.withTintColor(UIColor.black, renderingMode: .alwaysOriginal)
            let size = CGSize(width: 40, height: 40)
            UIGraphicsBeginImageContext(size)
            pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.image = resizedImage?.withTintColor(.green, renderingMode: .alwaysTemplate)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        canShowCallout = true
        centerOffset = CGPoint(x: 0, y: -20)
    }
    
}
