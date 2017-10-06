Pod::Spec.new do |s|
  s.name         = "CopyOnWrite"
  s.version      = "1.0.0"
  s.summary      = "A μframework that makes implementing value semantics easy!"

  s.description  = <<-DESC
                   CopyOnWrite is a μframework that makes implementing value semantics easy!
                   Wrap your reference types in the `CopyOnWrite` struct and access the value from the
                   appropriate accessor properties, and your type will have proper value semantics!
                   DESC

  s.homepage     = "https://github.com/klundberg/CopyOnWrite"

  s.license      = "MIT"

  s.author             = { "Kevin Lundberg" => "kevin@klundberg.com" }
  s.social_media_url   = "http://twitter.com/kevlario"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/klundberg/CopyOnWrite.git", :tag => "v#{s.version}" }
  s.source_files = "Sources/CopyOnWrite/*.swift"
end
