var fs = require('fs');
var parser = require('xml2json');

/**
 * Reads a XML file into a JSON object.
 * @param {*} xmlFilePath the path of the XML file
 */
function xmlToJson(xmlFilePath)
{
    fs.readFile( xmlFilePath, function(err, data) {
        var json = parser.toJson(data);
        console.log("to json ->", json);
    });
}


/**
 * Function exports.
 */
module.exports = { 
    xmlToJson
}