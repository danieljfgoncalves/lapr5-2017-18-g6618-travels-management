var express = require('express');
var router = express.Router();
var prologworker = require('../services/prologWorker');
var rootPredicateName = 'calculatePlan';
var assertFactName = 'location';


/* GET method for plans */
router.post('/',function(req, res, next) {

    var waypoints = req.body.points;
   
    if(waypoints)
    {
        var parsedPrologArray='[';
        for (var i = 0, len = waypoints.length - 1; i < len; i++){
            parsedPrologArray+= '[' + waypoints[i].latitude + ',' + waypoints[i].longitude +'],';
        }
        parsedPrologArray+= '[' + waypoints[waypoints.length-1].latitude + ',' + waypoints[waypoints.length-1].longitude +']';
        parsedPrologArray += ']';
        result = prologworker.callPredicateSingleResult(rootPredicateName,parsedPrologArray);
        res.status(200).json(result);
    }
    
    else{
        res.status(404).json('No valid waypoints found in request.');
    }

});

module.exports = router;
