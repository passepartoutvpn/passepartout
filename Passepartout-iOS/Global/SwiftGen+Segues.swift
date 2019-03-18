// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Segues

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardSegue {
  internal enum Main: String, SegueType {
    case accountSegueIdentifier = "AccountSegueIdentifier"
    case debugLogSegueIdentifier = "DebugLogSegueIdentifier"
    case endpointSegueIdentifier = "EndpointSegueIdentifier"
    case hostParametersSegueIdentifier = "HostParametersSegueIdentifier"
    case providerPoolSegueIdentifier = "ProviderPoolSegueIdentifier"
    case providerPresetSegueIdentifier = "ProviderPresetSegueIdentifier"
  }
  internal enum Organizer: String, SegueType {
    case aboutSegueIdentifier = "AboutSegueIdentifier"
    case addProviderSegueIdentifier = "AddProviderSegueIdentifier"
    case importHostSegueIdentifier = "ImportHostSegueIdentifier"
    case selectProfileSegueIdentifier = "SelectProfileSegueIdentifier"
    case showImportedHostsSegueIdentifier = "ShowImportedHostsSegueIdentifier"
    case siriShortcutsSegueIdentifier = "SiriShortcutsSegueIdentifier"
    case versionSegueIdentifier = "VersionSegueIdentifier"
  }
  internal enum Shortcuts: String, SegueType {
    case connectToSegueIdentifier = "ConnectToSegueIdentifier"
    case pickLocationSegueIdentifier = "PickLocationSegueIdentifier"
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol SegueType: RawRepresentable {}

internal extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

internal extension SegueType where RawValue == String {
  init?(_ segue: UIStoryboardSegue) {
    guard let identifier = segue.identifier else { return nil }
    self.init(rawValue: identifier)
  }
}

private final class BundleToken {}
