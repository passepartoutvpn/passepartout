// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import AppKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let organizerWindowController = SceneType<AppKit.NSWindowController>(storyboard: Main.self, identifier: "OrganizerWindowController")

    internal static let textInputViewController = SceneType<TextInputViewController>(storyboard: Main.self, identifier: "TextInputViewController")
  }
  internal enum Preferences: StoryboardType {
    internal static let storyboardName = "Preferences"

    internal static let initialScene = InitialSceneType<PreferencesViewController>(storyboard: Preferences.self)
  }
  internal enum Service: StoryboardType {
    internal static let storyboardName = "Service"

    internal static let initialScene = InitialSceneType<ServiceViewController>(storyboard: Service.self)

    internal static let accountViewController = SceneType<AccountViewController>(storyboard: Service.self, identifier: "AccountViewController")

    internal static let profileCustomizationContainerViewController = SceneType<ProfileCustomizationContainerViewController>(storyboard: Service.self, identifier: "ProfileCustomizationContainerViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: NSStoryboard {
    let name = NSStoryboard.Name(self.storyboardName)
    return NSStoryboard(name: name, bundle: BundleToken.bundle)
  }
}

internal struct SceneType<T> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = NSStoryboard.SceneIdentifier(self.identifier)
    guard let controller = storyboard.storyboard.instantiateController(withIdentifier: identifier) as? T else {
      fatalError("Controller '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialController() as? T else {
      fatalError("Controller is not of the expected class \(T.self).")
    }
    return controller
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    Bundle(for: BundleToken.self)
  }()
}
// swiftlint:enable convenience_type
