//
//  AddBookViewController.swift
//  BookmARker
//
//  Created by Matthew Serna on 12/16/17.
//  Copyright © 2017 Matthew Serna. All rights reserved.
//

import UIKit

class AddBookViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var bookTitleView: UITextField!
    @IBOutlet weak var bookImageVIew: UIImageView!
    
    @IBAction func applyNewBook(_ sender: UIButton) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newBook = BookData(context: context)
        newBook.title = bookTitleView.text!
        newBook.image = bookImageVIew.image!
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        //Closes controller after apply
        let _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func cancelNewBook(_ sender: UIButton) {
        //TODO
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Dismisses keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
