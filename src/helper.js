const getJsonObject = (str) => {
    let jsonObject = {};
    try {
      jsonObject = JSON.parse(str);
    } catch (e) {
      console.error("Unable to parse string object, Invalid Payload");
    }
    return jsonObject;
  };
  
  
  module.exports= {getJsonObject};