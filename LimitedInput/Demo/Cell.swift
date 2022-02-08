//
//  Cell.swift
//  LimitedInput
//
//  Created by jun on 2022/02/08.
//

import UIKit
import SnapKit

public class Cell: UITableViewCell {
    
    public var text: String? {
        didSet {
            label.text = text
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.bottom.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
