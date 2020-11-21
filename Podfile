source 'https://github.com/cocoapods/specs.git'
platform :ios, '12.0'
use_frameworks!

load 'Podfile.include'

$tunnelkit_name = 'TunnelKit'
$tunnelkit_specs = ['Protocols/OpenVPN', 'Extra/LZO']

def shared_pods
    #pod_version $tunnelkit_name, $tunnelkit_specs, '~> 3.0.1'
    pod_git $tunnelkit_name, $tunnelkit_specs, '4e2dca9'
    #pod_path $tunnelkit_name, $tunnelkit_specs, '..'
    pod 'SSZipArchive'

    for spec in ['About', 'Alerts', 'Dialogs', 'InApp', 'Misc', 'Options', 'Persistence', 'Reviewer', 'Tables', 'WebServices'] do
        pod "Convenience/#{spec}", :git => 'https://github.com/keeshux/convenience', :commit => '0b09b1e'
        #pod "Convenience/#{spec}", :path => '../../personal/convenience'
    end
end

target 'PassepartoutCore-iOS' do
    shared_pods
    pod 'Kvitto'
end

target 'Passepartout-iOS' do
    pod 'MBProgressHUD'
end
target 'Passepartout-iOS-Tunnel' do
    shared_pods
end
