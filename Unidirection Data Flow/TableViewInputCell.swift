//
//  TableViewInputCell.swift
//  Unidirection Data Flow
//
//  Created by Stephen003 on 2023/10/3.
//

import UIKit

protocol TableViewInputCellDelegate: AnyObject {
    func inputChanged(cell: TableViewInputCell, text: String)
}

class TableViewInputCell: UITableViewCell {
    weak var delegate: TableViewInputCellDelegate?
    @IBOutlet var textField: UITextField!
    
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        delegate?.inputChanged(cell: self, text: sender.text ?? "")
    }
}
