//
//  Category.swift
//  Todoey
//
//  Created by User on 21/11/22.
//

import Foundation
import RealmSwift

class Category: Object{
    @Persisted var name: String = ""
    @Persisted var items: List<Item>
}
