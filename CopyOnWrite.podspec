Pod::Spec.new do |s|

  s.name         = "CopyOnWrite"
  s.version      = "0.1.0"
  s.summary      = "μframework encapsulating the `CopyOnWrite` type, to make implementing value semantics easy!"

  s.description  = <<-DESC
TODO: THIS
                   DESC

  s.homepage     = "https://github.com/klundberg/CopyOnWrite"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Kevin Lundberg" => "kevin@klundberg.com" }
  s.social_media_url   = "http://twitter.com/kevlario"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/klundberg/CopyOnWrite.git", :tag => "v0.1.0" }

  s.source_files  = "Sources/*.swift"

end