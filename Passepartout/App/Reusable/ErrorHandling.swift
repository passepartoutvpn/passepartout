import SwiftUI

// https://www.ralfebert.com/swiftui/generic-error-handling/

private struct ErrorAlert: Identifiable {
    let id = UUID()

    let title: String?

    let message: String

    let dismissAction: (() -> Void)?
}

class ErrorHandling: ObservableObject {
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
    @ObservedObject private var errorHandling: ErrorHandling

    init() {
        errorHandling = .shared
    }

    func body(content: Content) -> some View {
        content
            .environmentObject(errorHandling)
            // Applying the alert for error handling using a background element
            // is a workaround, if the alert would be applied directly,
            // other .alert modifiers inside of content would not work anymore
            .background(
                EmptyView()
                    .alert(item: $errorHandling.currentAlert) { currentAlert in
                        Alert(
                            title: Text(currentAlert.title ?? Unlocalized.appName),
                            message: Text(currentAlert.message),
                            dismissButton: .cancel(Text(L10n.Global.Strings.ok)) {
                                currentAlert.dismissAction?()
                            }
                        )
                    }
            )
    }
}

extension View {
    func withErrorHandling() -> some View {
        modifier(HandleErrorsByShowingAlertViewModifier())
    }
}
