//
//  MKMapView+CenterInLocation.swift
//  Wapa_Customer_iOS
//
//  Created by Daniel Gomez Rico on 7/9/15.
//  Copyright © 2015 Barista Ventures. All rights reserved.
//

import MapKit

public extension MKMapView {
    
    public func centerZoomed(location: CLLocation, zoomLevel:Double = 0.4) {
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: zoomLevel, longitudeDelta: zoomLevel)
        let locationCenter = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: locationCenter, span: span)
        
        setRegion(region, animated: true)
    }
    
}
