//
//  CatalogViewController.swift
//  BookmARker
//
//  Created by Matthew Serna on 12/12/17.
//  Copyright © 2017 Matthew Serna. All rights reserved.
//

import UIKit

class CatalogViewController: UIViewController {
    
    @IBOutlet weak var bookTableView: UITableView!
    
    var bookArray = [BookData]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func addBook(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addBookSegue", sender: nil)
    }
    
    @IBAction func doneWithBooks(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookTableView.dataSource = self
        bookTableView.delegate = self
        bookTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
        bookTableView.reloadData()
    }
    
    func getData() {
        do {
            bookArray = try context.fetch(BookData.fetchRequest())
        }catch {
            print("Couldn't fetch data!")
        }
    }
    
}

//MARK: Data Source for TableView
extension CatalogViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = CustomBookTableViewCell()
        let mBook = bookArray[indexPath.row]
        
        if let tBook = mBook.title {
            cell.bookTitleView?.text = tBook
            if bookTableView.cellForRow(at: indexPath) != nil {
                print("Book applied sucessfully!")
            }else{
                print("Error on adding new cell!")
            }
        }
        
        if let iBook = mBook.image {
            cell.bookImageView?.image = iBook as! UIImage
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete Book?", message: "Are you sure you want to delete?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                let delBook = self.bookArray[indexPath.row]
                self.context.delete(delBook)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Book Deletion Canceled")
            }))
            
            present(alert, animated: true, completion: nil)
            
            do {
                bookArray = try context.fetch(BookData.fetchRequest())
            } catch {
                print("Fetching Failed")
            }
        }
        bookTableView.reloadData()
    }
}
