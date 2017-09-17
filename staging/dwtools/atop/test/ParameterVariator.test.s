( function _ParameterVariator_test_ss_( ) {

'use strict';

/*

to run this test
from the project directory run

npm install
node ./staging/dwtools/atop/test/ParameterVariator.test.s

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

//

function variatorTest( test )
{
  var variator;
  var downloader = Downloader();

  var variatorOptions =
  {
    allowedName : 'resolutionAllowed',
    prefferedName : 'resolutionPreffered',
    knownName : 'resolutionKnown',
    onAttempt : downloader.onAttempt
  }

  var cases =
  [
    {
      description : 'case1',
      downloader :
      {
        resolutionAvaible : [ 240,360,720 ],
        resolutionAllowed : [ 360,720 ],
        resolutionPreffered : [ 1080 ],
        resolutionKnown : [ 540, 720, 360 ],
      },
      variator : variatorOptions,
      expected : [ 360 ],
      shouldThrowError: false
    },
    {
      description : 'case2',
      downloader :
      {
        resolutionAvaible : [ 240,720],
        resolutionAllowed : [ 360,720 ],
        resolutionPreffered : [ 1080 ],
        resolutionKnown : [ 540, 720, 360 ],
      },
      variator : variatorOptions,
      expected : [ 720 ],
      shouldThrowError: false
    },
    {
      description : 'case3',
      downloader :
      {
        resolutionAvaible : [ 240,720],
        resolutionAllowed : [ 360,720 ],
        resolutionPreffered : [ 540,240 ],
        resolutionKnown : [ 540, 720, 360 ],
      },
      variator : variatorOptions,
      expected : [ 720 ],
      shouldThrowError: false
    },
    {
      description : 'case4',
      downloader :
      {
        resolutionAvaible : [ 240,360,720 ],
        resolutionAllowed : [ 240,360,720,1080 ],
        resolutionPreffered : [ 240,360 ],
        resolutionKnown : [ 540, 720, 360 ],
      },
      variator : variatorOptions,
      expected : [ 240,360 ],
      shouldThrowError: false
    },
    {
      description : 'case5',
      downloader :
      {
        resolutionAvaible : [ 240 ],
        resolutionAllowed : [ 360,720 ],
        resolutionPreffered : [ 1080 ],
        resolutionKnown : [ 540, 720, 360 ],
      },
      variator : variatorOptions,
      shouldThrowError: true
    },
    {
      description : 'case6',
      downloader :
      {
        resolutionAvaible : [ 240,720 ],
        resolutionAllowed : [ 240,360,720,1080 ],
        resolutionPreffered : [ 240,360 ],
        resolutionKnown : [ 540, 720, 360 ],
      },
      variator : variatorOptions,
      expected : [ 240,720 ],
      shouldThrowError: false
    },
    {
      description : 'case7',
      downloader :
      {
        resolutionAvaible : [ 240,720 ],
        resolutionAllowed : [ 240,360,1080 ],
        resolutionPreffered : [ 240,360 ],
        resolutionKnown : [ 540, 720, 360 ],
      },
      variator : variatorOptions,
      expected : [ 240 ],
      shouldThrowError: false
    },
    {
      description : 'case8',
      downloader :
      {
        resolutionAvaible : [ 720 ],
        resolutionAllowed : [ 240,360,1080 ],
        resolutionPreffered : [ 240,360 ],
        resolutionKnown : [ 540, 720, 360 ],
      },
      variator : variatorOptions,
      expected : null,
      shouldThrowError: true
    },
    {
      description : 'case9',
      downloader :
      {
        resolutionAvaible : [ '540p' ],
        resolutionAllowed : [ '720p', '360p', '540p' ],
        resolutionPreffered : [ '300p', Symbol.for( 'any' ) ],
        resolutionKnown : [ '540p','720p','360p' ],
      },
      variator : variatorOptions,
      expected : [ '540p' ],
      shouldThrowError: false
    },
    {
      description : 'case10',
      downloader :
      {
        resolutionAvaible : [ '540p' ],
        resolutionAllowed : [ Symbol.for( 'any' ) ],
        resolutionPreffered : [ Symbol.for( 'any' ) ],
        resolutionKnown : [ '540p','720p','360p' ],
      },
      variator : variatorOptions,
      expected : [ '540p' ],
      shouldThrowError: false
    },
    {
      description : 'case11',
      downloader :
      {
        resolutionAvaible : [ '540p' ],
        resolutionAllowed : [ '720p', '360p', '540p' ],
        resolutionPreffered : [ '720p', Symbol.for( 'any' ),'540p' ],
        resolutionKnown : [ '540p','720p','360p' ],
      },
      variator : variatorOptions,
      expected : [ '540p' ],
      shouldThrowError: false
    },
    {
      description : 'case12',
      downloader :
      {
        resolutionAvaible : [ '540p','360p' ],
        resolutionAllowed : [ '540p','360p' ],
        resolutionPreffered : [ Symbol.for( 'any' ),Symbol.for( 'any' ) ],
        resolutionKnown : [ '540p','720p','360p' ],
      },
      variator : variatorOptions,
      expected : [ '540p','360p' ],
      shouldThrowError: false
    },
    {
      description : 'case13',
      downloader :
      {
        resolutionAvaible : [ '540p','360p' ],
        resolutionAllowed : [ Symbol.for( 'any' ) ],
        resolutionPreffered : [ Symbol.for( 'any' ),Symbol.for( 'any' ) ],
        resolutionKnown : [ '540p','720p','360p' ],
      },
      variator : variatorOptions,
      expected : [ '540p','360p' ],
      shouldThrowError: false
    },
    {
      description : 'case14',
      downloader :
      {
        resolutionAvaible : [ '540p','360p' ],
        resolutionAllowed : [ '540p' ],
        resolutionPreffered : [ Symbol.for( 'any' ),Symbol.for( 'any' ) ],
        resolutionKnown : [ '540p','720p','360p' ],
      },
      variator : variatorOptions,
      expected : [ '540p' ],
      shouldThrowError: false
    },
    {
      description : 'case15',
      downloader :
      {
        resolutionAvaible : [ '540p','360p' ],
        resolutionAllowed : [  ],
        resolutionPreffered : [ Symbol.for( 'any' ) ],
        resolutionKnown : [ '540p','720p','360p' ],
      },
      variator : variatorOptions,
      shouldThrowError: true
    },
    {
      description : 'case16',
      downloader :
      {
        resolutionPreffered : [ ]
      },
      variator : variatorOptions,
      shouldThrowError: true
    },
    // {
    //   description : 'case17',
    //   downloader :
    //   {
    //     resolutionAvaible : [  ],
    //     resolutionAllowed : [ Symbol.for( 'any' ) ],
    //     resolutionPreffered : [ Symbol.for( 'any' ) ],
    //     resolutionKnown : [ '540p','720p','360p' ],
    //   },
    //   variator : variatorOptions,
    //   shouldThrowError: true
    // },

  ];

  var consequence = new wConsequence().give();
  for( var i = 0; i < cases.length; i++ )(function ()
  {
    var _case = cases[ i ];
    consequence.ifNoErrorThen( function()
    {
      test.description = _case.description;
      downloader = Downloader( _case.downloader );
      _case.variator.target = downloader;
      variator = _.ParameterVariator( _case.variator );
      var con = test.shouldMessageOnlyOnce( variator.make() );
      if( _case.shouldThrowError )
      con = test.shouldThrowError( con );
      else
      con.ifNoErrorThen( function ()
      {
        test.identical( variator.target.selectedVariants, _case.expected );
      });

      return con;
    })

  })()

  return consequence;
}


var Proto =
{

  name : 'ParameterVariator',

  tests :
  {
    variatorTest : variatorTest,
  },

  verbosity : 1,

}

_.mapExtend( Self,Proto );
Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );
} )( );
