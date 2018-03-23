//
//  MyPin.swift
//  ps-challenge
//
//  Created by Cagri Sahan on 3/21/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import MapKit

class MyPin: NSObject, MKAnnotation, Codable {
    
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

// MARK: Extensions
extension CLLocationCoordinate2D: Codable {
    
    enum codingKeys: CodingKey {
        case longitude
        case latitude
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: codingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
     public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: codingKeys.self)
        longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
    }
}
