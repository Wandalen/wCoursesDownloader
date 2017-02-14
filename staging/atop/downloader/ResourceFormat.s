( function _ResourceFormat_s_( ) {

'use strict';

// dependencies

if( typeof module !== 'undefined' )
{

  if( typeof wBase === 'undefined' )
  try
  {
    require( '../wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  var _ = wTools;

  _.include( 'wCopyable' );
  _.include( 'wConsequence' );
  _.include( 'wLogger' );


}

var symbolForAny = Symbol.for( 'any' );

// constructor

var _ = wTools;
var Parent = null;
var Self = function wResourceFormat( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'ResourceFormat';

// --
// inter
// --

function init( o )
{
  var self = this;

  _.instanceInit( self );

  Object.preventExtensions( self );

  if( o )
  self.copy( o );

  if( !self.onAttempt )
  if( _.routineIs( self.target.onAttempt ) )
  self.onAttempt = self.target.onAttempt;

}

// --
//
// --

function make()
{
  var self = this;
  return self._attempt();
}

//

function _attempt()
{
  var self = this;
  var con = new wConsequence().give();

  _.assert( _.strIs( self.prefferedName ) );
  _.assert( _.strIs( self.allowedName ) );

  var result = [];

  var prefferedFormats = self.target[ self.prefferedName ];
  var allowedFormats = self.target[ self.allowedName ];

  _.assert( _.arrayIs( prefferedFormats ) && _.arrayIs( allowedFormats ) )

  if( !prefferedFormats.length || !allowedFormats.length )
  return con.thenDo( function()
  {
    return result;
  })

  var preffered = _.arrayUnique( prefferedFormats );
  var allowed = _.arrayUnique( allowedFormats );

  function _checkForAny( src )
  {
    var res = false;
    var i = src.indexOf( null );
    if( i != -1 )
    {
      src.splice( i, 1 );
      res = true;
    }

    i = src.indexOf( symbolForAny );
    if( i != -1 )
    {
      src.splice( i, 1 );
      res = true;
    }

    return res;
  }

  var prefferedAny = _checkForAny( preffered );
  var allowedAny = _checkForAny( allowed );

  _.assert( _.routineIs( self.onAttempt ) );

  function _selectFormat( src )
  {
    for( var i = 0; i < src.length; i++ )( function ()
    {
      var format = src[ i ];
      if( allowed.indexOf( format ) != -1 )
      con.thenDo( _.routineSeal( self.target, self.onAttempt, [ format ] ) )
      .thenDo( function( err,got )
      {
        if( got )
        result.push( format );

        if( format === src[ src.length - 1 ] )
        return result;
      });
    })();
  }

  if( preffered.length && allowed.length )
  _selectFormat( preffered );

  if( !result.length && prefferedAny )
  _selectFormat( allowed );

  if( !result.length && allowedAny && prefferedAny )
  {
    con.thenDo( _.routineSeal( self.target, self.onAttempt ) )
    .thenDo( function( err,got )
    {
      result = got;
    });
  }

  //

  con.thenDo( function()
  {
    if( !result.length )
    con.error( _.err( "Any of preffered or allowed formats is not available!" ) )
    else
    return result;
  })


  return con;
}

//


// --
// relationships
// --

var Composes =
{
  verbosity : 1,

  target : null,
  allowedName : null,
  prefferedName : null,

  onAttempt : null,
}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
}

var Statics =
{
}

// --
// proto
// --

var Proto =
{
  init : init,

  make : make,

  _attempt : _attempt,


  // relationships

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
};

// define

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

wCopyable.mixin( Self );

// accessor

_.accessor( Self.prototype,
{
});

// readonly

_.accessorReadOnly( Self.prototype,
{
});

wTools[ Self.nameShort ] = _global_[ Self.name ] = Self;

})();
