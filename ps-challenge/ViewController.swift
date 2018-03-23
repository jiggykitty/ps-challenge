//
//  ViewController.swift
//  ps-challenge
//
//  Created by Cagri Sahan on 3/20/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit
import MapKit

class mapViewController: UIViewController {
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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Move the menu out of the screen
        hamburgerMenuLeadingEdge.constant = -hamburgerMenuView.frame.width
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        searchBar.delegate = self
        
        
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

extension mapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
            
        else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = #imageLiteral(resourceName: "parkingIcon")
            annotationView.canShowCallout = true
            return annotationView
        }
    }
}

extension mapViewController: CLLocationManagerDelegate {
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

extension mapViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension mapViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
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
        searchBar.resignFirstResponder()
        navController?.dismiss(animated: true, completion: nil)
    }
}

extension mapViewController: LocationPassable {
    func passLocationToWrite(location: MKAnnotation) {
        let annotation = MyPin(title: location.title, subtitle: location.subtitle, coordinate: location.coordinate)
        annotations?.append(annotation)
        do {
            try FileWriter.shared.writeData(pinList: annotations!)
        }
        catch { showErrorDialogue(message: error.localizedDescription) }
        mapView.addAnnotation(annotation)
        navController?.dismiss(animated: true, completion: nil)
        searchBar.resignFirstResponder()
    }
}
