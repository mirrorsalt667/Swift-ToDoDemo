//
//  ToDoDemoTableViewController.swift
//  Unidirection Data Flow
//
//  Created by Stephen003 on 2023/10/2.
//

import UIKit

let todoCellReuseId = "ToDoDemoTableViewCell"
let inputCellReuseId = "InputTableViewCell"
let titleCellReuseId = "TitleTableViewCell"

final class ToDoDemoTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var store: Store<Action, State, Command>!
    
    /// Reducer 部分
    /// 狀態管理
    struct State: StateType {
        var dataSource = TableViewControllerDataSource( // 獨立封裝 data source
            todos: [], // 存放 table 資料
            owner: nil // tableViewController
        )
        var text: String = "" // text field 輸入文字
    }
    
    /// Reducer 部分
    /// User Action使用者動作
    enum Action: ActionType {
        case updateText(text: String) // text field 更新時
        case addToDos(items: [String]) // todos 增加
        case removeToDo(index: Int) // todos 移除
        case loadToDos // 載入 todos 項目
    }
    
    /// Reducer 部分
    /// 狀態管理
    /// 注意 Command 中包含的 loadToDos 成员，它关联了一个方法作为结束时的回调，我们稍后会在这个方法里向 store 发送 .addToDos 的 Action。
    enum Command: CommandType {
        case loadToDos(completion: ([String]) -> Void)
        // 看起來是在 第一次 載入時用到
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 在此刻 owner 被指為自己
        let dataSource = TableViewControllerDataSource(todos: [], owner: self)
        store = Store<Action, State, Command>(reducer: reducer, initialState: State(dataSource: dataSource, text: ""))
        
        // 訂閱 store
        store.subscribe { [weak self] state, previousState, command in
            self?.stateDidChanged(state: state, previousState: previousState, command: command)
        }
        
        // 初始化UI
        stateDidChanged(state: store.state, previousState: nil, command: nil)
        
        // 開始非同步加載 ToDos
        store.dispatch(.loadToDos)
    }
    
    // MARK: Methods
    
    /// 添加待辦
    func addButtonPressed() {
        store.dispatch(.addToDos(items: [store.state.text]))
        store.dispatch(.updateText(text: ""))
    }
    
    /// 為了避免 reducer 持有 self
    /// 所以使用 lazy 且 標記 self 為 weak 引用
    lazy var reducer: (State, Action) -> (state: State, command: Command?) = { [weak self] (state: State, action: Action) in
        var state = state
        var command: Command? = nil
        
        switch action {
        case .updateText(text: let text):
            state.text = text
        case .addToDos(items: let items):
            state.dataSource = TableViewControllerDataSource(todos: items + state.dataSource.todos, owner: state.dataSource.owner)
        case .removeToDo(index: let index):
            let oldTodos = state.dataSource.todos
            state.dataSource = TableViewControllerDataSource(todos: Array(oldTodos[..<index] + oldTodos[(index + 1)...]), owner: state.dataSource.owner)
        case .loadToDos:
            command = Command.loadToDos(completion: { data in
                // 發送額外的 .addToDos
                self?.store.dispatch(.addToDos(items: data))
            })
        }
        
        return (state, command)
    }
    
    /// 只要 store 狀態改變，都會調用此函式
    func stateDidChanged(state: State, previousState: State?, command: Command?) {
        if let command = command {
            switch command {
            case .loadToDos(let handler):
                ToDoStore.shared.getToDoItems(compeltionHandler: handler)
            }
        }
        
        if previousState == nil || previousState!.dataSource.todos != state.dataSource.todos {
            let dataSource = state.dataSource
            tableView.dataSource = dataSource
            tableView.reloadData()
            title = "TODO - (\(dataSource.todos.count))"
        }
        
        if previousState == nil || previousState!.text != state.text {
            // 改變 ADD 按鈕狀態
            let titleIndexPath = IndexPath(row: 0, section: TableViewControllerDataSource.Section.title.rawValue)
            guard let titleCell = tableView.cellForRow(at: titleIndexPath) as? TableViewTitleAddCell,
                  let btn = titleCell.addRowBtn
            else {
                return
            }
            let isItemLengthEnough = state.text.count >= 3
            btn.isEnabled = isItemLengthEnough
            
            // 改變 input text
            let inputIndexPath = IndexPath(row: 0, section: TableViewControllerDataSource.Section.input.rawValue)
            let inputCell = tableView.cellForRow(at: inputIndexPath) as? TableViewInputCell
            inputCell?.textField.text = state.text
        }
    }
    
    
    // MARK: Table View
    
    // 移除待辦
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == TableViewControllerDataSource.Section.todos.rawValue else {
            return
        }
        store.dispatch(.removeToDo(index: indexPath.row))
    }
}

// MARK: - Delegate

extension ToDoDemoTableViewController: TableViewInputCellDelegate, TableViewAddActionDelegate, UITextFieldDelegate {
    
    func inputChanged(cell: TableViewInputCell, text: String) {
        store.dispatch(.updateText(text: text))
    }
    
    func addAction(cell: TableViewTitleAddCell) {
        addButtonPressed()
    }
}
