import AppKit

enum IconFactory {
    static func batteryIcon() -> NSImage {
        let size = NSSize(width: 18, height: 14)
        let image = NSImage(size: size)
        image.lockFocus()
        let rect = NSRect(x: 1, y: 2, width: 14, height: 10)
        let cap = NSRect(x: rect.maxX + 1, y: rect.midY - 2, width: 2, height: 4)
        let path = NSBezierPath(roundedRect: rect, xRadius: 2, yRadius: 2)
        NSColor.black.setStroke()
        path.lineWidth = 1.5
        path.stroke()
        NSBezierPath(rect: cap).stroke()
        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    static func batteryIconPulse(phase: CGFloat) -> NSImage {
        let size = NSSize(width: 18, height: 14)
        let image = NSImage(size: size)
        image.lockFocus()
        let rect = NSRect(x: 1, y: 2, width: 14, height: 10)
        let cap = NSRect(x: rect.maxX + 1, y: rect.midY - 2, width: 2, height: 4)
        let path = NSBezierPath(roundedRect: rect, xRadius: 2, yRadius: 2)
        NSColor.black.setStroke()
        path.lineWidth = 1.5
        path.stroke()
        NSBezierPath(rect: cap).stroke()
        let alpha = 0.2 + 0.6 * abs(sin(phase))
        NSColor.systemGreen.withAlphaComponent(alpha).setFill()
        NSBezierPath(roundedRect: rect.insetBy(dx: 1.5, dy: 1.5), xRadius: 1.5, yRadius: 1.5).fill()
        image.unlockFocus()
        image.isTemplate = false
        return image
    }

    static func dockBatteryIcon(size: CGFloat = 256) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()
        let padding: CGFloat = size * 0.12
        let w = size - padding * 2
        let h = w * 0.6
        let x = padding
        let y = (size - h) / 2
        let rect = NSRect(x: x, y: y, width: w, height: h)
        let capW = w * 0.08
        let capH = h * 0.35
        let cap = NSRect(x: rect.maxX + capW * 0.2, y: rect.midY - capH/2, width: capW, height: capH)
        let path = NSBezierPath(roundedRect: rect, xRadius: h * 0.15, yRadius: h * 0.15)
        NSColor(calibratedWhite: 0.1, alpha: 1.0).setFill()
        NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: size, height: size), xRadius: size*0.14, yRadius: size*0.14).fill()
        NSColor.white.setStroke()
        path.lineWidth = size * 0.03
        path.stroke()
        NSBezierPath(roundedRect: cap, xRadius: capH * 0.2, yRadius: capH * 0.2).stroke()
        image.unlockFocus()
        image.isTemplate = false
        return image
    }

    static func dockChargiIcon(size: CGFloat = 256) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()
        let bgRect = NSRect(x: 0, y: 0, width: size, height: size)
        let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: size*0.18, yRadius: size*0.18)
        let gradient = NSGradient(colors: [NSColor.systemBlue, NSColor.systemIndigo])
        gradient?.draw(in: bgPath, angle: 90)

        let center = NSPoint(x: size/2, y: size/2)
        let ringR = size * 0.32
        let ringPath = NSBezierPath()
        ringPath.appendArc(withCenter: center, radius: ringR, startAngle: 35, endAngle: 325, clockwise: false)
        NSColor.systemGreen.setStroke()
        ringPath.lineWidth = size * 0.06
        ringPath.stroke()

        let endAngle: CGFloat = 325
        let endRad = endAngle * .pi / 180
        let endPoint = NSPoint(x: center.x + ringR * cos(endRad), y: center.y + ringR * sin(endRad))
        let arrowSize = size * 0.08
        let a1 = NSPoint(x: endPoint.x + arrowSize * cos(endRad + .pi * 0.75), y: endPoint.y + arrowSize * sin(endRad + .pi * 0.75))
        let a2 = NSPoint(x: endPoint.x + arrowSize * cos(endRad - .pi * 0.75), y: endPoint.y + arrowSize * sin(endRad - .pi * 0.75))
        let arrow = NSBezierPath()
        arrow.move(to: endPoint)
        arrow.line(to: a1)
        arrow.line(to: a2)
        arrow.close()
        NSColor.systemGreen.setFill()
        arrow.fill()

        let clockR = size * 0.18
        let clockPath = NSBezierPath(ovalIn: NSRect(x: center.x - clockR, y: center.y - clockR, width: clockR*2, height: clockR*2))
        NSColor.white.setStroke()
        clockPath.lineWidth = size * 0.04
        clockPath.stroke()

        let hourLen = clockR * 0.6
        let minLen = clockR * 0.85
        let hourAngle: CGFloat = -50 * .pi / 180
        let minAngle: CGFloat = 20 * .pi / 180
        let hourEnd = NSPoint(x: center.x + hourLen * cos(hourAngle), y: center.y + hourLen * sin(hourAngle))
        let minEnd = NSPoint(x: center.x + minLen * cos(minAngle), y: center.y + minLen * sin(minAngle))
        let hands = NSBezierPath()
        hands.move(to: center)
        hands.line(to: hourEnd)
        hands.move(to: center)
        hands.line(to: minEnd)
        NSColor.white.setStroke()
        hands.lineWidth = size * 0.05
        hands.stroke()

        let bolt = NSBezierPath()
        let bw = size * 0.18
        let bh = size * 0.28
        let bx = center.x - bw * 0.35
        let by = center.y - bh * 0.35
        bolt.move(to: NSPoint(x: bx, y: by + bh))
        bolt.line(to: NSPoint(x: bx + bw * 0.55, y: by + bh * 0.55))
        bolt.line(to: NSPoint(x: bx + bw * 0.35, y: by + bh * 0.35))
        bolt.line(to: NSPoint(x: bx + bw, y: by))
        bolt.line(to: NSPoint(x: bx + bw * 0.45, y: by + bh * 0.45))
        bolt.line(to: NSPoint(x: bx + bw * 0.65, y: by + bh * 0.65))
        bolt.close()
        NSColor.systemYellow.setFill()
        bolt.fill()

        image.unlockFocus()
        image.isTemplate = false
        return image
    }
}
