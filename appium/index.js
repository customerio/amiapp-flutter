const { remote } = require('webdriverio');
const { identifyProfile } = require('./tests/IdentifyProfile.js');

const appiumOS = process.env.APPIUM_OS ?? 'android';
const osSpecificOps = appiumOS === 'android' ? {
    'platformName': 'Android',
    'appium:deviceName': 'emulator-5554',
    'appium:app': __dirname + '/../build/app/outputs/apk/debug/app-debug.apk',
    'appium:logcatFormat': 'raw',
    'appium:logcatFilterSpecs': ['*:S', '[CIO]:D'],
} : process.env.APPIUM_OS === 'ios' ? {
    'platformName': 'iOS',
    'appium:platformVersion': '12.2',
    'appium:deviceName': 'iPhone X',
    'appium:noReset': true,
    'appium:app': __dirname + '/../apps/Runner.zip',
} : {};

const proxy = {
    proxyType: "manual",
    httpProxy: "customer.io",
    noProxy: "127.0.0.1,localhost"
};

const capabilities = {
    ...osSpecificOps,
    'appium:automationName': 'UiAutomator2',
    'appium:appPackage': 'io.customer.amiapp_flutter',
    'appium:appActivity': '.MainActivity',
    'appium:retryBackoffTime': 500,
    'appium:maxRetryCount': 3,
    'appium:autoGrantPermissions': true,
    proxy: proxy,
};

const wdOpts = {
    host: process.env.APPIUM_HOST || 'localhost',
    port: parseInt(process.env.APPIUM_PORT, 10) || 4723,
    logLevel: 'debug',
    capabilities: capabilities,
};

async function runTest() {
    const driver = await remote(wdOpts);
    try {
        await identifyProfile(driver)
    } finally {
        await driver.pause(1000);
        await driver.deleteSession();
    }
}

runTest().catch(console.error);
