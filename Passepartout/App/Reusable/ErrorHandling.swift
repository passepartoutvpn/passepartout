import SwiftUI

// https://www.ralfebert.com/swiftui/generic-error-handling/

private struct ErrorAlert: Identifiable {
    let id = UUID()

    let title: String?

    let message: String

    let dismissAction: (() -> Void)?
}

final class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()

    @Published fileprivate var currentAlert: ErrorAlert?

    func handle(_ error: Error, title: String? = nil, onDismiss: (() -> Void)? = nil) {
        currentAlert = ErrorAlert(
            title: title,
            message: AppError(error).localizedDescription,
            dismissAction: onDismiss
        )
    }

    func handle(title: String, message: String, onDismiss: (() -> Void)? = nil) {
        currentAlert = ErrorAlert(
            title: title,
            message: message,
            dismissAction: onDismiss
        )
    }
}

struct HandleErrorsByShowingAlertViewModifier: ViewModifier {
    @ObservedObject private var errorHandler: ErrorHandler

    init() {
        errorHandler = .shared
    }

    func body(content: Content) -> some View {
        content
            // Applying the alert for error handling using a background element
            // is a workaround, if the alert would be applied directly,
            // other .alert modifiers inside of content would not work anymore
            .background(
                EmptyView()
                    .alert(item: $errorHandler.currentAlert) { currentAlert in
                        Alert(
                            title: Text(currentAlert.title ?? Unlocalized.appName),
                            message: Text(currentAlert.message.withTrailingDot),
                            dismissButton: .cancel(Text(L10n.Global.Strings.ok)) {
                                currentAlert.dismissAction?()
                            }
                        )
                    }
            )
    }
}

extension View {
    func withErrorHandler() -> some View {
        modifier(HandleErrorsByShowingAlertViewModifier())
    }
}
