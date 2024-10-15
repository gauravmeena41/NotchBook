//
//  BluetoothManager.swift
//  NotchBook
//
//  Created by Guruprasad Meena on 13/10/24.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on. Checking connected devices...")
            checkConnectedDevices()
        case .poweredOff:
            print("Bluetooth is powered off.")
        case .resetting:
            print("Bluetooth is resetting.")
        case .unauthorized:
            print("Bluetooth is unauthorized.")
        case .unsupported:
            print("Bluetooth is unsupported.")
        case .unknown:
            print("Bluetooth state is unknown.")
        @unknown default:
            print("A previously unknown state occurred.")
        }
    }

    private func checkConnectedDevices() {
        // Retrieve connected peripherals
        let connectedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [])
        if connectedPeripherals.isEmpty {
            print("No connected Bluetooth devices found.")
        } else {
            print("Currently connected Bluetooth devices:")
            for device in connectedPeripherals {
                print(device.name ?? "Unknown device")
            }
        }
    }
}
