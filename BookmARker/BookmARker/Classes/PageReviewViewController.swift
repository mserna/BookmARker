//
//  PageReviewViewController.swift
//  BookmARker
//
//  Created by Matthew Serna on 12/12/17.
//  Copyright © 2017 Matthew Serna. All rights reserved.
//

import UIKit

class PageReviewViewController: UIViewController {

    @IBAction func cancelBookmark(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyBookmark(_ sender: Any) {
        //TODO - Needs to apply changes and import to catalog to specific book
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
