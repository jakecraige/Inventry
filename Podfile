source "https://github.com/CocoaPods/Specs"

platform :ios, "9.0"

use_frameworks!

target "Inventry" do
  pod "Firebase"
  pod "Firebase/Auth"
  pod "Firebase/Crash"
  pod "Firebase/Database"
  pod "Firebase/RemoteConfig"
  pod "Argo"
  pod "Curry"
end

abstract_target :unit_tests do
  target "UnitTests"
end

# Copy acknowledgements to the Settings.bundle

post_install do |installer|
  require "fileutils"

  pods_acknowledgements_path =
    "Pods/Target Support Files/Pods/Pods-Acknowledgements.plist"
  settings_bundle_path = Dir.glob("**/*Settings.bundle*").first

  if File.file?(pods_acknowledgements_path)
    puts "Copying acknowledgements to Settings.bundle"
    FileUtils.cp_r(
      pods_acknowledgements_path,
      "#{settings_bundle_path}/Acknowledgements.plist",
      remove_destination: true
    )
  end
end

