Pod::Spec.new do |s|
  s.name         = "TKMultiColumnTableCollectionViewLayout"
  s.version      = "0.0.2"
  s.summary      = "A short description of TKMultiColumnTableCollectionViewLayout."

  s.homepage     = "https://github.com/itworx/TKMultiColumnTableCollectionViewLayout"
    
  s.requires_arc = true
  s.author             = { "ahmadalmoraly" => "ahmedalmoraly@gmail.com" }
  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/itworx/TKMultiColumnTableCollectionViewLayout.git", :tag => {s.version} }

  s.source_files  = 'TKMultiColumnTableCollectionView/TKMultiColumnCollectionViewLayout.{h,m}'
end
