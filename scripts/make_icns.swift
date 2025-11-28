import AppKit

func savePNG(_ image: NSImage, to url: URL) {
    guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff), let data = rep.representation(using: .png, properties: [:]) else { return }
    try? data.write(to: url)
}

let cwd = FileManager.default.currentDirectoryPath
let iconsetPath = URL(fileURLWithPath: cwd).appendingPathComponent("Resources/AppIcon.iconset")
try? FileManager.default.createDirectory(at: iconsetPath, withIntermediateDirectories: true)

let sizes: [(Int, String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

for (s, name) in sizes {
    let img = IconFactory.dockChargiIcon(size: CGFloat(s))
    let url = iconsetPath.appendingPathComponent(name)
    savePNG(img, to: url)
}
