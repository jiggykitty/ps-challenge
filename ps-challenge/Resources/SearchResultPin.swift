//
//  SearchResultPin.swift
//  ps-challenge
//
//  Created by Cagri Sahan on 3/24/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import MapKit

class SearchResultPin: NSObject, MKAnnotation, Codable {
    
    // MARK: Variables
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    // MARK: Functions
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
}
