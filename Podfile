source 'https://github.com/cocoapods/specs.git'
platform :ios, '11.0'
use_frameworks!

def shared_pods
    #pod 'TunnelKit', '~> 1.6.1'
    #pod 'TunnelKit/LZO', '~> 1.6.1'
    pod 'TunnelKit', :git => 'https://github.com/keeshux/tunnelkit', :commit => '914864c'
    pod 'TunnelKit/LZO', :git => 'https://github.com/keeshux/tunnelkit', :commit => '914864c'
    #pod 'TunnelKit', :path => '../../personal/tunnelkit'
    #pod 'TunnelKit/LZO', :path => '../../personal/tunnelkit'
end

target 'Passepartout-Core' do
    shared_pods
end
target 'Passepartout-CoreTests' do
    shared_pods
end

target 'Passepartout-iOS' do
    pod 'MBProgressHUD'
end
target 'Passepartout-iOS-Tunnel' do
    shared_pods
end
