#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_haptics_and_audio.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_haptics_and_audio'
  s.version          = '1.0.0'
  s.summary          = 'Ultra-low latency native haptic and audio feedback for POS barcode scanners.'
  s.description      = <<-DESC
A high-performance Flutter plugin that bypasses standard audio packages to deliver
zero-latency 16-bit PCM audio playback and crisp native haptic feedback on iOS,
optimized for Point-of-Sale barcode scanning workflows.
                       DESC
  s.homepage         = 'https://github.com/andresmontaniv/native_haptics_and_audio'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Andres Montano' => 'andresmontaniv@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.resource_bundles = {
    'native_haptics_and_audio' => ['Assets/*.wav'],
    'native_haptics_and_audio_privacy' => ['Resources/PrivacyInfo.xcprivacy']
  }

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
