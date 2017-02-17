( function _ParameterVariator_test_ss_( ) {

'use strict';

/*

to run this test
from the project directory run

npm install
node ./staging/atop/test/ParameterVariator.test.s

*/

if( typeof module !== 'undefined' )
{

  require( 'wLogger' );

  var _ = wTools;

  _.include( 'wTesting' );

  require( '../variator/ParameterVariator.s' );

}

var _ = wTools;
var Self = {};
var Downloader = require( './Downloader.s' );


function simpleTest( test )
{
  // defaults
  // formatAvaible : [ 'mp4' ] ,
  // formatAllowed : [ 'mp4', 'webm' ],
  // formatPreffered :[ 'webm' ],
  //
  // resolutionAvaible : [ '720p','540p' ],
  // resolutionAllowed : [ '720p', '360p', '540p' ],
  // resolutionPreffered : [ '720p','360p' ],
  // videoVaryFirst : 'format',

  var downloader = Downloader();

  var o =
  {
    allowedName : 'resolutionAllowed',
    prefferedName : 'resolutionPreffered',
    target : downloader,
    onAttempt : downloader.onAttempt
  }

  var rf = _.ParameterVariator( o );
  rf.make()
  .thenDo( function( err, got )
  {
    if( err )
    throw _.err( err );
    console.log( got );

    test.description = "test1";
    test.identical( rf.target.selectedVariants, [ '720p' ] );
  })


}


var Proto =
{

  name : 'ParameterVariator test',

  tests :
  {
    simpleTest : simpleTest,
  },

  /* verbosity : 1, */

}

Object.setPrototypeOf( Self, Proto );
Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );
} )( );
