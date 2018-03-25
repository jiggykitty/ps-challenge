//
//  MyPinView.swift
//  ps-challenge
//
//  Created by Cagri Sahan on 3/24/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit
import MapKit

class MySavedPinView: MKAnnotationView {

    override var annotation: MKAnnotation? {
        willSet {
            guard newValue is MyPin else { return }
            canShowCallout = true
            image = #imageLiteral(resourceName: "parkingIcon")
        }
    }
}

