Pod::Spec.new do |s|
  s.name     = 'TONavigationBar'
  s.version  = '0.0.1'
  s.license  =  { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'A UINavigationBar subclass that recreates the clear bar style of Apple\'s modern apps'
  s.homepage = 'https://github.com/TimOliver/TONavigationBar'
  s.author   = 'Tim Oliver'
  s.source   = { :git => 'https://github.com/TimOliver/TONavigationBar.git', :tag => s.version }
  s.platform = :ios, '10.0'
  s.source_files = 'TONavigationBar/**/*.{h,m}'
  s.requires_arc = true
end
