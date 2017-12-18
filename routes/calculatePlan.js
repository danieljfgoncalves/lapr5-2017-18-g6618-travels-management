var express = require('express');
var router = express.Router();
var planController = require('../controllers/plansController');


/**
 * Get method for plans. 
 * Waypoints should be cointained within the body in the following format : {
	"points": [{
			"latitude": "value",
			"longitude": "value"
        }]
    }
 */
router.post('/',function(req, res, next) {

    var waypoints = req.body.points;
   
    if(waypoints)
    {
        result =  planController.calculatePlan(waypoints);
        res.status(200).json(result);
    }
    else{
        res.status(404).json('No valid waypoints found in request.');
        //xmlworker.xmlToJson("../utils/xml.xml");
    }

});


module.exports = router;
