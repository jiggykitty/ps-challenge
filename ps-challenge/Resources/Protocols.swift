//
//  Protocols.swift
//  ps-challenge
//
//  Created by Cagri Sahan on 3/22/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import MapKit

protocol TableRefreshable {
    func refreshTableViewController()
}

protocol LocationPassable {
    func writePinFromCompleter(location: MyPin)
    func writePinFromSearch(location: SearchResultPin)
}
