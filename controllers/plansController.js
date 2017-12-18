var prologworker = require('../services/prologWorker');
var xmlworker = require('../services/xmlWorker');
var rootPredicateName = 'calculatePlan';
var assertFactName = 'location';


/**
 * Calculates a delivery plan having into account the waypoints, using prolog interface.
 * @param {*} waypoints the waypoints array
 */
function calculatePlan(waypoints)
{
    var parsedPrologArray='[';
    for (var i = 0, len = waypoints.length - 1; i < len; i++){
        parsedPrologArray+= '[' + waypoints[i].latitude + ',' + waypoints[i].longitude +'],';
    }

    parsedPrologArray+= '[' + waypoints[waypoints.length - 1].latitude + ',' + waypoints[waypoints.length - 1].longitude +']]';

    return prologworker.callPredicateSingleResult(rootPredicateName,parsedPrologArray);  
}


/**
 * Function exports.
 */
module.exports = { 
    calculatePlan
}