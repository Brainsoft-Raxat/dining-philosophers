//
//  MKMapView.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 15.04.2023.
//

import Foundation
import MapKit

extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
