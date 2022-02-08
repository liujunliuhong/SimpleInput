//
//  ViewController.swift
//  LimitedInput
//
//  Created by jun on 2022/01/29.
//

import UIKit

public class ViewController: UITableViewController {
    
    private var dataSource: [String] {
        return ["文本限制",
                "输入占位"]
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Demo"
        view.backgroundColor = .white
        tableView.rowHeight = 55.0
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .always
        } else {
            automaticallyAdjustsScrollViewInsets = true
        }
        tableView.register(Cell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(Cell.classForCoder()))
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Cell.classForCoder())) as? Cell
        cell?.text = dataSource[indexPath.row]
        cell?.accessoryType = .disclosureIndicator
        return cell ?? UITableViewCell()
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let vc = LimitedListViewController()
            vc.navigationItem.title = dataSource[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            let vc = PlaceholderViewController()
            vc.navigationItem.title = dataSource[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
