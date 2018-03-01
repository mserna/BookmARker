//
//  PageReviewViewController.swift
//  BookmARker
//
//  Created by Matthew Serna on 12/12/17.
//  Copyright © 2017 Matthew Serna. All rights reserved.
//

import UIKit

class PageReviewViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var pageNumTextField: UITextField!
    @IBOutlet weak var chapterTextField: UITextField!
    @IBOutlet weak var bookImageView: UIImageView!
    var bookmark: Bookmark?
    
    var saveBookmarkDelegate: SaveBookmarkDelegate!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func cancelBookmark(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBookmark(_ sender: Any) {
        if(saveBookmarkDelegate == nil){
            print("Error - bookmark delegate nil")
            dismiss(animated: true, completion: nil)
        }else {
            saveBookmarkDelegate.displayBookmark(bookmark: bookmark!)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func applyBookmark(_ sender: Any) {
        //TODO - Needs to apply changes and import to catalog to specific book
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SaveBookmarkDelegate.self
        
        //Grab new struct data
        pageNumTextField.text = bookmark?.pageNumber
        chapterTextField.text = bookmark?.chapterNumber
        bookImageView.image = bookmark?.newBookPageImage
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

protocol SaveBookmarkDelegate {
    func displayBookmark(bookmark: Bookmark)
}
