//
//  main.swift
//  FanGPU
//
//  Created by Paul Zabelin on 5/26/19.
//  Copyright © 2019 Paul Zabelin. All rights reserved.
//

import Foundation
import SMCKit

func disableOutputBuffering() {
    setlinebuf(stdout)
}

func enablePrintOutput() {
    disableOutputBuffering()
}

enablePrintOutput()

do {
    try SMCKit.open()
} catch {
    print("Failed to open a connection to the SMC")
    exit(EX_UNAVAILABLE)
}

defer {
    SMCKit.close()
}

do {
    let fanController = try FanController()
    try fanController.work()
} catch {
    NSLog("error: \(error)")
}
