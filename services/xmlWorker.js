var fs = require('fs');
var parser = require('xml2json');
var _ = require('underscore');
var prologWorker = require('./prologWorker');

/**
 * Reads a XML file into a JSON object and asserts data into .pl knowledge base.
 * @param {*} xmlFilePath the path of the XML file
 */
function xmlToJson(xmlFilePath)
{
    fs.readFile( xmlFilePath, function(err, data) {
        var dataJson = parser.toJson(data);
        var parsedJson = JSON.parse(dataJson);
        _.each(parsedJson.osm.node,(element,index,list)=>{
        
            prologWorker.assertFact('location(',element.id + ',' + '(' + element.lat + ',' + element.lon + '))');

        });

        _.each(parsedJson.osm.way,(elementWay,indexWay,list)=>{

          _.each(elementWay.nd,(element,index,list)=>{

            _.each(elementWay.nd,(elementNext,index2,list)=>{

                if(index2 > index)
                {
                    prologWorker.assertFact('connection(' , element.ref + ',' + elementNext.ref + ')');
                    console.log('connection('+ element.ref + ',' + elementNext.ref + ')');
                }
            });

          });

        });
        
        console.log('=================================\nFacts asserted into knowledge base.\n=================================\n');
        
         

       
    });
}


/**
 * Function exports.
 */
module.exports = { 
    xmlToJson
}