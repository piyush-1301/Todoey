//
//  Item.swift
//  Todoey
//
//  Created by User on 21/11/22.
//

import Foundation
import RealmSwift


class Item: Object{
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    @Persisted var dateCreated: Date = Date()
    @Persisted var color: String = "#FFFFFF"
    @Persisted(originProperty: "items") var person: LinkingObjects<Category>
}
