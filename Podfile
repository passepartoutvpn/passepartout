source 'https://github.com/cocoapods/specs.git'
use_frameworks!

def shared_pods
    #pod 'TunnelKit', '~> 1.4.2'
    pod 'TunnelKit', :git => 'https://github.com/keeshux/tunnelkit', :commit => '147cbb8'
    #pod 'TunnelKit', :path => '../../personal/tunnelkit'
end

target 'Passepartout-iOS' do
    platform :ios, '11.0'
    shared_pods
    pod 'MBProgressHUD'
end
target 'Passepartout-iOS-Tunnel' do
    platform :ios, '11.0'
    shared_pods
end
target 'PassepartoutTests-iOS' do
    platform :ios, '11.0'
    shared_pods
end
