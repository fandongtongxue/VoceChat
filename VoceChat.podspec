#
# Be sure to run `pod lib lint VoceChat.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VoceChat'
  s.version          = '0.1.0'
  s.summary          = 'A short description of VoceChat.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/范东同学/VoceChat'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '范东同学' => 'admin@fandong.me' }
  s.source           = { :git => 'https://github.com/范东同学/VoceChat.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'VoceChat/Classes/**/*'
  
  # s.resource_bundles = {
  #   'VoceChat' => ['VoceChat/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  #网络请求
  s.dependency 'Alamofire', '~> 5.6.2'
  #解析JSON
  s.dependency 'HandyJSON', '~> 5.0.2'
  #Toast
  s.dependency 'Toast-Swift', '~> 5.0.1'
  #SSE
  s.dependency 'LDSwiftEventSource', '~> 3.0'
  #SQLite
  s.dependency 'SQLite.swift', '~> 0.14.0'
end
