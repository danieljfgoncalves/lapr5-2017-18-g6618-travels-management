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

    return new Promise( (resolve, reject) => {

        fs.readFile( xmlFilePath, function(err, data) {
            var facts="";
            var dataJson = parser.toJson(data);
            var parsedJson = JSON.parse(dataJson);
            _.each(parsedJson.osm.node,(element,index,list)=>{
            
                prologWorker.assertFact('location('+element.id + ',' + '(' + element.lat + ',' + element.lon + '))');
                //facts+='location(' + element.id + ',' + '(' + element.lat + ',' + element.lon + '))\n';
               // console.log('location(' + element.id + ',' + '(' + element.lat + ',' + element.lon + '))');
            });

            _.each(parsedJson.osm.way,(elementWay,indexWay,list)=>{
            //console.log("===================\n");
            _.each(elementWay.nd,(element,index,list)=>{

                _.each(elementWay.nd,(elementNext,index2,list)=>{

                    if(index2 > index && index2-index == 1)
                    {
                        if(elementWay.tag && elementWay.tag.k=="oneway" && elementWay.tag.v=="yes")
                        {
                        prologWorker.assertFact('connection(' + element.ref + ',' + elementNext.ref + ')');
                        //facts+='connection(' + element.ref + ',' + elementNext.ref + ')\n';
                        //console.log('connection('+ element.ref + ',' + elementNext.ref + ')');
                        
                        }
                        else
                        {
                            prologWorker.assertFact('connection(' + element.ref + ',' + elementNext.ref + ')');
                            prologWorker.assertFact('connection(' + elementNext.ref + ',' + element.ref + ')'); 
                            //facts+='connection(' + element.ref + ',' + elementNext.ref + ')\n';
                            //facts+='connection(' + elementNext.ref + ',' + element.ref + ')\n';
                           // console.log('connection('+ element.ref + ',' + elementNext.ref + ')');
                            //console.log('connection('+ elementNext.ref + ',' + element.ref + ')');     
                        }
                    }
                });

            });
            
            });
            
            console.log('=================================\nFacts asserted into knowledge base.\n=================================\n');
            //writeToFile("../utils/facts.txt",facts);
            resolve();   
        });

    });
}

function writeToFile(filePath,data)
{
    var fs = require('fs');
    fs.writeFile(filePath, data, function(err) {
        if(err) {
            return console.log(err);
        }

        console.log("The file was saved!");
    }); 
}


/**
 * Function exports.
 */
module.exports = { 
    xmlToJson
}