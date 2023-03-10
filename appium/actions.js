module.exports = {
    tapElement: async function (driver, element, pause = 500) {
        return driver.touchAction({
            action: 'tap',
            element: element,
        }).then(result => driver.pause(pause));
    },
};
