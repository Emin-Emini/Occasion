//
//  AddEventAnchorViewController.swift
//  Occasion
//
//  Created by Emin Emini on 10.4.20.
//  Copyright © 2020 Emin Emini. All rights reserved.
//

import UIKit

class AddEventAnchorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let addEventVC: AddEventViewController =
            self.storyboard!.instantiateViewController(withIdentifier: "AddEventViewController") as! AddEventViewController
        
        self.present(addEventVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.tabBarController?.selectedIndex = previousViewIndex
        
        
        
        
        self.tabBarController?.selectedIndex = previousViewIndex
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.tabBarController?.selectedIndex = previousViewIndex
    }

}
