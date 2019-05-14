source 'https://github.com/cocoapods/specs.git'
platform :ios, '11.0'
use_frameworks!

def shared_pods
    #pod 'TunnelKit', '~> 1.7.0'
    #pod 'TunnelKit/LZO', '~> 1.7.0'
    pod 'TunnelKit', :git => 'https://github.com/passepartoutvpn/tunnelkit', :commit => 'd06b2e1'
    pod 'TunnelKit/LZO', :git => 'https://github.com/passepartoutvpn/tunnelkit', :commit => 'd06b2e1'
    #pod 'TunnelKit', :path => '../tunnelkit'
    #pod 'TunnelKit/LZO', :path => '../tunnelkit'
    pod 'SSZipArchive'
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
