#
#  Be sure to run `pod spec lint LimitedInput.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name                   = 'SimpleInput-Swift'
  spec.version                = '0.0.2'
  spec.homepage               = 'https://github.com/liujunliuhong/SimpleInput'
  spec.source                 = { :git => 'https://github.com/liujunliuhong/SimpleInput.git', :tag => spec.version }
  spec.summary                = 'Lightweight input control handling in Swift'
  spec.license                = { :type => 'MIT', :file => 'LICENSE' }
  spec.author                 = { 'liujunliuhong' => '1035841713@qq.com' }
  spec.module_name            = 'SimpleInput'
  spec.swift_version          = '5.0'
  spec.platform               = :ios, '10.2'
  spec.ios.deployment_target  = '10.2'
  spec.requires_arc           = true
  spec.static_framework       = true
  
  spec.subspec 'Limited' do |ss|
    ss.source_files = 'Sources/Limited/*.swift'
  end

  spec.subspec 'Placeholder' do |ss|
    ss.source_files = 'Sources/Placeholder/*.swift'
  end

end
