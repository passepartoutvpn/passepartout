import SwiftUI

// https://www.ralfebert.com/swiftui/generic-error-handling/

private struct ErrorAlert: Identifiable {
    let id = UUID()

    let title: String?

    let message: String

    let dismissAction: (() -> Void)?
}

@MainActor
final class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()

    @Published fileprivate var isPresented = false

    @Published fileprivate var currentAlert: ErrorAlert?

    func handle(_ error: Error, title: String? = nil, onDismiss: (() -> Void)? = nil) {
        currentAlert = ErrorAlert(
            title: title,
            message: AppError(error).localizedDescription,
            dismissAction: onDismiss
        )
        isPresented = true
    }

    func handle(title: String, message: String, onDismiss: (() -> Void)? = nil) {
        currentAlert = ErrorAlert(
            title: title,
            message: message,
            dismissAction: onDismiss
        )
        isPresented = true
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
                    .alert(
                        errorHandler.currentAlert?.title ?? Unlocalized.appName,
                        isPresented: $errorHandler.isPresented,
                        presenting: errorHandler.currentAlert
                     ) { alert in
                         Button(role: .cancel) {
                             alert.dismissAction?()
                         } label: {
                             Text(L10n.Global.Strings.ok)
                         }
                     } message: { alert in
                         Text(alert.message.withTrailingDot)
                     }
            )
    }
}

extension View {
    func withErrorHandler() -> some View {
        modifier(HandleErrorsByShowingAlertViewModifier())
    }
}
