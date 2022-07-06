Pod::Spec.new do |s|
  s.name             = 'fl_rangers_applog'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'RangersAppLog'
  s.frameworks = 'Foundation','UIKit','JavaScriptCore','WebKit','CoreFoundation','CoreTelephony','Security','SystemConfiguration','AdSupport'
  s.libraries = 'z','lite3'
  s.requires_arc = true
  s.platform = :ios, '10.0'
  s.static_framework = true
  
end

