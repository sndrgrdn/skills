# Turbo Native (iOS & Android)

## Contents
- [Architecture](#architecture)
- [iOS integration](#ios-integration)
- [Android integration](#android-integration)
- [Path configuration](#path-configuration)
- [Bridge components (Strada)](#bridge-components-strada)
- [Server-side considerations](#server-side-considerations)
- [Common patterns](#common-patterns)

> **Library status:** `turbo-ios`/`turbo-android` + `strada-ios`/`strada-android` are deprecated. Use the consolidated libraries: **hotwire-native-ios** and **hotwire-native-android** (Bridge/Strada is built-in).

---

## Architecture

Hotwire Native wraps a **single shared WKWebView (iOS) / WebView (Android)** in a native shell. The web view is reused across screens; when a screen is deactivated, a screenshot replaces the live web view.

**Navigation flow:**
1. Link tap in WebView → Turbo JS intercepts
2. Native bridge receives visit proposal (URL + options + path properties)
3. Navigator routes to a UIViewController / Fragment (push, modal, replace, etc.)
4. Web view visits the new URL; screenshot of previous screen shown during loading
5. Content rendered; screenshot hidden

**Visit types:**
- **Cold boot** — first visit or after reload; full page load. Slow.
- **JavaScript visit** — subsequent Turbo-driven navigation; only fetches HTML, replaces `<body>`. Fast.

---

## iOS integration

### Installation

```swift
// SPM: https://github.com/hotwired/hotwire-native-ios from: "1.2.2"
import HotwireNative
```

### Minimal setup (SceneDelegate)

```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let navigator = Navigator(configuration: .init(
        name: "main", startLocation: URL(string: "https://your-app.example.com")!
    ))

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        window?.rootViewController = navigator.rootViewController
        navigator.start()
    }
}
```

### Key classes

| Class | Purpose |
|---|---|
| `Navigator` | Top-level coordinator, manages two Sessions (main + modal), routes proposals |
| `NavigatorDelegate` | Protocol: accept/reject/customize proposals, handle errors |
| `Session` | Manages a WKWebView, handles cold boot vs JS visits |
| `VisitProposal` | `url`, `options`, `properties`, `parameters` |
| `HotwireWebViewController` | Default web VC; subclass for customization |
| `HotwireTabBarController` | Tab bar with one Navigator per tab |
| `PathConfiguration` | Loads and evaluates path configuration JSON |

### NavigatorDelegate

```swift
func handle(proposal: VisitProposal, from navigator: Navigator) -> ProposalResult {
    switch proposal.viewController {
    case NumbersViewController.pathConfigurationIdentifier:
        return .acceptCustom(NumbersViewController(url: proposal.url, navigator: navigator))
    default:
        return .accept  // default HotwireWebViewController
    }
}

func visitableDidFailRequest(_ visitable: any Visitable, error: any Error, retryHandler: RetryBlock?) {
    if let turboError = error as? TurboError, case let .http(statusCode) = turboError, statusCode == 401 {
        // prompt authentication
    }
}
```

### Native screen

```swift
final class NumbersViewController: UITableViewController, PathConfigurationIdentifiable {
    static var pathConfigurationIdentifier: String { "numbers" }
}
```

### Configuration

```swift
Hotwire.config.applicationUserAgentPrefix = "MyApp"
Hotwire.config.showDoneButtonOnModals = true
Hotwire.loadPathConfiguration(from: [
    .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!),
    .server(URL(string: "https://example.com/configurations/ios_v1.json")!)
])
Hotwire.registerBridgeComponents([FormComponent.self, MenuComponent.self])
```

---

## Android integration

### Installation

```kotlin
// build.gradle.kts
implementation("dev.hotwire:core:<version>")
implementation("dev.hotwire:navigation-fragments:<version>")
```

### Minimal setup

```kotlin
class MainActivity : HotwireActivity() {
    override fun navigatorConfigurations() = listOf(
        NavigatorConfiguration(
            name = "main",
            startLocation = "https://your-app.example.com",
            navigatorHostId = R.id.main_nav_host
        )
    )
}
```

### Key classes

| Class | Purpose |
|---|---|
| `HotwireActivity` | Base AppCompatActivity with Navigator management |
| `NavigatorHost` | Extends NavHostFragment, hosts one Navigator + Session |
| `Navigator` | Routes URLs to Fragment destinations |
| `HotwireWebFragment` | Base web Fragment (annotate with `@HotwireDestinationDeepLink`) |
| `HotwireFragment` | Base native Fragment |
| `HotwireBottomNavigationController` | Manages BottomNavigationView with one NavigatorHost per tab |
| `PathConfiguration` | Loads JSON from assets and/or remote URL |

### Web fragment

```kotlin
@HotwireDestinationDeepLink(uri = "hotwire://fragment/web")
class WebFragment : HotwireWebFragment()
```

### Native fragment

```kotlin
@HotwireDestinationDeepLink(uri = "hotwire://fragment/native/numbers")
class NumbersFragment : HotwireFragment() {
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?) =
        inflater.inflate(R.layout.fragment_numbers, container, false)
}
```

### App initialization

```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        Hotwire.loadPathConfiguration(context = this,
            location = PathConfiguration.Location(
                assetFilePath = "json/configuration.json",
                remoteFileUrl = "https://example.com/configurations/android_v1.json"
            ))
        Hotwire.registerFragmentDestinations(WebFragment::class, NumbersFragment::class)
        Hotwire.registerBridgeComponents(BridgeComponentFactory("form", ::FormComponent))
    }
}
```

---

## Path configuration

A JSON file controlling routing without an app release. Loaded locally (bundled) then remotely (server).

```json
{
  "settings": { "screenshots_enabled": true },
  "rules": [
    {
      "patterns": [".*"],
      "properties": { "context": "default", "uri": "hotwire://fragment/web" }
    },
    {
      "patterns": ["/new$", "/edit$"],
      "properties": { "context": "modal", "pull_to_refresh_enabled": false }
    },
    {
      "patterns": ["/numbers$"],
      "properties": { "view_controller": "numbers", "uri": "hotwire://fragment/native/numbers" }
    }
  ]
}
```

### Properties

| Property | iOS | Android | Values |
|---|---|---|---|
| `context` | ✓ | ✓ | `default`, `modal` |
| `presentation` | ✓ | ✓ | `default`, `push`, `pop`, `replace`, `replace_root`, `clear_all`, `refresh`, `none` |
| `pull_to_refresh_enabled` | ✓ | ✓ | `true`, `false` |
| `view_controller` | ✓ | — | String matching `PathConfigurationIdentifiable` |
| `uri` | — | ✓ | Deep link URI matching `@HotwireDestinationDeepLink` |
| `modal_style` | ✓ | — | `large`, `medium`, `full`, `page_sheet`, `form_sheet` |

**Versioning:** Use platform-specific paths (`ios_v1.json`, `android_v1.json`). Bump to `_v2.json` for breaking changes.

---

## Bridge components (Strada)

Bridge components enable bidirectional communication between web Stimulus controllers and native Swift/Kotlin code.

### Web component (JavaScript)

```javascript
import { BridgeComponent, BridgeElement } from "@hotwired/strada"

export default class extends BridgeComponent {
  static component = "form"
  static targets = ["submit"]

  submitTargetConnected(target) {
    const submitButton = new BridgeElement(target)
    this.send("connect", { submitTitle: submitButton.title }, () => {
      target.click()  // callback when native replies
    })
  }
}
```

```html
<form data-controller="bridge--form">
  <button type="submit" data-bridge--form-target="submit" data-bridge-title="Save">Save</button>
</form>
```

Hide web element when native component is active:
```css
[data-bridge-components~="form"] [data-controller~="bridge--form"] [type="submit"] {
  display: none;
}
```

### iOS bridge component

```swift
final class FormComponent: BridgeComponent {
    override class var name: String { "form" }

    override func onReceive(message: Message) {
        guard let data: MessageData = message.data() else { return }
        let action = UIAction { [unowned self] _ in reply(to: "connect") }
        let item = UIBarButtonItem(title: data.submitTitle, primaryAction: action)
        (delegate?.destination as? UIViewController)?.navigationItem.rightBarButtonItem = item
    }

    private struct MessageData: Decodable { let submitTitle: String }
}
```

### Android bridge component

```kotlin
class FormComponent(name: String, private val delegate: BridgeDelegate<HotwireDestination>)
    : BridgeComponent<HotwireDestination>(name, delegate) {

    override fun onReceive(message: Message) {
        when (message.event) {
            "connect" -> {
                val data = message.data<MessageData>() ?: return
                // Add toolbar button that calls replyTo("connect") on click
            }
        }
    }

    @Serializable data class MessageData(@SerialName("submitTitle") val title: String)
}
```

---

## Server-side considerations

### Detecting Turbo Native requests

```ruby
def turbo_native_app?
  request.user_agent.include?("Turbo Native") || request.user_agent.include?("Hotwire Native")
end
```

User-Agent includes: `Hotwire Native iOS`, `Turbo Native Android`, `bridge-components: [form menu]`.

### Navigation helpers (turbo-rails)

```ruby
recede_or_redirect_to(url)   # pop modal + pop screen
refresh_or_redirect_to(url)  # pop modal + refresh current screen
resume_or_redirect_to(url)   # pop modal only
```

### Response considerations

- Simplify HTML for native (remove desktop nav, footers) when `turbo_native_app?`
- Use `data-turbo-action="replace"` to prevent duplicate screens on native stack
- Handle 401 responses natively to trigger auth flow

---

## Common patterns

### Authentication

**Cookie-based (simplest):** Sign in via web view; server sets persistent cookies. WKWebView/WebView persists cookies to disk automatically.

**Token-based:** Perform auth natively → receive token → store in Keychain/KeyStore. Catch HTTP 401 in error handler → redirect to sign-in URL.

```swift
func visitableDidFailRequest(_ visitable: any Visitable, error: any Error, retryHandler: RetryBlock?) {
    if case .http(401) = (error as? TurboError) {
        navigator.route(URL(string: "\(rootURL)/session/new")!)
    }
}
```

### Tab bar app

**iOS:**
```swift
let tabBarController = HotwireTabBarController(navigatorDelegate: self)
tabBarController.load([
    HotwireTab(title: "Home", image: UIImage(systemName: "house")!, url: rootURL),
    HotwireTab(title: "Settings", image: UIImage(systemName: "gear")!, url: settingsURL)
])
```

**Android:** Use `HotwireBottomNavigationController` with `BottomNavigationView`.

### External links

- iOS: external URLs open in SFSafariViewController by default
- Android: external URLs open in Chrome Custom Tabs by default
- Override via custom `RouteDecisionHandler`

### Debug logging

```swift
Hotwire.config.debugLoggingEnabled = true  // iOS — never in production
```
```kotlin
Hotwire.config.debugLoggingEnabled = true   // Android
Hotwire.config.webViewDebuggingEnabled = true  // Chrome DevTools
```
