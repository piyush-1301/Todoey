//
//  ViewController.swift
//  Todoey
//
//  Created by User on 09/11/22.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    var todoItems: Results<Item>?
    let realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        if let colorHex = selectedCategory?.color{
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else{fatalError("Error loading navigation bar")}
            if let uiColor = UIColor(hexString: colorHex){
                navBar.backgroundColor = uiColor
                navBar.tintColor = ContrastColorOf(uiColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(uiColor, returnFlat: true)]
                searchBar.barTintColor = uiColor
                searchBar.searchTextField.backgroundColor = .white
                
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        }else{
            cell.textLabel?.text = "No Items added"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    item.done = !item.done
                }
            }catch{
                print("error updating item \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.color = UIColor.randomFlat().hexValue()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving new Items \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField{ (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }

    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated")
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(item)
                }
            }catch{
                print("error deleting object \(error)")
            }
        }
    }
    
   
    
}

extension TodoListViewController: UISearchBarDelegate{

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        } else {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated")
        }
        tableView.reloadData()
    }
}



