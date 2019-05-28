import Foundation
import SMCKit

enum GpuTemp: Int {
    case normal
    case hot = 100
    case veryHot = 106

    init(celcius: Int) {
        switch celcius {
        case GpuTemp.veryHot.rawValue...:
            self = .veryHot
        case GpuTemp.hot.rawValue...GpuTemp.veryHot.rawValue:
            self = .hot
        default:
            self = .normal
        }
    }
}

struct FanController {
    let gpuDiodeSensor: TemperatureSensor
    let mainFan: Fan
    var previousSpeed: Int = 0

    init() throws {
        gpuDiodeSensor = try SMCKit.allKnownTemperatureSensors().first{$0.name == "GPU_0_DIODE"}!
        mainFan = try SMCKit.allFans().first{$0.name.hasPrefix("Main")}!
        print(mainFan)
        let minSpeed = 1200
        appropriateFanForTemperature = [
        .normal:minSpeed,
        .hot:(minSpeed+mainFan.maxSpeed)/2,
        .veryHot:mainFan.maxSpeed - 10
        ]
    }

    let appropriateFanForTemperature: [GpuTemp: Int]

    mutating func work() throws {
        try testMaxFanSpeed()
        while true {
            try updateFanSpeed()
            Thread.sleep(forTimeInterval: 2)
        }
    }

    func getGpuTemperature() throws -> GpuTemp {
        let gpuTemp = try SMCKit.temperature(gpuDiodeSensor.code)
        return GpuTemp(celcius: Int(gpuTemp))
    }

    mutating func setFanMinimumSpeed(speed: Int) throws {
        if previousSpeed != speed {
            print("changing minimum fan speed to \(speed)")
            try SMCKit.fanSetMinSpeed(0, speed: speed)
            previousSpeed = speed
        }
    }

    mutating func testMaxFanSpeed() throws {
        let maxSpeed = appropriateFanForTemperature[.veryHot]!
        print("testing maximum fan speed: \(maxSpeed)")
        try SMCKit.fanSetMinSpeed(0, speed: maxSpeed)
    }

    mutating func updateFanSpeed() throws {
        try setFanMinimumSpeed(speed: appropriateFanForTemperature[getGpuTemperature()]!)
    }
}
