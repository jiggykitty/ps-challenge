//
//  SearchResultTableTableViewController.swift
//  ps-challenge
//
//  Created by Cagri Sahan on 3/22/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit
import MapKit

class SearchResultTableTableViewController: UITableViewController {
    
    // MARK: Variables
    var searchString: String?
    var searchCompleter = MKLocalSearchCompleter()
    var results = [MKLocalSearchCompletion]()
    var delegate: LocationPassable?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
    }


    // MARK: TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row].title
        cell.detailTextLabel?.text = results[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let query = results[indexPath.row]
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = query.subtitle
        let search = MKLocalSearch(request: request)
        
        search.start { [unowned self] response, error in
            guard error == nil else { return }
            guard let response = response else { return }
            let annotation = response.mapItems.first!.placemark
            let pin = MyPin(title: query.title, subtitle: query.subtitle, coordinate: annotation.coordinate)
            self.delegate?.passLocationToWrite(location: pin)
        }
    }
}

// MARK: Extensions
extension SearchResultTableTableViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
        self.tableView.reloadData()
    }
}

extension SearchResultTableTableViewController: TableRefreshable {
    func refreshTableViewController() {
        searchCompleter.queryFragment = searchString!
    }
}
