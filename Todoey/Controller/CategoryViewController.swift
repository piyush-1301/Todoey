//
//  CategoryViewController.swift
//  Todoey
//
//  Created by User on 18/11/22.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category>?
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let navBar = navigationController?.navigationBar else{fatalError("Error loading navigation bar")}
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            self.save(category: newCategory)
        }
        
        alert.addTextField{ (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let cat = categories?[indexPath.row]{
            cell.textLabel?.text = cat.name
            if let uiColor = UIColor(hexString: cat.color){
                cell.backgroundColor = uiColor
                cell.textLabel?.textColor = ContrastColorOf(uiColor, returnFlat: true)
            }
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
            print("Error saving data \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let cat = self.categories?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(cat)
                }
            }catch{
                print("error deleting object \(error)")
            }
        }
    }
}

