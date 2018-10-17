

Pod::Spec.new do |s|

  s.name         = "HLHJFactModuleSDK"
  s.version      = "1.0.0"

  s.summary      = "爆料爆料爆料"
  s.description  = <<-DESC
                   "爆料爆料爆料"
                   DESC

  s.platform =   :ios, "9.0"
  s.ios.deployment_target = "8.0"

  s.homepage     = "https://github.com/zaijianrumo/HLHJFactModuleSDK"
  s.source       = { :git => "https://github.com/zaijianrumo/HLHJFactModuleSDK.git", :tag => "1.0.0"  }
  s.source_files = "HLHJFactModuleSDK"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "zaijianrumo" => "2245190733@qq.com" }
  s.requires_arc  = true


  s.dependency            "AFNetworking","~>3.2.0"
  s.dependency            "IQKeyboardManager","~>6.0.4"
  s.dependency            "MBProgressHUD","~>1.1.0"
  s.dependency            "MJRefresh","~>3.1.15.3"
  s.dependency            "SDCycleScrollView","~>1.75"
  s.dependency            "SDAutoLayout","~>2.2.0"
  s.dependency            "YYModel","~>1.0.4"
  s.dependency            "SDWebImage","~>4.3.3"
  s.dependency            "TZImagePickerController","~>2.0.1"
  s.dependency            "ZFPlayer","~>3.0.9.1"

 end