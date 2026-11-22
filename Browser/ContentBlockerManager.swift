import Foundation
import WebKit

final class ContentBlockerManager {
    static let shared = ContentBlockerManager()

    private(set) var ruleList: WKContentRuleList?
    private var isCompiled = false

    func compileRules() {
        guard !isCompiled else { return }
        isCompiled = true

        let rules: [[String: Any]] = [
            // Ad networks
            ["trigger": ["url-filter": ".*", "if-domain": ["*doubleclick.net"]], "action": ["type": "block"]],
            ["trigger": ["url-filter": ".*", "if-domain": ["*googlesyndication.com"]], "action": ["type": "block"]],
            ["trigger": ["url-filter": ".*", "if-domain": ["*googleadservices.com"]], "action": ["type": "block"]],
            ["trigger": ["url-filter": ".*", "if-domain": ["*adnxs.com"]], "action": ["type": "block"]],
            ["trigger": ["url-filter": ".*", "if-domain": ["*adsrvr.org"]], "action": ["type": "block"]],
            ["trigger": ["url-filter": ".*", "if-domain": ["*moatads.com"]], "action": ["type": "block"]],
            // Trackers
            ["trigger": ["url-filter": ".*", "if-domain": ["*google-analytics.com"]], "action": ["type": "block"]],
            ["trigger": ["url-filter": ".*", "if-domain": ["*facebook.net"]], "action": ["type": "block"]],
            ["trigger": ["url-filter": ".*", "if-domain": ["*hotjar.com"]], "action": ["type": "block"]],
            ["trigger": ["url-filter": ".*", "if-domain": ["*mixpanel.com"]], "action": ["type": "block"]],
            ["trigger": ["url-filter": ".*", "if-domain": ["*segment.io"]], "action": ["type": "block"]],
            ["trigger": ["url-filter": ".*", "if-domain": ["*amplitude.com"]], "action": ["type": "block"]],
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: rules),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }

        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: "browser-blocklist",
            encodedContentRuleList: jsonString
        ) { [weak self] ruleList, error in
            if let error {
                print("Content blocker compilation failed: \(error.localizedDescription)")
                return
            }
            self?.ruleList = ruleList
        }
    }
}
