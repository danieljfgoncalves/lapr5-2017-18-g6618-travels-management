var swipl = require('swipl');

swipl.initialise();

swipl.call('working_directory(_, utils)');
swipl.call('consult(base_knowledge)');


/**
 * Asserts a fact into a prolog knowledge base.
 * @param {*} factName The name of the fact
 * @param {*} factArgs The arguments of the fact
 */
function assertFact(factName,factArgs)
{
    swipl.assert(factName + '(' + factArgs +')');
}
 
/**
 * Calls a prolog predicate with given args.
 * @param {*} predicateName The name of the predicate
 * @param {*} predicateArgs  The arguments of the predicate
 * @param {*} result  The result of the prolog call
 */
function callPredicateSingleResult(predicateName,predicateArgs){
     
    //swipl.assert('location(1000,1200)');
    result = swipl.call(predicateName + '(' + predicateArgs + ',R) .');
    console.log(predicateName + '(' + predicateArgs + ',R) .');
    return result.R.tail;
   
}


/**
 * 
 *@param {*} predicateName The name of the predicate
 * @param {*} predicateArgs  The arguments of the predicate
 * @param {*} [result] The array of results found by querying the PL base of knowledge
 */
function callPredicateMultipleResult(predicateName,predicateArgs,[result]){
    var query = swipl.call(predicateName + '(' + predicateArgs.latitude+ ').');
    while (ret = query.next()) {
        result.push(ret);
    }
}






/**
 * Function exports.
 */
module.exports = { 
    callPredicateSingleResult,
    callPredicateMultipleResult,
    assertFact
}