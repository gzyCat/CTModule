Pod::Spec.new do |s|


  s.name         = "CTMediator-Extension"
  s.version      = "0.0.1"
  s.summary      = "CTMediator-Extension"

  s.description  = <<-DESC
  this is module config
                   DESC

  s.homepage     = "https://github.com/gzyCat/CTModule"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "gaoziying" => "841905781@qq.com" }
  s.source       = { :git => "https://github.com/gzyCat/CTModule.git", :tag => s.version.to_s }
  s.source_files  = "CTMediator-Extension/CTMediator-Extension/*.{h,m}"

end
