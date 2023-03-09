const { BUTTON_CLASS, INPUT_FILED_CLASS } = require('../constants');

exports.identifyProfile = async function (driver) {
    const firstNameField = await driver.$$(INPUT_FILED_CLASS)[0];
    const emailField = await driver.$$(INPUT_FILED_CLASS)[1];
    const loginButton = await driver.$$(BUTTON_CLASS)[1];

    await firstNameField.setValue("Appium T1");
    await emailField.setValue("t1@appium.com");

    console.log("First Name: ", await firstNameField.getText());
    console.log("Email: ", await emailField.getText());

    loginButton.click();

    await driver.pause(3000);
}
