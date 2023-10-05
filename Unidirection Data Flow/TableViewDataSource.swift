//
//  TableViewDataSource.swift
//  Unidirection Data Flow
//
//  Created by Stephen003 on 2023/10/3.
//

import Foundation
import UIKit

/// 把 dataSource 提取出來
final class TableViewControllerDataSource: NSObject, UITableViewDataSource {
    
    var todos: [String]
    weak var owner: ToDoDemoTableViewController?
    
    /// 為了讓程式碼清晰表意自解释，在 TableViewController 里内嵌一个 Section 枚舉：
    enum Section: Int {
        // 數字從零開始，以此類推
        case title = 0, input, todos, max
    }
    
    init(todos: [String], owner: ToDoDemoTableViewController?) {
        self.todos = todos
        self.owner = owner
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.max.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        switch section {
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: titleCellReuseId, for: indexPath) as! TableViewTitleAddCell
            cell.delegate = owner
            cell.rowTitleLabel.text = "TODO - (\(todos.count))"
            cell.addRowBtn.isEnabled = false
            return cell
        case .input:
            let cell = tableView.dequeueReusableCell(withIdentifier: inputCellReuseId, for: indexPath) as! TableViewInputCell
            cell.delegate = owner
            cell.textField.delegate = owner
            return cell
        case .todos:
            let cell = tableView.dequeueReusableCell(withIdentifier: todoCellReuseId, for: indexPath)
            cell.textLabel?.text = todos[indexPath.row]
            return cell
        case .max:
            fatalError()
        }
    }
}
