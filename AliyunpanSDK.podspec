Pod::Spec.new do |spec|
  spec.name         = "AliyunpanSDK"
  spec.version      = "0.1.2"
  spec.summary      = "Aliyunpan OpenSDK-iOS"

  spec.description  = <<-DESC
  Aliyunpan OpenSDK-iOS
                   DESC
  spec.homepage     = "https://github.com/alibaba/aliyunpan-ios-sdk"
  spec.license      = "MIT"
  spec.author       = { "zhaixian" => "zixuan.wzx@alibaba-inc.com" }

  spec.platform     = :ios, "13.0"
  spec.swift_versions = '5.0'

  spec.source       = { :git => "https://github.com/alibaba/aliyunpan-ios-sdk.git", :tag => "#{spec.version}" }

  spec.source_files  = "Sources/**/*.swift"
  spec.ios.framework  = 'UIKit'
end
