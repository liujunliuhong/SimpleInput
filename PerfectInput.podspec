#
#  Be sure to run `pod spec lint LimitedInput.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name                   = "LimitedInput"
  spec.homepage               = 'https://github.com/liujunliuhong/LimitedInput'
  spec.source                 = { :git => 'https://github.com/liujunliuhong/LimitedInput.git', :tag => "#{spec.version}" }
  spec.version                = "0.0.1"
  spec.summary                = "UITextField、UITextView输入限制"
  spec.description            = "UITextField、UITextView长度限制，指定输入内容"
  spec.license                = { :type => 'MIT', :file => 'LICENSE' }
  spec.author                 = { 'liujunliuhong' => '1035841713@qq.com' }
  spec.platform               = :ios, '10.0'
  spec.module_name            = 'LimitedInput'
  spec.swift_version          = '5.0'
  spec.ios.deployment_target  = '10.0'
  spec.requires_arc           = true
  spec.static_framework       = true
  spec.source_files           = "Sources/*.swift"
end
