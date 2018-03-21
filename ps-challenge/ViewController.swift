//
//  ViewController.swift
//  ps-challenge
//
//  Created by Cagri Sahan on 3/20/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit

class mapViewController: UIViewController {
    //MARK: IBOutlets
    
    @IBOutlet weak var hamburgerMenuView: UIView!
    @IBOutlet weak var hamburgerMenuLeadingEdge: NSLayoutConstraint!
    
    @IBOutlet var contentTapRecognizer: UITapGestureRecognizer!
    @IBOutlet var windowPanRecognizer: UIPanGestureRecognizer!
    
    
    @IBAction func hamburgerMenuButtonPressed(_ sender: Any) {
        moveHamburgerMenu()
    }
    
    
    @IBAction func backgroundContentTapped(_ sender: Any) {
        moveHamburgerMenu()
    }
    
    @IBAction func windowPannedLeft(_ sender: Any) {
        moveHamburgerMenu()
    }
    
    var menuShouldBeOpen: Bool = false {
        didSet {
            contentTapRecognizer.isEnabled = !menuShouldBeOpen
            contentTapRecognizer.isEnabled = !menuShouldBeOpen
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        hamburgerMenuLeadingEdge.constant = -hamburgerMenuView.frame.width
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
}

