#
#  Be sure to run `pod spec lint CedCirCleView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "CedCircleView"
  s.version      = "0.0.16"
  s.summary      = "A pure Swift framework for cyclical view like bannerView"
  s.description  = <<-DESC
  A pure Swift framework for cyclical view like bannerView.
  often used for banner
                   DESC
  s.homepage     = "https://github.com/gssdromen/CedCircleView/"
  s.license      = "MIT"
  s.author             = { "wuyinjun" => "wuyinjun@fangdd.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/gssdromen/CedCircleView.git", :tag => "#{s.version}" }
  s.source_files  = "CedCircleView/**/*.swift"
  s.requires_arc = true
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }

end
