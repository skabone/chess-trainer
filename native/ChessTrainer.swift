// Chess Trainer — native macOS wrapper (WKWebView, no Electron, no dependencies)
// Required Notice: Copyright (c) 2026 Mintay Misgano (https://github.com/skabone)
// Licensed under the PolyForm Noncommercial License 1.0.0
//
// Unlike the Daybook wrapper, this one loads the copy of index.html bundled
// inside the .app rather than a hosted URL: the engine is embedded in the page
// and the whole point is that it works with no network at all. Rebuild the app
// to take a new version.

import Cocoa
import WebKit

final class WebController: NSViewController, WKNavigationDelegate, WKUIDelegate {
    let web: WKWebView

    init() {
        let cfg = WKWebViewConfiguration()
        cfg.websiteDataStore = .default()          // localStorage persists across launches
        cfg.defaultWebpagePreferences.allowsContentJavaScript = true
        self.web = WKWebView(frame: NSRect(x: 0, y: 0, width: 1280, height: 900), configuration: cfg)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        web.navigationDelegate = self
        web.uiDelegate = self
        web.allowsBackForwardNavigationGestures = false   // arrow keys walk the game
        self.view = web
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let path = Bundle.main.url(forResource: "index", withExtension: "html") else {
            let alert = NSAlert()
            alert.messageText = "index.html is missing from the app bundle."
            alert.informativeText = "Rebuild with ./build.sh from the native/ folder."
            alert.runModal()
            return
        }
        // read access to the containing directory, so file:// loads cleanly
        web.loadFileURL(path, allowingReadAccessTo: path.deletingLastPathComponent())
    }

    @objc func reload(_ sender: Any?) { web.reload() }

    // Keep the app on its own page; send real links to the browser.
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated,
           let u = navigationAction.request.url, u.scheme?.hasPrefix("http") == true {
            NSWorkspace.shared.open(u)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ note: Notification) {
        let vc = WebController()
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 900),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "Chess Trainer"
        window.contentViewController = vc
        window.setFrameAutosaveName("ChessTrainerWindow")
        window.center()
        window.makeKeyAndOrderFront(nil)
        buildMenu(vc)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool { true }

    private func buildMenu(_ vc: WebController) {
        let main = NSMenu()

        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About Chess Trainer",
                        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Hide Chess Trainer",
                        action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(withTitle: "Quit Chess Trainer",
                        action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu
        main.addItem(appItem)

        let viewItem = NSMenuItem()
        let viewMenu = NSMenu(title: "View")
        let r = NSMenuItem(title: "Reload", action: #selector(WebController.reload(_:)), keyEquivalent: "r")
        r.target = vc
        viewMenu.addItem(r)
        viewItem.submenu = viewMenu
        main.addItem(viewItem)

        let editItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editItem.submenu = editMenu
        main.addItem(editItem)

        NSApp.mainMenu = main
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
