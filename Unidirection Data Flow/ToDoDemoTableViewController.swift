//
//  ToDoDemoTableViewController.swift
//  Unidirection Data Flow
//
//  Created by Stephen003 on 2023/10/2.
//

import UIKit

final class ToDoDemoTableViewController: UITableViewController {
    var todos: [String] = []
    let todoCellReuseId = "ToDoDemoTableViewCell"
    let inputCellReuseId = "InputTableViewCell"
    let titleCellReuseId = "TitleTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ToDoStore.shared.getToDoItems { data in
            self.todos += data
            self.title = "TODO - (\(self.todos.count))"
            self.tableView.reloadData()
        }
    }
    
    /// 為了讓程式碼清晰表意自解释，在 TableViewController 里内嵌一个 Section 枚舉：
    enum Section: Int {
        // 數字從零開始，以此類推
        case title = 0, input, todos, max
    }
    
    // 添加待辦
    func addButtonPressed() {
        let inputIndexPath = IndexPath(row: 0, section: Section.input.rawValue)
        guard let inputCell = tableView.cellForRow(at: inputIndexPath) as? TableViewInputCell,
              let text = inputCell.textField.text
        else {
            return
        }
        todos.insert(text, at: 0)
        inputCell.textField.text = ""
        title = "TODO - (\(todos.count))"
        tableView.reloadData()
    }
    
    // 移除待辦
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == Section.todos.rawValue else {
            return
        }
        
        todos.remove(at: indexPath.row)
        title = "TODO - (\(todos.count))"
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.max.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        // 4個 section
        switch section {
        case .title: return 1
        case .input: return 1
        case .todos: return todos.count
        case .max: fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .title: // 返回 title cell
            let cell = tableView.dequeueReusableCell(withIdentifier: titleCellReuseId, for: indexPath) as! TableViewTitleAddCell
            cell.delegate = self
            cell.rowTitleLabel.text = "TODO - (\(todos.count))"
            cell.addRowBtn.isEnabled = false
            return cell
            
        case .input: // 返回 input cell
            let cell = tableView.dequeueReusableCell(withIdentifier: inputCellReuseId, for: indexPath) as! TableViewInputCell
            cell.delegate = self
            cell.textField.delegate = self
            return cell
            
        case .todos: // 返回 todo item cell
            let cell = tableView.dequeueReusableCell(withIdentifier: todoCellReuseId, for: indexPath)
            cell.textLabel?.text = todos[indexPath.row]
            return cell
        default: fatalError()
        }
    }
}

extension ToDoDemoTableViewController: TableViewInputCellDelegate, TableViewAddActionDelegate, UITextFieldDelegate {
    
    func inputChanged(cell: TableViewInputCell, text: String) {
        let inputIndexPath = IndexPath(row: 0, section: Section.title.rawValue)
        guard let titleCell = tableView.cellForRow(at: inputIndexPath) as? TableViewTitleAddCell,
              let btn = titleCell.addRowBtn
        else {
            return
        }
        let isItemLengthEnough = text.count >= 3
        btn.isEnabled = isItemLengthEnough
    }
    
    func addAction(cell: TableViewTitleAddCell) {
        addButtonPressed()
    }
}
