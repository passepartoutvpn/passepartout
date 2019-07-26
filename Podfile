source 'https://github.com/cocoapods/specs.git'
platform :ios, '11.0'
use_frameworks!

load 'Podfile.include'

$tunnelkit_name = 'TunnelKit'
$tunnelkit_specs = ['Protocols/OpenVPN', 'Extra/LZO']

def shared_pods
    #pod_version $tunnelkit_name, $tunnelkit_specs, '~> 2.0.1'
    pod_git $tunnelkit_name, $tunnelkit_specs, 'd717527ab7d3704d05e1f1ac828aef4066e002f2'
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
