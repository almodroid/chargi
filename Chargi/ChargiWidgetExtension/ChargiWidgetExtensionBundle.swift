//
//  ChargiWidgetExtensionBundle.swift
//  ChargiWidgetExtension
//
//  Created by almo on 07/06/1447 AH.
//

import WidgetKit
import SwiftUI

@main
struct ChargiWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        ChargiWidgetExtension()
        ChargiWidgetExtensionControl()
    }
}
