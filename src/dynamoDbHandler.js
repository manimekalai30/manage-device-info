const AWS = require("aws-sdk");
const docClient = new AWS.DynamoDB.DocumentClient();
/**
 *
 * @param {Object} putData
 * this function inserts payload to Table in Dynamo DB
 */
const insertRecords = (putData) => {
    return new Promise(async (resolve, reject) => {
        docClient.put(
            {
                TableName: "device-information",
                Item: putData,
            },
            (error, data) => {
                if (error) {
                    console.log(
                        `Error occurred while inserting the device information`, error
                    );
                    reject(error);
                } else {
                    resolve("Data Inserted successfully");
                }
            }
        );
    });
};

module.exports = { insertRecords };
