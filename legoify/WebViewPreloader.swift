import Foundation
import WebKit

class WebViewPreloader {
    static let shared = WebViewPreloader()
    private var preloadedWebView: WKWebView?

    private init() {
        preloadWebView()
    }

    private func preloadWebView() {
        let webView = WKWebView(frame: .zero)

        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }

        preloadedWebView = webView
    }

    func getWebView() -> WKWebView {
        if let webView = preloadedWebView {
            preloadedWebView = nil
            preloadWebView() // Prepare next one
            return webView
        } else {
            // Fallback if reused too quickly
            let newWebView = WKWebView()
            preloadWebView()
            return newWebView
        }
    }
}

