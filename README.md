# SimpleInput
&emsp;&emsp;在平时开发中，经常会对输入控件(`UITextField`、`UITextView`)做一些处理，比如设置占位符，设置允许输入的最大长度，设置只能输入数字等等。这些功能谈不上多复杂，你可能也做过一些简单的封装，不过你可能仅仅只是针对某些情况做的封装，不够全面。<br>
&emsp;&emsp;我在开发中就是这个样子的，每次遇到类似功能都要去写很多重复代码。之前也曾想过写个轮子，把对输入控件的处理封装起来，但是由于需求千变万化，且功能不复杂，网上有很多类似代码，也就懒得写了。但是总这样下去也不行啊，所以自己动手，写了这个轮子。

## 主要功能
- 支持`UITextField`和`UITextView`这两大输入控件的输入处理
- 支持设置占位符文字、占位符文本颜色、占位符文本字体、属性占位符
- 支持设置最大长度
- 支持中文、表情、数字、小写字母、大写字母的多种组合限制
- 支持正则表达式对输入做限制
- 支持浮点类型（支持形如`+1.23`、`-0.25`这种带有符号的浮点形式）
- 支持实时文本回调


## 安装
推荐使用`CocoaPods`
```
pod 'SimpleInput'
```

## 使用
### 设置占位符
针对`UITextField`来说，系统已经自带`placeholder`属性，但是不能自定义`placeholder`的颜色和字体，除非设置`attributedPlaceholder`<br>
请使用`PlaceholderTextField`，`PlaceholderTextField`继承自`UITextField`

```
let textField = PlaceholderTextField()
textField.placeholder = "请输入文本"
textField.placeholderTextColor = UIColor.cyan
textField.textColor = UIColor.red
textField.font = UIFont.systemFont(ofSize: 17)
```


针对`UITextView`来说，系统没有提供`placeholder`属性。<br>
请使用`PlaceholderTextView`，`PlaceholderTextView`继承自`UITextView`

```
let textView = PlaceholderTextView()
textView.placeholder = "请输入文本"
textView.placeholderTextColor = UIColor.cyan
textView.font = UIFont.systemFont(ofSize: 17)
textView.textColor = UIColor.orange
```

### 输入限制
支持`UITextField`和`UITextView`，下面以`UITextField`为例，`UITextView`使用和`UITextField`相同<br>

如果你想设置最大长度
```
textField.limitedInput.maxLength = 10 // 设置为0，表示无限长度
```

如果你想设置为只能输入中文，可以设置`generalPolicy`属性
```
textField.limitedInput.generalPolicy = [.chinese]
```

如果你想输入金额或者浮点类型，可以设置`decimalPolicy`属性
```
limitedInput.decimalPolicy = .policy1(integerPartLength: 5, decimalPartLength: 8, allowSigned: true)
```

如果你觉得框架自带的输入限制满足不了你的需求，你可以自定义正则
```
textField.limitedInput.regex = "^1[a-zA-Z]*" // 以1开头，后面只能输入字母
```

### 实时输入回调
```
// 实时文本回调有3种
// processChangeClosure: 原始文本实时回调
// processRealChangeClosure: 真实文本回调(对decimalPolicy做了处理)
// processRealDecimalChangeClosure: 真实小数策略文本回调(对decimalPolicy做了处理)
textField.limitedInput.processChangeClosure { text in
    print("原始文本:\(text ?? "")")
}
```
针对实时文本回调做下说明：

- processChangeClosure

原始文本实时回调。也就是说，返回的是输入控件的值
<br>

- processRealChangeClosure

真实文本回调
对`decimalPolicy`做了处理，如果`decimalPolicy`为空，返回的是输入控件的值
比如`0.120 => 0.12`，把尾部的0去掉了
比如`5. => 5`，把尾部的小数点去掉了
比如`+ => nil`，只输入一个`+`，返回的其实是`nil`
也就是说，返回的是合法的且是最精简的数
<br>

- processRealDecimalChangeClosure

在`processRealChangeClosure`的基础上做了进一步处理
比如`decimalPolicy`设置为`.policy1(integerPartLength: 2, decimalPartLength: 3, allowSigned: false)`，输入控件此时值为`2.3`，那么此时返回的是`2.300`

<br>
更多使用方法请查看`Demo`和源码注释

## 补充
&emsp;&emsp;我是想把该轮子写的非常完善，不过由于本人才疏学浅，还需要各位大神多多指教。在使用过程中，有任何建议或问题，欢迎提issue，或者通过邮箱1035841713@qq.com联系我。<br>
&emsp;&emsp;喜欢就star❤️一下吧

