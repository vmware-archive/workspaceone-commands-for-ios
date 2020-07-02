//
//  ContextSetupTests.swift
//  ActionTests
//
//  Created by Mohammed Lazim on 7/13/19.
//  Copyright © 2019-2020 VMware, Inc.

import XCTest

@testable import Actions

private let validConfigurations: [String: Any]  = [
    "DEVICE_UID": "1231235245",

    "API_HOSTNAME": "https://cnaapp.ssdevrd.com/api",
    "API_KEY": "sadfsad23234",
    "API_USERNAME": "naveen",
    "API_PASSWORD": "naveen5",
    
    "BACKGROUND_IMAGE": "https://www.testwebsite.com/image.png",
    
    "ENABLE_TROUBLESHOOTING": 1,

    "ACTION_WIPE": 1,
    "ACTION_LOCK": 1,
    "ACTION_QUERY": 1,
    "ACTION_ENTERPRISEWIPE": 1
]

private struct TestConfigurationContextSetupProvider: UserDefaultsContextSetupProvider {
    var context: ApplicationContext = ApplicationContext()

    var store: UserDefaults {
        return .standard
    }

    var configurationKey: String {
        return TestConfigurationContextSetupProvider.testConfigKey
    }

    static var testConfigKey = "com.air-watch.action.configuration.managed"
}

class ContextSetupTests: XCTestCase {

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: TestConfigurationContextSetupProvider.testConfigKey)

        super.tearDown()
    }


    func testContextSetupWithValidConfigurations() {

        UserDefaults.standard.set(validConfigurations, forKey: TestConfigurationContextSetupProvider.testConfigKey)

        let sut = TestConfigurationContextSetupProvider()
        let status = sut.setup()
        XCTAssertEqual(status, .success, "Context should have been setup correctly")

    }

    func testContextSetupWithMissingConfigurationInfo() {

        let sut = TestConfigurationContextSetupProvider()

        let status = sut.setup()
        XCTAssertEqual(status, ContextSetupStatus.missingConfigInfo, "Context should have been failed when config map is missing")

    }

    func testContextSetupWithMissingDeviceIdentifier() {

        var newConfig = validConfigurations
        newConfig.removeValue(forKey: "DEVICE_UID")

        UserDefaults.standard.set(newConfig, forKey: TestConfigurationContextSetupProvider.testConfigKey)

        let sut = TestConfigurationContextSetupProvider()

        let status = sut.setup()
        XCTAssertEqual(status, ContextSetupStatus.missingDeviceIdentifier, "Context should have been failed when device info is missing")

    }

    func testContextSetupWithMissingAPIConfig() {

        var newConfig = validConfigurations
        newConfig.removeValue(forKey: "API_HOSTNAME")

        UserDefaults.standard.set(newConfig, forKey: TestConfigurationContextSetupProvider.testConfigKey)

        let sut = TestConfigurationContextSetupProvider()


        var status = sut.setup()
        XCTAssertEqual(status, ContextSetupStatus.missingAPIInfo, "Context should have been failed when API config is missing")

        newConfig.removeValue(forKey: "API_KEY")
        status = sut.setup()
        XCTAssertEqual(status, ContextSetupStatus.missingAPIInfo, "Context should have been failed when API config is missing")

        newConfig.removeValue(forKey: "API_USERNAME")
        status = sut.setup()
        XCTAssertEqual(status, ContextSetupStatus.missingAPIInfo, "Context should have been failed when API config is missing")

        newConfig.removeValue(forKey: "API_PASSWORD")
        status = sut.setup()
        XCTAssertEqual(status, ContextSetupStatus.missingAPIInfo, "Context should have been failed when API config is missing")

    }

    func testContextSetupWithNoSupportedActions() {

        var newConfig = validConfigurations
        newConfig.removeValue(forKey: "ACTION_WIPE")
        newConfig.removeValue(forKey: "ACTION_LOCK")
        newConfig.removeValue(forKey: "ACTION_QUERY")
        newConfig.removeValue(forKey: "ACTION_ENTERPRISEWIPE")

        UserDefaults.standard.set(newConfig, forKey: TestConfigurationContextSetupProvider.testConfigKey)

        let sut = TestConfigurationContextSetupProvider()

        let status = sut.setup()
        XCTAssertEqual(status, ContextSetupStatus.noSupportedActions, "Context should have been failed when no supported actions are found")

    }

}
