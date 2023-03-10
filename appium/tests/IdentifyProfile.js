const { tapElement } = require('../actions');
const { BUTTON_CLASS, INPUT_FILED_CLASS } = require('../constants');

const defaultFullName = "Appium T1";
const defaultEmail = "t1@appium.com";

exports.identifyProfile = async function (driver, name = defaultFullName, email = defaultEmail) {
    const firstNameField = await driver.$$(INPUT_FILED_CLASS)[0];
    await tapElement(driver, firstNameField);
    await firstNameField.setValue(name);

    const emailField = await driver.$$(INPUT_FILED_CLASS)[1];
    await tapElement(driver, emailField);
    await emailField.setValue(email);

    console.log("First Name: ", await firstNameField.getText());
    console.log("Email: ", await emailField.getText());

    const loginButton = await driver.$$(BUTTON_CLASS)[1];
    await driver.pause(500);
    await loginButton.click();
    const logs = await driver.getLogs('logcat');

    let desiredActionLogMessage = `identify profile ${email}`;
    let desiredActionLogMessageCount = logs.filter(e => e.message === desiredActionLogMessage).length;
    if (desiredActionLogMessageCount < 1) {
        console.log("Profile identification failed");
        throw new Error("Profile identification failed");
    }

    console.log(`Profile successfully identified ${desiredActionLogMessageCount} times`);
    await driver.pause(3000);

    const logoutButton = await driver.$$(BUTTON_CLASS)[6];
    await logoutButton.click();
    await driver.pause(500);
}
