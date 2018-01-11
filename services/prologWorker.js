var swipl = require('swipl');
var _ = require('underscore');


const rootPredicateName = 'planTravel';


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
function callPredicateSingleResult(baseKnowledge,predicateArgs){
    
    //swipl.initialise();
    //swipl.call('working_directory(_, baseknowledges)');

    //swipl.cleanup();
    swipl.call('consult('+baseKnowledge+')');
    var jsonObject = {};
    var keys = ['Distance','VisitedPharmacies' , 'OrderedWaypoints' , 'NonVisitedPharmacies'];
    console.log(rootPredicateName + '(' + predicateArgs + ',(Visited,Ordered,NonVisited)) .\n\n');
    result = swipl.call(rootPredicateName + '(' + predicateArgs + ',(TotalDistance,Visited,Ordered,NonVisited)) .');
    //var json = JSON.stringify(result.NonVisited);
    //console.log(json);
    var totalDistance = result.TotalDistance;
    console.log(totalDistance);
    var resultVisited = parsePrologOutput(result.Visited,true,"V");
    var resultOrdered  = parsePrologOutput(result.Ordered,true,"O");
    var resultNonVisited = parsePrologOutput(result.NonVisited,true,"NV");
   
    jsonObject[keys[0]] = totalDistance;
    jsonObject[keys[1]] = resultVisited;
    jsonObject[keys[2]] = resultOrdered;
    jsonObject[keys[3]]= resultNonVisited;

    return jsonObject;
   
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
       //Some json inputs can have undefined args, we need to discard these.
       try{
            switch(whatToParse)
            {
                case "V":
                    var obj={
                        name: jsonInput.head.args[0],
                        latitude:jsonInput.head.args[1].args[0],
                        longitude:jsonInput.head.args[1].args[1].args[0],
                        time:jsonInput.head.args[1].args[1].args[1]
                    }
                    output.push(obj);
                    break;
                case "NV":
                    var obj={
                        name: jsonInput.head.args[0],
                        latitude:jsonInput.head.args[1].args[0],
                        longitude:jsonInput.head.args[1].args[1].args[0],
                        time:jsonInput.head.args[1].args[1].args[1]
                    }
                    output.push(obj);
                    break;
                case "O":
                    var obj={
                        
                        
                        latitude:jsonInput.head.args[0],
                        longitude:jsonInput.head.args[1]
                         
                    }
                    output.push(obj);
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