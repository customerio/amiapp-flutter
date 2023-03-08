const wdio = require("webdriverio");
const assert = require("assert");

const opts = {
    path: '/wd/hub',
    port: 4723,
    capabilities: {
        platformName: "Android",
        platformVersion: "11",
        deviceName: "emulator-5554",
        app: "/Users/mrehan/code/amiapp-flutter/build/app/outputs/apk/debug/app-debug.apk",
        appPackage: "io.customer.amiapp_flutter",
        appActivity: ".MainActivity",
        automationName: "UiAutomator2"
    }
};

async function main() {
    const client = await wdio.remote(opts);

    const field = await client.$("android.widget.EditText");
    await field.setValue("Hello World!");
    const value = await field.getText();
    assert.strictEqual(value, "Hello World!");

    await client.deleteSession();
}

main();
