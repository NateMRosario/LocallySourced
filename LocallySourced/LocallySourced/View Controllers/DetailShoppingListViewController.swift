//
//  DetailShoppingListViewController.swift
//  LocallySourced
//
//  Created by C4Q on 3/3/18.
//  Copyright © 2018 TeamLocallySourced. All rights reserved.
//

import UIKit

class DetailShoppingListViewController: UIViewController {
    
    // MARK: - Properties
    var detailShoppingListView = DetailShoppingListView()
    let resusableCell = "ItemCell"
    var shoppingList: List! {
        didSet {
            DispatchQueue.main.async {
                self.detailShoppingListView.shoppingListTableView.reloadData()
            }
        }
    }
    
    // MARK: - Init (Dependency injection)
    var favorite: [FarmersMarket]
    init(fav: [FarmersMarket]){
        self.favorite = fav
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Mark: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        detailShoppingListView.shoppingListTableView.delegate = self
        detailShoppingListView.shoppingListTableView.dataSource = self
        configureNavBar()
        self.view.addSubview(detailShoppingListView)
        self.view.backgroundColor = .red
    }
    
    // MARK: - Functions
    //    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
    //        if !isCompleted {
    //            cell.accessoryType = .none
    //            cell.textLabel?.textColor = UIColor.black
    //            cell.detailTextLabel?.textColor = UIColor.black
    //        } else {
    //            cell.accessoryType = .checkmark
    //            cell.textLabel?.textColor = UIColor.gray
    //            cell.detailTextLabel?.textColor = UIColor.gray
    //        }
    //    }
    
    private func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.black
    }
    
    // adds items to shoppingList, via alertController
    @objc func addItem() {
        let alert = UIAlertController(title: "Grocery Item", message: "Add an Item", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let textField = alert.textFields![0]
            let item = Item(name: textField.text!, amount: 0, completed: false)
            FileManagerHelper.manager.addItem(item, toShoppingList: self.shoppingList)
            self.shoppingList.items.append(item)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource
extension DetailShoppingListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: resusableCell, for: indexPath) as! ItemCell
        let item = shoppingList.items[indexPath.row]
        cell.configureCell(with: item)
        //        toggleCellCheckbox(cell, isCompleted: item.completed)
        return cell
    }
    
    // defines tableView editing style. Set to .delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            shoppingList.items.remove(at: indexPath.row)
            FileManagerHelper.manager.removeItem(shoppingList.items[indexPath.row], fromShoppingList: self.shoppingList)
            tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension DetailShoppingListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        var groceryItem = shoppingList.items[indexPath.row]
        groceryItem.completed = !groceryItem.completed
        FileManagerHelper.manager.updateItem(groceryItem, forShoppingList: self.shoppingList)
        //        let toggledCompletion = !groceryItem.completed
        //        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        //        groceryItem.completed = toggledCompletion
        tableView.reloadData()
    }
    
    // allows tableview row editing
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension DetailShoppingListViewController: ItemCellDelegate {
    func stepperButtonPressed() {

    }
    
    func checkedButtonPressed() {
        
    }
    
    
}

