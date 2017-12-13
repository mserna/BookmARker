//
//  CustomCollectionViewCell.swift
//  BookmARker
//
//  Created by Matthew Serna on 12/12/17.
//  Copyright © 2017 Matthew Serna. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookmarkCounter: UITextView!
    @IBOutlet weak var currentlyReading: UITextView!
    
    var isCurrentlyReading : Bool = false
    var counter: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bookmarkCounter.layer.borderWidth = 1
        bookmarkCounter.layer.borderColor = UIColor.black as! CGColor
        
        currentlyReading.layer.borderWidth = 1
        currentlyReading.layer.borderColor = UIColor.black as! CGColor
    }
}
