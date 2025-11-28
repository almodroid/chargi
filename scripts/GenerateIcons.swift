import AppKit

func drawBatteryIcon(size: CGFloat) -> NSImage {
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
    NSColor(calibratedWhite: 0.1, alpha: 1.0).setFill()
    NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: size, height: size), xRadius: size*0.14, yRadius: size*0.14).fill()
    let path = NSBezierPath(roundedRect: rect, xRadius: h * 0.15, yRadius: h * 0.15)
    NSColor.white.setStroke()
    path.lineWidth = size * 0.05
    path.stroke()
    NSBezierPath(roundedRect: cap, xRadius: capH * 0.2, yRadius: capH * 0.2).stroke()
    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, url: URL) throws {
    guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "GenerateIcons", code: 1, userInfo: [NSLocalizedDescriptionKey: "PNG conversion failed"])
    }
    try png.write(to: url)
}

let fm = FileManager.default
let cwd = URL(fileURLWithPath: fm.currentDirectoryPath)
let appiconset = cwd.appendingPathComponent("Assets.xcassets/AppIcon.appiconset")
let iconset = cwd.appendingPathComponent("Assets/AppIcon.iconset")
try? fm.createDirectory(at: appiconset, withIntermediateDirectories: true)
try? fm.createDirectory(at: iconset, withIntermediateDirectories: true)

let specs: [(name: String, size: CGFloat)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024)
]

for spec in specs {
    let img = drawBatteryIcon(size: spec.size)
    let filename = spec.name + ".png"
    try savePNG(img, url: appiconset.appendingPathComponent(filename))
    try savePNG(img, url: iconset.appendingPathComponent(filename))
}

print("Generated PNGs in \(appiconset.path) and \(iconset.path)")

