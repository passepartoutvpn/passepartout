source 'https://github.com/cocoapods/specs.git'
platform :ios, '11.0'
use_frameworks!

load 'Podfile.include'

$tunnelkit_name = 'TunnelKit'
$tunnelkit_specs = ['Protocols/OpenVPN', 'Extra/LZO']

def shared_pods
    #pod_version $tunnelkit_name, $tunnelkit_specs, '~> 2.1.0'
    pod_git $tunnelkit_name, $tunnelkit_specs, '8b17a13'
    #pod_path $tunnelkit_name, $tunnelkit_specs, '..'
    pod 'SSZipArchive'

    for spec in ['About', 'Alerts', 'Dialogs', 'InApp', 'Misc', 'Options', 'Persistence', 'Reviewer', 'Tables', 'WebServices'] do
        pod "Convenience/#{spec}", :git => 'https://github.com/keeshux/convenience', :commit => '7fe7dcf'
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
