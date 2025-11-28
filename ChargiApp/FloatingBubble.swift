import SwiftUI
import AppKit

final class BubbleViewModel: ObservableObject {
    @Published var text: String = "--"
    @Published var isCharging: Bool = false
}

struct BubbleView: View {
    @ObservedObject var model: BubbleViewModel
    @State private var offset: CGFloat = -30

    var body: some View {
        Text(model.text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: true)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    LinearGradient(colors: [Color.green.opacity(0.8), Color.blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                        .offset(x: offset)
                        .frame(height: 28)
                        .clipShape(Capsule())
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
            )
            .scaleEffect(model.isCharging ? 1.03 : 1.0)
            .onAppear {
                if model.isCharging {
                    withAnimation(.linear(duration: 4).repeatForever(autoreverses: true)) { offset = 30 }
                }
            }
            .onChange(of: model.isCharging) { charging in
                if charging {
                    offset = -30
                    withAnimation(.linear(duration: 4).repeatForever(autoreverses: true)) { offset = 30 }
                } else {
                    withAnimation(.easeOut(duration: 0.3)) { offset = 0 }
                }
            }
    }
}

final class BubbleController {
    private var window: NSPanel?
    private let model = BubbleViewModel()
    private var service: BatteryService?
    private var preferences: Preferences?
    private var hostingView: NSHostingView<BubbleView>?
    private var observerId: UUID?

    func bind(batteryService: BatteryService, preferences: Preferences) {
        self.service = batteryService
        self.preferences = preferences
        observerId = batteryService.addObserver { [weak self] reading in
            guard let self else { return }
            self.model.text = reading.displayText
            self.model.isCharging = reading.isCharging
            self.updateSize()
        }
    }

    func show() {
        if window == nil { createWindow() }
        window?.orderFrontRegardless()
    }

    func hide() {
        window?.orderOut(nil)
    }

    private func createWindow() {
        let content = NSHostingView(rootView: BubbleView(model: model))
        hostingView = content
        let initialSize = content.fittingSize
        let panel = NSPanel(contentRect: NSRect(x: 100, y: 100, width: max(120, initialSize.width + 6), height: max(40, initialSize.height + 6)), styleMask: [.nonactivatingPanel, .titled], backing: .buffered, defer: true)
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = content
        window = panel
    }

    private func updateSize() {
        guard let window, let hostingView else { return }
        let size = hostingView.fittingSize
        window.setContentSize(NSSize(width: size.width + 6, height: size.height + 6))
    }
}
