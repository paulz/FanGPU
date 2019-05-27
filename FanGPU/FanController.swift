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

    init() throws {
        gpuDiodeSensor = try SMCKit.allKnownTemperatureSensors().first{$0.name == "GPU_0_DIODE"}!
        mainFan = try SMCKit.allFans().first{$0.name == "Main"}!
        appropriateFanForTemperature = [
        .normal:mainFan.minSpeed,
        .hot:(mainFan.minSpeed+mainFan.maxSpeed)/2,
        .veryHot:mainFan.maxSpeed
        ]
    }

    let appropriateFanForTemperature: [GpuTemp: Int]

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

    func setFanMinimumSpeed(speed: Int) throws {
        try SMCKit.fanSetMinSpeed(0, speed: speed)
    }

    func updateFanSpeed() throws {
        try setFanMinimumSpeed(speed: appropriateFanForTemperature[getGpuTemperature()]!)
    }
}
