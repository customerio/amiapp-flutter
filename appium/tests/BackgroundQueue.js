const { tapElement } = require('../actions');
const { BUTTON_RANDOM_EVENT, BUTTON_CLASS, INPUT_FILED_CLASS, BUTTON_CUSTOM_EVENT, BUTTON_SEND_EVENT} = require('../constants');

const defaultFullName = "Appium T1";
const defaultEmail = "t1@appium.com";
const randomEventName = "EventJasonTest10"

exports.backgroundQueue = async function (driver, name = defaultFullName, email = defaultEmail) {
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

    const customEvent = await driver.$(BUTTON_CUSTOM_EVENT);
    customEvent.click();
    await driver.pause(3000);

    const eventName = await driver.$$(INPUT_FILED_CLASS)[0];
    await tapElement(driver, eventName);
    await eventName.setValue(randomEventName);

    const propertyName = await driver.$$(INPUT_FILED_CLASS)[1];
    await tapElement(driver, propertyName);
    await propertyName.setValue(randomEventName);

    const propertyValue = await driver.$$(INPUT_FILED_CLASS)[2];
    await tapElement(driver, propertyValue);
    await propertyValue.setValue(randomEventName);

    const sendEvent = await driver.$(BUTTON_SEND_EVENT);
    sendEvent.click();

    const backButton = await driver.$$(BUTTON_CLASS)[0];
    backButton.click();


    const randomEvent = await driver.$(BUTTON_RANDOM_EVENT);
    for (let step = 0; step < 10; step++) { 
        randomEvent.click();
        console.log("clicked on random event: " + step);
        await driver.pause(1000);
      }

    await driver.pause(3000);
    
    const http = require("https");

    const options = {
      "method": "GET",
      "hostname": "api.customer.io",
      "path": "/v1/customers/95d207003132/activities?type=event&name=EventJasonTest10",
      "headers": {
        "Authorization": "Bearer f1038bdc3413f94cbdfc9c15691d587b"
      }
    };
    
    const req = http.request(options, function (res) {
      const chunks = [];
    
      res.on("data", function (chunk) {
        chunks.push(chunk);
      });
    
      res.on("end", function () {
        const body = Buffer.concat(chunks);
        
        var logs = body.toString();
        console.log(logs);  
      });
    });
    
    req.end();
}
