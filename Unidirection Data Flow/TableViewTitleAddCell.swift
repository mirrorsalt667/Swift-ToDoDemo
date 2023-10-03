//
//  TableViewTitleAddCell.swift
//  Unidirection Data Flow
//
//  Created by Stephen003 on 2023/10/3.
//

import UIKit

protocol TableViewAddActionDelegate: AnyObject {
    func addAction(cell: TableViewTitleAddCell)
}

class TableViewTitleAddCell: UITableViewCell {
    weak var delegate: TableViewAddActionDelegate?
    @IBOutlet var rowTitleLabel: UILabel!
    @IBOutlet var addRowBtn: UIButton!
    
    @IBAction func addRowAction(_ sender: Any) {
        delegate?.addAction(cell: self)
    }
}
