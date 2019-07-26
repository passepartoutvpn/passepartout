source 'https://github.com/cocoapods/specs.git'
platform :ios, '11.0'
use_frameworks!

load 'Podfile.include'

$tunnelkit_name = 'TunnelKit'
$tunnelkit_specs = ['Protocols/OpenVPN', 'Extra/LZO']

def shared_pods
    pod_version $tunnelkit_name, $tunnelkit_specs, '~> 2.0.2'
    #pod_git $tunnelkit_name, $tunnelkit_specs, 'a4333eaafe33bf88c3b2ec3a3b8c4a5ceba9203e'
    #pod_path $tunnelkit_name, $tunnelkit_specs, '..'
    pod 'SSZipArchive'
end

target 'PassepartoutCore-iOS' do
    shared_pods
end

target 'Passepartout-iOS' do
    pod 'MBProgressHUD'
end
target 'Passepartout-iOS-Tunnel' do
    shared_pods
end
