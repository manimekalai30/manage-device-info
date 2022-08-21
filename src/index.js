const { insertRecords } = require("./dynamoDbHandler");
const { getJsonObject } = require("./helper");
const moment = require("moment");

/**
 * Lambda function to insert device details
 * @param {Object} event 
 * @returns 
 */
exports.handler = async (event) => {
    event = getJsonObject(event.body);
    let { serialNumber = "", deviceId = "" } = event || {};

    // for db params to insert records
    let putParams = {
        serialNumber,
        deviceId,
        createdAt: `${moment.now()}`,
        updatedAt: `${moment.now()}`

    };
    let transactions = await insertRecords(putParams);
    // TODO implement
    const response = {
        statusCode: 200,
        'Content-Type':"application/json",
        message: "Device details inserted succesfully",
        body: JSON.stringify(transactions),
    };
    return response;
};