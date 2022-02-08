//
//  LimitedListViewController.swift
//  LimitedInput
//
//  Created by jun on 2022/02/08.
//

import UIKit

fileprivate class Model {
    let title: String?
    let action:(()->())?
    init(title: String?, action:(()->())?) {
        self.title = title
        self.action = action
    }
}

public class LimitedListViewController: UITableViewController {
    private lazy var dataSource: [Model] = {
        return [Model(title: "允许输入所有字符，且长度设置为10位", action: inputAll),
                Model(title: "只能输入数字，且长度设置为5位", action: onlyInputNumber),
                Model(title: "只能输入表情，且长度设置为5位", action: onlyInputEmoji),
                Model(title: "只能输入中文和小写英文字母，且长度设置为5位", action: onlyInputChineseAndLowercaseAlphabet),
                Model(title: "金额输入(整数部分5位，小数部分8位，允许符号)", action: priceSet1),
                Model(title: "金额输入(总共5位，不允许符号)", action: priceSet2),
                Model(title: "金额输入(整数部分3位，保留2位有效位数，最多保留5位小数，允许符号)", action: priceSet3),
                Model(title: "金额输入(整数部分3位，保留5位有效位数，最多保留2位小数，允许符号)", action: priceSet4),
                Model(title: "金额输入(整数部分3位，保留2位有效位数，最多保留0位小数，允许符号)，此时输入不了小数", action: priceSet5),]
    }()
    public override func viewDidLoad() {
        super.viewDidLoad()
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
        let model = dataSource[indexPath.row]
        cell?.text = model.title
        cell?.accessoryType = .disclosureIndicator
        return cell ?? UITableViewCell()
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        model.action?()
    }
}

extension LimitedListViewController {
    private func inputAll() {
        let vc = LimitedViewController()
        vc.label.text = "允许输入所有字符，且长度设置为10位"
        vc.textField.limitedInput.generalPolicy = .all
        vc.textField.limitedInput.maxLength = 10
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func onlyInputNumber() {
        let vc = LimitedViewController()
        vc.label.text = "只能输入数字，且长度设置为5位"
        vc.textField.limitedInput.generalPolicy = [.number]
        vc.textField.limitedInput.maxLength = 5
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func onlyInputEmoji() {
        let vc = LimitedViewController()
        vc.label.text = "只能输入表情，且长度设置为5位"
        vc.textField.limitedInput.generalPolicy = [.emoji]
        vc.textField.limitedInput.maxLength = 5
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func onlyInputChineseAndLowercaseAlphabet() {
        let vc = LimitedViewController()
        vc.label.text = "只能输入中文和小写英文字母，且长度设置为5位"
        vc.textField.limitedInput.generalPolicy = [.chinese, .lowercaseAlphabet]
        vc.textField.limitedInput.maxLength = 5
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func priceSet1() {
        let vc = LimitedViewController()
        vc.label.text = "金额输入(整数部分5位，小数部分8位，允许符号)"
        vc.textField.limitedInput.decimalPolicy = .policy1(integerPartLength: 5, decimalPartLength: 8, allowSigned: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func priceSet2() {
        let vc = LimitedViewController()
        vc.label.text = "金额输入(总共5位，不允许符号)"
        vc.textField.limitedInput.decimalPolicy = .policy2(totalLength: 5, allowSigned: false)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func priceSet3() {
        let vc = LimitedViewController()
        vc.label.text = "金额输入(整数部分3位，保留2位有效位数，最多保留5位小数，允许符号)"
        vc.textField.limitedInput.decimalPolicy = .policy3(integerPartLength: 3, decimalReservedValidDigitLength: 2, maximumDecimalPartLength: 5, allowSigned: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func priceSet4() {
        let vc = LimitedViewController()
        vc.label.text = "金额输入(整数部分3位，保留5位有效位数，最多保留2位小数，允许符号)"
        vc.textField.limitedInput.decimalPolicy = .policy3(integerPartLength: 3, decimalReservedValidDigitLength: 5, maximumDecimalPartLength: 2, allowSigned: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func priceSet5() {
        let vc = LimitedViewController()
        vc.label.text = "金额输入(整数部分3位，保留2位有效位数，最多保留0位小数，允许符号)，此时输入不了小数"
        vc.textField.limitedInput.decimalPolicy = .policy3(integerPartLength: 3, decimalReservedValidDigitLength: 2, maximumDecimalPartLength: 0, allowSigned: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}
