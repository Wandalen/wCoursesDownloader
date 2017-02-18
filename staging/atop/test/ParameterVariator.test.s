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
  var variator = _.ParameterVariator( o );
  var consequence = new wConsequence().give();

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'case1';
    var con =  variator.make();
    con = test.shouldMessageOnlyOnce( con );
    return con;
  })
  .ifNoErrorThen( function()
  {
    test.identical( variator.target.selectedVariants, [ '720p' ] );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'case2';
    downloader = Downloader
    ({
      resolutionAvaible : [ '540p' ],
      resolutionAllowed : [ '720p', '360p', '540p' ],
      resolutionPreffered : [ '300p', Symbol.for( 'any' ) ]
    });
    var o =
    {
      allowedName : 'resolutionAllowed',
      prefferedName : 'resolutionPreffered',
      target : downloader,
      onAttempt : downloader.onAttempt
    }
    variator = _.ParameterVariator( o );
    var con =  variator.make();
    con = test.shouldMessageOnlyOnce( con );
    return con;
  })
  .ifNoErrorThen( function()
  {
    test.identical( variator.target.selectedVariants, [ '540p' ] );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'case3';
    downloader = Downloader
    ({
      resolutionAvaible : [ '540p' ],
      resolutionAllowed : [ Symbol.for( 'any' ) ],
      resolutionPreffered : [ Symbol.for( 'any' ) ]
    });
    var o =
    {
      allowedName : 'resolutionAllowed',
      prefferedName : 'resolutionPreffered',
      target : downloader,
      onAttempt : downloader.onAttempt
    }
    variator = _.ParameterVariator( o );
    var con =  variator.make();
    con = test.shouldMessageOnlyOnce( con );
    return con;
  })
  .ifNoErrorThen( function()
  {
    test.identical( variator.target.selectedVariants, [ '540p' ] );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'case4';
    downloader = Downloader
    ({
      resolutionAvaible : [ '540p' ],
      resolutionAllowed : [ '720p', '360p', '540p' ],
      resolutionPreffered : [ '720p', Symbol.for( 'any' ),'540p' ]
    });
    var o =
    {
      allowedName : 'resolutionAllowed',
      prefferedName : 'resolutionPreffered',
      target : downloader,
      onAttempt : downloader.onAttempt
    }
    variator = _.ParameterVariator( o );
    var con =  variator.make();
    con = test.shouldMessageOnlyOnce( con );
    return con;
  })
  .ifNoErrorThen( function()
  {
    test.identical( variator.target.selectedVariants, [ '540p' ] );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'case5';
    downloader = Downloader
    ({
      resolutionAvaible : [ '540p','360p' ],
      resolutionAllowed : [ '540p','360p' ],
      resolutionPreffered : [ Symbol.for( 'any' ),Symbol.for( 'any' ) ]
    });
    var o =
    {
      allowedName : 'resolutionAllowed',
      prefferedName : 'resolutionPreffered',
      target : downloader,
      onAttempt : downloader.onAttempt
    }
    variator = _.ParameterVariator( o );
    var con =  variator.make();
    con = test.shouldMessageOnlyOnce( con );
    return con;
  })
  .ifNoErrorThen( function()
  {
    test.identical( variator.target.selectedVariants, [ '540p','360p' ] );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'case6';
    downloader = Downloader
    ({
      resolutionAvaible : [ '540p','360p' ],
      resolutionAllowed : [ Symbol.for( 'any' ) ],
      resolutionPreffered : [ Symbol.for( 'any' ),Symbol.for( 'any' ) ]
    });
    var o =
    {
      allowedName : 'resolutionAllowed',
      prefferedName : 'resolutionPreffered',
      target : downloader,
      onAttempt : downloader.onAttempt
    }
    variator = _.ParameterVariator( o );
    var con =  variator.make();
    con = test.shouldMessageOnlyOnce( con );
    return con;
  })
  .ifNoErrorThen( function()
  {
    test.identical( variator.target.selectedVariants, [ '540p','360p' ] );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'case7';
    downloader = Downloader
    ({
      resolutionAvaible : [ '540p','360p' ],
      resolutionAllowed : [ '540p' ],
      resolutionPreffered : [ Symbol.for( 'any' ),Symbol.for( 'any' ) ]
    });
    var o =
    {
      allowedName : 'resolutionAllowed',
      prefferedName : 'resolutionPreffered',
      target : downloader,
      onAttempt : downloader.onAttempt
    }
    variator = _.ParameterVariator( o );
    var con =  variator.make();
    con =  test.shouldMessageOnlyOnce( con );
    return con;
  })
  .ifNoErrorThen( function()
  {
    test.identical( variator.target.selectedVariants, [ '540p'] );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'case8';
    downloader = Downloader
    ({
      resolutionAvaible : [ '540p','360p' ],
      resolutionAllowed : [  ],
      resolutionPreffered : [ Symbol.for( 'any' ) ]
    });
    var o =
    {
      allowedName : 'resolutionAllowed',
      prefferedName : 'resolutionPreffered',
      target : downloader,
      onAttempt : downloader.onAttempt
    }
    variator = _.ParameterVariator( o );
    var con =  variator.make();
    con =  test.shouldMessageOnlyOnce( con );
    con =  test.shouldThrowError( con );
    return con;
  })
  .ifNoErrorThen( function()
  {
    test.description = 'case9';
    downloader = Downloader
    ({
      resolutionPreffered : [ ]
    });
    var o =
    {
      allowedName : 'resolutionAllowed',
      prefferedName : 'resolutionPreffered',
      target : downloader,
      onAttempt : downloader.onAttempt
    }
    variator = _.ParameterVariator( o );
    var con =  variator.make();
    con =  test.shouldMessageOnlyOnce( con );
    return con;
  })
  .ifNoErrorThen( function( got )
  {
    test.identical( got, false );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'case10';
    downloader = Downloader
    ({
      resolutionAvaible : [  ],
      resolutionAllowed : [ Symbol.for( 'any' ) ],
      resolutionPreffered : [ Symbol.for( 'any' ) ]
    });
    var o =
    {
      allowedName : 'resolutionAllowed',
      prefferedName : 'resolutionPreffered',
      target : downloader,
      onAttempt : downloader.onAttempt
    }
    variator = _.ParameterVariator( o );
    var con =  variator.make();
    con =  test.shouldMessageOnlyOnce( con );
    con =  test.shouldThrowError( con );
    return con;
  })

  return consequence;
}


var Proto =
{

  name : 'ParameterVariator test',

  tests :
  {
    simpleTest : simpleTest,
  },

  verbosity : 1,

}

_.mapExtend( Self,Proto );
Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );
} )( );
