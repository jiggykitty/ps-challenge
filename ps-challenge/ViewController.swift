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

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Move the menu out of the screen
        hamburgerMenuLeadingEdge.constant = -hamburgerMenuView.frame.width
        
        locationManager.requestWhenInUseAuthorization()
        
        if !FileWriter.shared.localDataExists() {
            do {
                annotations = try FileWriter.shared.readDemoData()
            }
            catch { showErrorDialogue(message: error.localizedDescription) }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
}
