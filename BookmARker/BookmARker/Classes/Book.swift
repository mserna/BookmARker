//
//  Book.swift
//  BookmARker
//
//  Created by Matthew Serna on 12/12/17.
//  Copyright © 2017 Matthew Serna. All rights reserved.
//

import UIKit

struct Book {
    
    var title: String
    var description: String
    var image: UIImage
    
    
    init(title: String, description: String, image: UIImage) {
        self.title = title
        self.description = description
        self.image = image
    }
    
    init?(dictionary: [String: String]) {
        guard let title = dictionary["Title"], let description = dictionary["Description"], let photo = dictionary["Photo"],
            let image = UIImage(named: photo) else {
                return nil
        }
        self.init(title: title, description: description, image: image)
    }
    
    static func allBooks() -> [Book] {
        var books = [Book]()
        guard let URL = Bundle.main.url(forResource: "Books", withExtension: "plist"),
            let booksFromPlist = NSArray(contentsOf: URL) as? [[String:String]] else {
                return books
        }
        for dictionary in booksFromPlist {
            if let book = Book(dictionary: dictionary) {
                books.append(book)
            }
        }
        return books
    }
    
}
