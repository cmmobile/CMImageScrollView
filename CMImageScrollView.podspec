
Pod::Spec.new do |spec|


  spec.name         = "CMImageScrollView"
  spec.version      = "0.1.0"
  spec.summary      = "This image scroll view can easily zoom in, zoom out an iamge."

  spec.description  = "You can pass an image, or declare which view you want to show detail image."

  spec.homepage     = "https://github.com/cmmobile/CMImageScrollView"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "CMoney" => "mobile@cmoney.com.tw" }
  spec.social_media_url   = "https://www.cmoney.tw/app/"

#   spec.platform     = :ios
#   spec.platform     = :ios, "10.0"

  #  When using multiple platforms
  spec.ios.deployment_target = "10.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"


  spec.source       = { :git => "https://github.com/cmmobile/CMImageScrollView.git", :tag => spec.version }

  spec.exclude_files = 'DemoCMImageScrollView/**/*.*','DemoCMImageScrollView/*.*'
  
  spec.source_files = 'CMImageScrollView/CMImageScrollView/*.{h,m,swift}','CMImageScrollView/CMImageScrollView/**/*.{h,m,swift}'
  spec.framework = 'UIKit'
  spec.resource_bundles = {
    'CMImageScrollView' => ['CMImageScrollView/CMImageScrollView/Assets/*.*']
  }
  
  spec.swift_versions = ['4.2', '5.0', '5.1', '5.2']
  
end
