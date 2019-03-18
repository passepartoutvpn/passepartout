source 'https://github.com/cocoapods/specs.git'
platform :ios, '11.0'
use_frameworks!

def shared_pods
    #pod 'TunnelKit', '~> 1.4.2'
    pod 'TunnelKit', :git => 'https://github.com/keeshux/tunnelkit', :commit => '147cbb8'
    #pod 'TunnelKit', :path => '../../personal/tunnelkit'
end

target 'Passepartout-Core' do
    shared_pods
end
target 'Passepartout-CoreTests' do
    shared_pods
end

target 'Passepartout-iOS' do
    shared_pods
    pod 'MBProgressHUD'
end
target 'Passepartout-iOS-Tunnel' do
    shared_pods
end
