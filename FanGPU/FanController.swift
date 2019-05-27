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
        mainFan = try SMCKit.allFans().first{$0.name.hasPrefix("Main")}!
        print(mainFan)
        let minSpeed = 1200
        appropriateFanForTemperature = [
        .normal:minSpeed,
        .hot:(minSpeed+mainFan.maxSpeed)/2,
        .veryHot:mainFan.maxSpeed-1
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
//        print("setting min fan speed to \(speed)")
        try SMCKit.fanSetMinSpeed(0, speed: speed)
    }

    func updateFanSpeed() throws {
        try setFanMinimumSpeed(speed: appropriateFanForTemperature[getGpuTemperature()]!)
    }
}
