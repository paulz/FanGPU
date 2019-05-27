//
//  main.swift
//  FanGPU
//
//  Created by Paul Zabelin on 5/26/19.
//  Copyright © 2019 Paul Zabelin. All rights reserved.
//

import Foundation
import SMCKit

print("Hello, World!")

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
    let sensors = try SMCKit.allKnownTemperatureSensors()
    let gpuSensor = sensors.first{$0.name == "GPU_0_DIODE"}!

    let gpuTemp = try SMCKit.temperature(gpuSensor.code)
    print(gpuTemp)

//    try SMCKit.fanSetMinSpeed(0, speed: 2000)
    let fans = try SMCKit.allFans()
    fans.forEach {
        print($0)
    }

} catch {
    print(error)
}


