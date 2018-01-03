var prologworker = require('../services/prologWorker');
var xmlworker = require('../services/xmlWorker');
var rootPredicateName = 'planTravel';
var assertFactName = 'location';

/**
 * Calculates a delivery plan having into account the waypoints, using prolog interface.
 * @param {*} req the http request
 * @param {*} res the http result
 */
calculatePlan = (req, res) => {

    
    xmlworker.xmlToJson("../utils/xml.xml").then(data => {
        
  
    
    
    if (!req.body.departure) {
        res.status(400).send({"Message":"Departure point must be specified."});
        return;
    }

    if (!req.body.pharmacies || req.body.pharmacies.length < 1) {
        res.status(400).send({"Message":"Must have at least one pharmacy."});
        return;
    }

    var departure = '(' + req.body.departure.name + ',' + req.body.departure.latitude +
                    ',' + req.body.departure.longitude + ',' + req.body.departure.time +
                    ')';
    
    var pharmacies = '[';
    req.body.pharmacies.forEach( (phar, idx, array) => {
        pharmacies += '(' + phar.name + ',' + phar.latitude +
                      ',' + phar.longitude + ',' + phar.limitTime +
                      ')';

        pharmacies += idx == (array.length-1) ? ']' : ',';
    });

    parsedPrologArray = departure + ',' + pharmacies;
    
    result = prologworker.callPredicateSingleResult(rootPredicateName, parsedPrologArray);
    res.status(200).json(result);
    });

}


returnParsedPlan = (url, plan) => {

}


/**
 * Function exports.
 */
module.exports = { 
    calculatePlan
}