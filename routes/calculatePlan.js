/**
 * calculatePlan.js
 */

var express = require('express');
var router = express.Router();
var planController = require('../controllers/plansController');

/**
 * Get method for plans. 
 * Waypoints should be cointained within the body in the following format : {
 *     "points": [{
 *         "latitude": "value",
 *         "longitude": "value"
 *     }]
 * }
 */
router.post('/', planController.calculatePlan);


module.exports = router;
