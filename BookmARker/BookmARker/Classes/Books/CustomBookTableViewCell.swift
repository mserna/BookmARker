//
//  CustomBookTableViewCell.swift
//  BookmARker
//
//  Created by Matthew Serna on 12/16/17.
//  Copyright © 2017 Matthew Serna. All rights reserved.
//

import UIKit

class CustomBookTableViewCell: UITableViewCell {

    @IBOutlet weak var customBookView: UIView!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var bookTitleView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
