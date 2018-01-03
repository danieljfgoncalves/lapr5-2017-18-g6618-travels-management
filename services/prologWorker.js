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
 */
function callPredicateSingleResult(predicateName,predicateArgs){
    console.log(predicateName + '(' + predicateArgs + ',(Visited,Ordered,NonVisited)) .\n\n');
    result = swipl.call(predicateName + '(' + predicateArgs + ',(Visited,Ordered,NonVisited)) .');
    //var json = JSON.stringify(result.NonVisited);
    //console.log(json);
    var resultVisited = parsePrologOutput(result.Visited,true,"V");
    var resultOrdered  = parsePrologOutput(result.Ordered,true,"O");
    var resultNonVisited = parsePrologOutput(result.NonVisited,true,"NV");
    parsedResult = resultVisited.concat(resultOrdered.concat(resultNonVisited));
    //TODO: Transform parsed result in wanted json, for now its only a straight array.
    return parsedResult;
   
}

/**
 * Recursive method that parses list of heads and tails returned by prolog query into a flattened js array.
 * @param {*} jsonInput An unflattened json input.
 * @param {*} isHead A 'boolean' variable to parse initial head and tail element separatly.
 * @param {*} whatToParse A aux variable to help determine what we list is being parsed, since they take different means of parsing.
 */
function parsePrologOutput(jsonInput,isHead,whatToParse)
{
    var output=[];
   if(isHead)
   {
       try{
            switch(whatToParse)
            {
                case "V":
                    output.push(jsonInput.head.args[0]);
                    output.push(jsonInput.head.args[1].args[0]);
                    output.push(jsonInput.head.args[1].args[1].args[0]);
                    break;
                case "NV":
                    output.push(jsonInput.head.args[0]);
                    output.push(jsonInput.head.args[1].args[0]);
                    output.push(jsonInput.head.args[1].args[1].args[0]);
                    break;
                case "O":
                    output.push(jsonInput.head.args[0]);
                    output.push(jsonInput.head.args[1]);
                    break;
            }
        }
        catch(e)
        {
            return output;
        }
       
   }
    if(jsonInput.tail != "[]"){

        var localOutput = parsePrologOutput(jsonInput.tail,isHead,whatToParse);
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