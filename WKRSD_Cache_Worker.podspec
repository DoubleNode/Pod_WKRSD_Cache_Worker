Pod::Spec.new do |s|

  s.name         = "WKRSD_Cache_Worker"
  s.version      = "0.2.4"
  s.summary      = "A SDWebImage Cacheworker."

  s.description  = <<-DESC
                    A worker for SDWebImage's Image Caching based on the Cache protocol.
                   DESC

  s.homepage     = "https://github.com/DoubleNode/Pod_WKRSD_Cache_Worker"
  s.license      = { :type => "PRIVATE", :file => "README.md" }

  s.author             = { "Darren Ehlers" => "me@darrenehlers.com" }
  s.social_media_url   = "http://twitter.com/ehlersd"

  s.platform     = :ios, "10.0"

  s.source = { :git => "https://github.com/DoubleNode/Pod_WKRSD_Cache_Worker.git", :tag => "#{s.version}" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.public_header_files = "Classes/**/*.h"

  s.requires_arc = true

  s.dependency "SDWebImage"

  s.dependency "DNCProtocols"

end
