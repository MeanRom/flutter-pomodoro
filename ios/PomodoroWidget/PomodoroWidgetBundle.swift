//
//  PomodoroWidgetBundle.swift
//  PomodoroWidget
//
//  Created by Thomas Moerman on 22/12/2025.
//

import WidgetKit
import SwiftUI

@main
struct PomodoroWidgetBundle: WidgetBundle {
    var body: some Widget {
        PomodoroWidget()
        PomodoroWidgetControl()
        PomodoroWidgetLiveActivity()
    }
}
