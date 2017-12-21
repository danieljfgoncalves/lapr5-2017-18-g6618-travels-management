var swipl = require('swipl');
var _ = require('underscore');

swipl.initialise();

swipl.call('working_directory(_, baseknowledges)');
swipl.call('consult(planTravel)');


/**
 * Asserts a fact into a prolog knowledge base.
 * @param {*} factName The name of the fact
 * @param {*} factArgs The arguments of the fact
 */
function assertFact(factName,factArgs)
{
    swipl.call('assert(' + factName+').');
  //  console.log('assert(' + factName +').');
    
}


/**
 * Calls a prolog predicate with given args.
 * @param {*} predicateName The name of the predicate
 * @param {*} predicateArgs  The arguments of the predicate
 * @param {*} result  The result of the prolog call
 */
function callPredicateSingleResult(predicateName,predicateArgs){
    console.log(predicateName + '(' + predicateArgs + ',R) .');
    result = swipl.call(predicateName + '(' + predicateArgs + ',R) .');
   
    var resultHead = parsePrologOutput(result.R.head,true);
    parsedResult = resultHead.concat(parsePrologOutput(result.R.tail,false));
    return parsedResult;
   
}

/**
 * Recursive method that parses list of heads and tails returned by prolog query into a flattened js array.
 * @param {*} jsonInput An unflattened json input.
 * @param {*} isHead A 'boolean' variable to parse initial head and tail element separatly.
 */
function parsePrologOutput(jsonInput,isHead)
{
    var output=[];
   if(isHead)
   {
        output.push(jsonInput.head);
   }
   if(!isHead)
   {
    _.each(jsonInput.head,(element,index,list)=>{

            if(_.isNumber(element))
            {
                output.push(element);
            }
            else{
                output.push(element.head);
            }
       
    });
   }
    if(jsonInput.tail != "[]"){

        var localOutput = parsePrologOutput(jsonInput.tail,isHead);
        var  final = output.concat(localOutput);

        return final;
    }
     
    return output;
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