# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'FCM-Test' do
   # Comment the next line if you don't want to use dynamic frameworks
  use_modular_headers!

  # Pods for BonanzaMaze
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/AnalyticsWithoutAdIdSupport'



end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
