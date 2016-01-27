Pod::Spec.new do |s|

  s.name         = "JKFancySignature"
  s.version      = "0.1.4"
  s.summary      = "Fancy Signature view to create dynamic signature and graphics"

  s.description  = <<-DESC
                   A Custom view to allow users to easily create, store and reproduce signature with fancy effects. 
                   Highly customizable to suite to your requirements.
                   DESC

  s.homepage     = "https://github.com/jayesh15111988/JKFancySignature"  
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Jayesh Kawli" => "j.kawli@gmail.com" }
  s.social_media_url   = "http://twitter.com/JayeshKawli"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/jayesh15111988/JKFancySignature.git", :branch => "master" }
  s.source_files  = "JKFancySignature/Classes/**/*.{h,m}"
  #s.resource  = "icon.png"
  #s.resources = "JKFancySignature/Images/*.{png, jpg, jpeg}"
  s.requires_arc = true

end
