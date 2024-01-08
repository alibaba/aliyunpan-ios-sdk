Pod::Spec.new do |spec|
  spec.name         = "AliyunpanSDK"
  spec.version      = "0.1.14"
  spec.summary      = "Aliyunpan OpenSDK-iOS"

  spec.description  = <<-DESC
  Aliyunpan OpenSDK-iOS
                   DESC
  spec.homepage     = "https://github.com/alibaba/aliyunpan-ios-sdk"
  spec.license      = "MIT"
  spec.author       = { "zhaixian" => "zixuan.wzx@alibaba-inc.com" }

  spec.swift_versions = '5.0'
  
  spec.ios.deployment_target = "13.0"
  spec.tvos.deployment_target = "13.0"
  spec.osx.deployment_target = "10.15"
  
  spec.source       = { :git => "https://github.com/alibaba/aliyunpan-ios-sdk.git", :tag => "v#{spec.version}" }

  spec.source_files  = "Sources/**/*.swift"
end
