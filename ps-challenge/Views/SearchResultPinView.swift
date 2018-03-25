//
//  MyPinView.swift
//  ps-challenge
//
//  Created by Cagri Sahan on 3/24/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit
import MapKit

class SearchResultPinView: MKMarkerAnnotationView {
    
    // MARK: Variables
    var delegate: LocationPassable?
    
    override var annotation: MKAnnotation? {
        willSet {
            guard newValue is SearchResultPin else { return }
            
            animatesWhenAdded = true
            canShowCallout = true
            markerTintColor = #colorLiteral(red: 0.05882352941, green: 0.4352941176, blue: 0.9058823529, alpha: 1)
            glyphImage = #imageLiteral(resourceName: "searchIcon")
            
            let saveButton = UIButton(type: .contactAdd)
            saveButton.tintColor = UIColor.white
            saveButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            saveButton.backgroundColor = #colorLiteral(red: 0.05882352941, green: 0.4352941176, blue: 0.9058823529, alpha: 1)
            saveButton.addTarget(self, action: #selector(sendLocation), for: .touchUpInside)
            leftCalloutAccessoryView = saveButton
        }
    }
    
    // MARK: Functions
    @objc func sendLocation() {
        delegate?.writePinFromSearch(location: self.annotation as! SearchResultPin)
    }
}


