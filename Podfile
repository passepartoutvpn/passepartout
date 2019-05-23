source 'https://github.com/cocoapods/specs.git'
platform :ios, '11.0'
use_frameworks!

load 'Podfile.include'

$tunnelkit_name = 'TunnelKit'
$tunnelkit_specs = ['Core', 'AppExtension', 'LZO']
#$tunnelkit_specs = ['OpenVPN', 'LZO']

def shared_pods
    by_version('~> 1.7.1', $tunnelkit_name, $tunnelkit_specs)
    #by_git('d06b2e1', $tunnelkit_name, $tunnelkit_specs)
    #by_path('..', $tunnelkit_name, $tunnelkit_specs)
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
