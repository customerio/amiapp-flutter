const { tapElement } = require('../actions');
const { BUTTON_CLASS, INPUT_FILED_CLASS } = require('../constants');

exports.identifyProfile = async function (driver) {
    const firstNameField = await driver.$$(INPUT_FILED_CLASS)[0];
    await tapElement(driver, firstNameField);
    await firstNameField.setValue("Appium T1");

    const emailField = await driver.$$(INPUT_FILED_CLASS)[1];
    await tapElement(driver, emailField);
    await emailField.setValue("t1@appium.com");

    console.log("First Name: ", await firstNameField.getText());
    console.log("Email: ", await emailField.getText());

    const loginButton = await driver.$$(BUTTON_CLASS)[1];
    await driver.pause(500);
    await loginButton.click();
    await driver.pause(3000);

    const logoutButton = await driver.$$(BUTTON_CLASS)[6];
    await logoutButton.click();
    await driver.pause(500);
}
