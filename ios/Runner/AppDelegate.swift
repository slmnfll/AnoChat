import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = registrar(forPlugin: "AnoLiquidTabs") {
      registrar.register(AnoTabsFactory(messenger: registrar.messenger()), withId: "ano/liquid-tabs")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

final class AnoTabsFactory: NSObject, FlutterPlatformViewFactory {
  let messenger: FlutterBinaryMessenger
  init(messenger: FlutterBinaryMessenger) { self.messenger = messenger }
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol { FlutterStandardMessageCodec.sharedInstance() }
  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    AnoTabs(frame: frame, id: viewId, messenger: messenger, selected: (args as? [String: Any])?["selected"] as? Int ?? 0)
  }
}
final class AnoTabs: NSObject, FlutterPlatformView {
  let tabs: GlassTabsView
  let channel: FlutterMethodChannel
  init(frame: CGRect, id: Int64, messenger: FlutterBinaryMessenger, selected: Int) {
    tabs = GlassTabsView(frame: frame)
    channel = FlutterMethodChannel(name: "ano/liquid-tabs/\(id)", binaryMessenger: messenger)
    super.init()
    tabs.selected = selected
    tabs.onSelect = { [weak self] index in self?.channel.invokeMethod("select", arguments: index) }
    channel.setMethodCallHandler { [weak self] call, result in
      if call.method == "select", let index = call.arguments as? Int { self?.tabs.select(index, notify: false); result(nil) } else { result(FlutterMethodNotImplemented) }
    }
  }
  func view() -> UIView { tabs }
  deinit { channel.setMethodCallHandler(nil) }
}
final class GlassTabsView: UIView {
  var selected = 0
  var onSelect: ((Int) -> Void)?
  private let material = UIVisualEffectView()
  private let lens = UIVisualEffectView()
  private var buttons: [UIButton] = []
  private var tracking = false
  private let feedback = UISelectionFeedbackGenerator()
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
    if #available(iOS 26.0, *) {
      let glass = UIGlassEffect(style: .regular)
      glass.isInteractive = true
      material.effect = glass
      let selection = UIGlassEffect(style: .clear)
      selection.isInteractive = true
      selection.tintColor = UIColor(red: 0.72, green: 0.79, blue: 0.67, alpha: 0.32)
      lens.effect = selection
    } else if #available(iOS 13.0, *) {
      material.effect = UIBlurEffect(style: .systemUltraThinMaterialLight)
      lens.effect = UIBlurEffect(style: .systemThinMaterialLight)
    } else {
      material.effect = UIBlurEffect(style: .extraLight)
      lens.effect = UIBlurEffect(style: .light)
    }
    material.isUserInteractionEnabled = true
    material.clipsToBounds = true
    lens.isUserInteractionEnabled = false
    lens.clipsToBounds = true
    addSubview(material)
    material.contentView.addSubview(lens)
    for (index, symbol) in ["house", "square.grid.2x2", "bubble.left.and.bubble.right", "person"].enumerated() {
      let button = UIButton(type: .system)
      button.tag = index
      if #available(iOS 13.0, *) {
        button.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 23, weight: .regular)), for: .normal)
      } else {
        button.setTitle(["⌂", "▦", "☏", "◉"][index], for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25)
      }
      button.tintColor = UIColor(red: 0.25, green: 0.32, blue: 0.24, alpha: 1)
      button.accessibilityLabel = ["Lounge", "Rooms", "Friends", "Your account"][index]
      button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
      material.contentView.addSubview(button)
      buttons.append(button)
    }
    addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragged(_:))))
    let hold = UILongPressGestureRecognizer(target: self, action: #selector(dragged(_:)))
    hold.minimumPressDuration = 0.15
    addGestureRecognizer(hold)
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  override func layoutSubviews() {
    super.layoutSubviews()
    material.frame = bounds
    material.layer.cornerRadius = bounds.height / 2
    let width = (bounds.width - 12) / 4
    for (index, button) in buttons.enumerated() { button.frame = CGRect(x: 6 + CGFloat(index) * width, y: 0, width: width, height: bounds.height) }
    if !tracking { positionLens(CGFloat(selected), expanded: false) }
    updateAccessibility()
  }
  private func positionLens(_ position: CGFloat, expanded: Bool) {
    let width = (bounds.width - 12) / 4
    let inset: CGFloat = expanded ? 4 : 7
    lens.frame = CGRect(x: 6 + position * width, y: inset, width: width, height: bounds.height - inset * 2)
    lens.layer.cornerRadius = lens.bounds.height / 2
  }
  private func updateAccessibility() { for (i, button) in buttons.enumerated() { button.accessibilityTraits = i == selected ? [.button, .selected] : [.button] } }
  func select(_ index: Int, notify: Bool = true) {
    guard (0...3).contains(index) else { return }
    let changed = selected != index
    selected = index
    updateAccessibility()
    if !tracking {
      UIView.animate(withDuration: UIAccessibility.isReduceMotionEnabled ? 0 : 0.28, delay: 0, usingSpringWithDamping: 0.78, initialSpringVelocity: 0, options: [.beginFromCurrentState, .allowUserInteraction]) { self.positionLens(CGFloat(index), expanded: false) }
    }
    if changed && notify { feedback.selectionChanged(); onSelect?(index) }
  }
  @objc private func tapped(_ sender: UIButton) { select(sender.tag) }
  @objc private func dragged(_ gesture: UIGestureRecognizer) {
    switch gesture.state {
    case .began, .changed:
      tracking = true
      let width = max(1, (bounds.width - 12) / 4)
      let x = gesture.location(in: self).x - 6
      positionLens(min(3, max(0, x / width - 0.5)), expanded: true)
      select(min(3, max(0, Int(floor(x / width)))))
    default:
      tracking = false
      select(selected, notify: false)
    }
  }
}
