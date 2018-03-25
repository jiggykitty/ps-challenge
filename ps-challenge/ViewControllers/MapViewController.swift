//
//  ViewController.swift
//  ps-challenge
//
//  Created by Cagri Sahan on 3/20/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    // MARK: IBOutlets
    
    @IBOutlet weak var hamburgerMenuView: UIView!
    @IBOutlet weak var hamburgerMenuLeadingEdge: NSLayoutConstraint!
    
    
    @IBOutlet var contentTapRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet { mapView.delegate = self }
    }
    
    // MARK: IBActions
    @IBAction func hamburgerMenuButtonPressed(_ sender: Any) {
        moveHamburgerMenu()
    }
    
    
    @IBAction func backgroundContentTapped(_ sender: Any) {
        moveHamburgerMenu()
    }
    
    
    // MARK: Variables
    var menuShouldBeOpen: Bool = false {
        didSet {
            contentTapRecognizer.isEnabled = !menuShouldBeOpen
        }
    }
    
    let locationManager = CLLocationManager()
    var annotations: [MyPin]?
    var resultTable: SearchResultTableTableViewController?
    var navController: UINavigationController?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Move the menu out of the screen
        hamburgerMenuLeadingEdge.constant = -hamburgerMenuView.frame.width
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        searchBar.delegate = self
        
        registerAnnotationViewClasses()
        
        if !FileWriter.shared.localDataExists() {
            do {
                annotations = try FileWriter.shared.readDemoData()
            }
            catch { showErrorDialogue(message: error.localizedDescription) }
        }
        else {
            do {
                annotations = try FileWriter.shared.readData()
            }
            catch { showErrorDialogue(message: error.localizedDescription) }
        }
        mapView.addAnnotations(annotations!)
    }
    
    // MARK: Functions
    func registerAnnotationViewClasses() {
        mapView.register(MySavedPinView.self, forAnnotationViewWithReuseIdentifier: "mySavedPinView")
        mapView.register(SearchResultPinView.self, forAnnotationViewWithReuseIdentifier: "searchResultPinView")
    }
    
    func moveHamburgerMenu() {
        hamburgerMenuLeadingEdge.constant = menuShouldBeOpen ? 0 : -hamburgerMenuView.frame.width
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) { [unowned self] animateCompleted in
            if animateCompleted {
                self.menuShouldBeOpen = !self.menuShouldBeOpen
            }
        }
    }
    
    func showErrorDialogue(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(actionOK)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: Extensions
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        else if annotation is MyPin {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "mySavedPinView") ?? MySavedPinView(annotation: annotation, reuseIdentifier: "mySavedPinView")
            return annotationView
        }
        else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "searchResultPinView") as? SearchResultPinView ?? SearchResultPinView(annotation: annotation, reuseIdentifier: "searchResultPinView")
            annotationView.delegate = self
            return annotationView
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showErrorDialogue(message: "Can't get user location")
    }
}

extension MapViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension MapViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // Clear previous search annotations
        let searchAnnotations = mapView.annotations.filter { $0 is SearchResultPin }
        if !searchAnnotations.isEmpty {
            self.mapView.removeAnnotations(searchAnnotations)
        }
        
        resultTable = self.storyboard?.instantiateViewController(withIdentifier: "SearchResultTableTableViewController") as? SearchResultTableTableViewController
        navController = UINavigationController(rootViewController: resultTable!)
        navController!.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = navController!.popoverPresentationController!
        resultTable?.preferredContentSize = CGSize(width: searchBar.frame.width, height: 400)
        popover.delegate = self
        popover.sourceView = searchBar.superview
        popover.sourceRect = searchBar.frame
        
        resultTable?.delegate = self
        self.present(navController!, animated: true, completion: nil)
        
        resultTable?.searchString = searchBar.text ?? ""
        resultTable?.refreshTableViewController()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resultTable?.searchString = searchBar.text ?? ""
        resultTable?.refreshTableViewController()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchQuery = searchBar.text ?? ""
        searchBar.text = ""
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchQuery
        let search = MKLocalSearch(request: request)
        search.start { [unowned self] response, error in
            guard error == nil else { self.showErrorDialogue(message: "Can't find location"); return }
            guard let response = response else { self.showErrorDialogue(message: "Can't find location"); return }
            
            // Drop pins for the first 7 results for the user to choose from
            for i in 0...min(response.mapItems.count-1, 6) {
                let annotation = response.mapItems[i].placemark
                let searchPin = SearchResultPin(title: annotation.name, subtitle: annotation.title, coordinate: annotation.coordinate)
                self.mapView.addAnnotation(searchPin)
            }
        }
        
        searchBar.resignFirstResponder()
        navController?.dismiss(animated: true, completion: nil)
    }
}

extension MapViewController: LocationPassable {
    func writePinFromCompleter(location: MyPin) {
        annotations?.append(location)
        do {
            try FileWriter.shared.writeData(pinList: annotations!)
        }
        catch { showErrorDialogue(message: error.localizedDescription) }
        mapView.addAnnotation(location)
        
        // Restore search bar
        searchBar.text = ""
        searchBar.resignFirstResponder()
        navController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func writePinFromSearch(location: SearchResultPin) {
        let myPin = MyPin(fromSearchResultPin: location)
        annotations?.append(myPin)
        do {
            try FileWriter.shared.writeData(pinList: annotations!)
        }
        catch { showErrorDialogue(message: error.localizedDescription) }
        
        // Remove other search annotations after saving one
        let searchAnnotations = mapView.annotations.filter { $0 is SearchResultPin }
        self.mapView.removeAnnotations(searchAnnotations)
        
        // Add the new annotation
        self.mapView.addAnnotation(myPin)
    }
}
