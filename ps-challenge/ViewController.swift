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
    weak var resultTable: UITableViewController!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Move the menu out of the screen
        hamburgerMenuLeadingEdge.constant = -hamburgerMenuView.frame.width
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        
        if !FileWriter.shared.localDataExists() {
            do {
                annotations = try FileWriter.shared.readDemoData()
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

extension mapViewController: UISearchBarDelegate, TableRefresher, UIPopoverPresentationControllerDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let tableVC = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "SearchResultTableTableViewController") as! SearchResultTableTableViewController
        tableVC.searchString = searchBar.text
        self.resultTable = tableVC
        var nav = UINavigationController(rootViewController: tableVC)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        var popover = nav.popoverPresentationController!
        tableVC.preferredContentSize = CGSize(width: 500, height: 600)
        popover.delegate = self
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: 100, y: 100, width: 0, height: 0)
        
        self.present(nav, animated: true, completion: nil)
    }
    
    func refreshTableViewController() {
        resultTable.tableView.reloadData()
    }
}
