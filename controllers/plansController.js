var prologworker = require('../services/prologWorker');
var xmlworker = require('../services/xmlWorker');
const gaPredicate = 'ga';
const  gaTwPredicate = 'gatw';

var assertFactName = 'location';
var request = require('request');

/**
 * Calculates a delivery plan having into account the waypoints, using prolog interface.
 * @param {*} req the http request
 * @param {*} res the http result
 */
calculatePlan = (req, res) => {
        
    if (!req.body.departure) {
        res.status(400).send({"Message":"Departure point must be specified."});
        return;
    }

    if (!req.body.pharmacies || req.body.pharmacies.length < 2) {
        res.status(400).send({"Message":"Must have at least two pharmacies."});
        return;
    }
    if(req.body.url)
         res.status(200).send({"Message":"Plan calculation requested with success. Should respond within moments."});
    var departure = '(' + req.body.departure.name.toLowerCase().replace(/ /g,"_") + ',' + '(' + req.body.departure.latitude +
                    ',' + req.body.departure.longitude + ')' + ',' + req.body.departure.time +
                    ')';
    
    var pharmacies = '[';
    req.body.pharmacies.forEach( (phar, idx, array) => {
        pharmacies += '(' + phar.name.toLowerCase().replace(/ /g,"_") + ',' + '('+ phar.latitude +
                      ',' + phar.longitude + ')' + ',' + phar.time +
                      ')';

        pharmacies += idx == (array.length-1) ? ']' : ',';
    });

    parsedPrologArray = departure + ',' + pharmacies;
    var algorithm_name = req.body.algorithm;
    if(!algorithm_name)
    {
        algorithm_name = gaTwPredicate;
    }
    switch(algorithm_name)
    {
        case gaPredicate:
            result = prologworker.callPredicateSingleResult(gaPredicate, parsedPrologArray);
        break;
           
        default:
            result = prologworker.callPredicateSingleResult(gaTwPredicate, parsedPrologArray);
    }

    if(!req.body.url)
        res.status(200).json(result);
    else
        returnParsedPlan(req.body.url,result);
        

    return;
}


/**
 * Posts a parsed plan into the given callback route.
 * @param {*} url the callback URL
 * @param {*} plan json object that contains the plan
 */
returnParsedPlan = (url, plan) => {

    var options ={
        url: url,
        headers: {'content-type' : 'application/json'},
        method: 'POST',
        json: {plan: plan}
    };

    request(options, function(error, res, body) {

        if (error) {
            console.log({"Message":"Error while sending response. Check  the CallBack URL."});
        }
        else{
            console.log({"Message":"Response sent with success."});
        }
    });
}


/**
 * Function exports.
 */
module.exports = { 
    calculatePlan
}