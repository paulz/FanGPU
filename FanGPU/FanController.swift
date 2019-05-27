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

enum FanSpeed: Int {
    case normal = 1200
    case fast = 2000
    case veryFast = 2793
}

struct FanController {
    let gpuDiodeSensor: TemperatureSensor

    init() throws {
        gpuDiodeSensor = try SMCKit.allKnownTemperatureSensors().first{$0.name == "GPU_0_DIODE"}!
    }

    let appropriateFanForTemperature: [GpuTemp: FanSpeed] = [
        .normal:.normal,
        .hot:.fast,
        .veryHot:.veryFast
    ]

    func work() throws {
        while true {
            try updateFanSpeed()
            sleep(1)
        }
    }

    func getGpuTemperature() throws -> GpuTemp {
        let gpuTemp = try SMCKit.temperature(gpuDiodeSensor.code)
        return GpuTemp(celcius: Int(gpuTemp))
    }

    func setFanMinimumSpeed(speed: FanSpeed) throws {
        try SMCKit.fanSetMinSpeed(0, speed: speed.rawValue)
    }

    func updateFanSpeed() throws {
        try setFanMinimumSpeed(speed: appropriateFanForTemperature[getGpuTemperature()]!)
    }
}
