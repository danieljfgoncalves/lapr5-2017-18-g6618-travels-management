var fs = require('fs');
var parser = require('xml2json');
var _ = require('underscore');


/**
 * Reads a XML file into a JSON object and asserts data into .pl knowledge base.
 * @param {*} xmlFilePath the path of the XML file
 */
function xmlToPl(xmlFilePath, outputFilePath)
{

    return new Promise( (resolve, reject) => {

        fs.readFile( xmlFilePath, function(err, data) {
            var facts="";
            var dataJson = parser.toJson(data);
            var parsedJson = JSON.parse(dataJson);
            _.each(parsedJson.osm.node,(element,index,list)=>{
            
                facts+='location(' + element.id + ',' + '(' + element.lat + ',' + element.lon + ')).\n';
                
            });

            _.each(parsedJson.osm.way,(elementWay,indexWay,list)=>{
          
            _.each(elementWay.nd,(element,index,list)=>{

                _.each(elementWay.nd,(elementNext,index2,list)=>{

                    if(index2 > index && index2-index == 1)
                    {
                        if(elementWay.tag && elementWay.tag.k=="oneway" && elementWay.tag.v=="yes")
                        {
                         facts+='connection(' + element.ref + ',' + elementNext.ref + ').\n';
                        }
                        else
                        {
                            facts+='connection(' + element.ref + ',' + elementNext.ref + ').\n';
                            facts+='connection(' + elementNext.ref + ',' + element.ref + ').\n';
                        }
                    }
                });

            });
            
            });
            
            writeToFile(outputFilePath,facts);
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
    xmlToPl
}