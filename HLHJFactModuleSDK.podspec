

Pod::Spec.new do |s|

  s.name         = "HLHJFactModuleSDK"
  s.version      = "1.0.4"

  s.summary      = "爆料爆料爆料"
  s.description  = <<-DESC
                   "爆料爆料爆料"
                   DESC

  s.platform =   :ios, "9.0"
  s.ios.deployment_target = "9.0"

  s.homepage     = "https://github.com/zaijianrumo/HLHJFactModuleSDK"
  s.source       = { :git => "https://github.com/zaijianrumo/HLHJFactModuleSDK.git", :tag => "1.0.4"  }
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "zaijianrumo" => "2245190733@qq.com" }
  s.requires_arc  = true


  s.source_files            = 'HLHJFramework/HLHJFactModuleSDK.framework/Headers/*.{h,m}'
  s.ios.vendored_frameworks = 'HLHJFramework/HLHJFactModuleSDK.framework'
  s.resources               = 'HLHJFramework/imgBundle.bundle'

  s.xcconfig = {'VALID_ARCHS' => 'arm64 x86_64'}

  s.dependency            "AFNetworking"
  s.dependency            "IQKeyboardManager"
  s.dependency            "MBProgressHUD"
  s.dependency            "MJRefresh"
  s.dependency            "SDCycleScrollView"
  s.dependency            "SDAutoLayout"
  s.dependency            "YYModel"
  s.dependency            "SDWebImage"
  s.dependency            "TZImagePickerController"
  s.dependency            "ZFPlayer"
  s.dependency            "TMUserCenter"

 end