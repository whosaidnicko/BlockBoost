

import SafariServices


final class OpenPage {
    
    func openWebView() {
        if let url = URL(string: "https://www.privacypolicies.com/live/f2a3b22d-751c-47f1-a3af-2c1d4966df60") {
            let safariViewController = SFSafariViewController(url: url)

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(safariViewController, animated: true, completion: nil)
            }
        }
    }
}
