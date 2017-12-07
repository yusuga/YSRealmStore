Pod::Spec.new do |s|
  s.name = 'YSRealmStore'
  s.version = '0.11.0'
  s.summary = 'Simple wrapper for Realm Cocoa.'
  s.homepage = 'https://github.com/yusuga/YSRealmStore'
  s.license = 'MIT'
  s.author = 'Yu Sugawara'
  s.social_media_url = 'https://twitter.com/yusuga_'
  s.source = { :git => 'https://github.com/yusuga/YSRealmStore.git', :tag => s.version.to_s }
  s.platform = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.source_files = 'Classes/YSRealmStore/*.{h,m}'
  s.requires_arc = true
  s.compiler_flags = '-fmodules'
  
  s.dependency 'Realm', '~> 3.0'
  
  s.subspec 'Category' do |ss|
    ss.source_files = 'Classes/YSRealmStore/Category/*.{h,m}'
  end
end