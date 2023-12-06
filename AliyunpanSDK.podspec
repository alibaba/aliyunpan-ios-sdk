Pod::Spec.new do |s|
    s.name = 'AliyunpanSDK'
    s.version = '0.1.0'
    s.license = 'MIT'
    s.summary = 'Aliyunpan iOS SDK'
    s.homepage = 'https://github.com/alibaba/aliyunpan-ios-sdk'
    s.authors = { 'zhaixian' => 'zixuan.wzx@alibaba-inc.com' }
    s.source = { :git => 'https://github.com/alibaba/aliyunpan-ios-sdk.git', :tag => s.version }
    s.ios.deployment_target = '13.0'
    s.swift_versions = ['5']
    s.source_files = 'Sources/**/*.swift'
  end
  
