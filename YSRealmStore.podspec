Pod::Spec.new do |s|
  s.name = 'YSRealmStore'
  s.version = '0.3.1'
  s.summary = 'Realm helper.'
  s.homepage = 'https://github.com/yusuga/YSRealmStore'
  s.license = 'MIT'
  s.author = 'Yu Sugawara'
  s.source = { :git => 'https://github.com/yusuga/YSRealmStore.git', :tag => s.version.to_s }
  s.platform = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.source_files = 'Classes/YSRealmStore/*.{h,m}'
  s.requires_arc = true
  s.compiler_flags = '-fmodules'
  
  s.dependency 'Realm', '0.88.0'
  s.dependency 'CocoaLumberjack', '~> 2.0.0-rc'
  
  s.prefix_header_contents = "#import <CocoaLumberjack/CocoaLumberjack.h>
#ifdef DEBUG
    static const DDLogLevel ddLogLevel = DDLogLevelAll;
#else
    static const DDLogLevel ddLogLevel = DDLogLevelError;
#endif"

  s.subspec 'Category' do |ss|
    ss.source_files = 'Classes/YSRealmStore/Category/*.{h,m}'
  end
end