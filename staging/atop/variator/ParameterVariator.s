( function _ParameterVariator_s_( ) {

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
var symbolForSkip = Symbol.for( 'skip' );

// constructor

var _ = wTools;
var Parent = null;
var Self = function wParameterVariator( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'ParameterVariator';

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

  var allowed = self.target[ self.allowedName ];
  var preffered = self.target[ self.prefferedName ];

  var prefferedAny =  self._checkForAny( preffered );
  var allowedAny =  self._checkForAny( allowed );

  var allowedSkip = self._checkForSkip( allowed );

  var i = 0;
  var selected = 0;

  if( !preffered.length && !prefferedAny)
  return con.thenDo( function()
  {
    logger.error( "Warning! Preffered is empty" );
    return false;
  });

  function varyPreffered( preffered, allowed )
  {
    var variant = preffered.shift();

    if( allowed.indexOf( variant ) != -1 )
    con.thenDo( _.routineSeal( self.target, self.onAttempt,[ variant ] ) );

    con.thenDo( function ( err, got )
    {
      if( got )
      return true;
      else if( preffered.length )
      {
        varyPreffered( preffered,allowed );
      }
      else if( prefferedAny )
      {
        return varyPrefferedAny( allowed );
      }

      return false;
    });
  }

  function varyPrefferedAny( allowed )
  {
    if( allowed.length )
    {
      var variant = allowed.shift();
      con.thenDo( _.routineSeal( self.target, self.onAttempt,[ variant ] ) );
    }
    else if( allowedAny )
    {
      con.thenDo( _.routineSeal( self.target, self.onAttempt, [] ) );
    }

    con.thenDo( function ( err, got )
    {
      if( got )
      {
        --prefferedAny;
        selected++;
      }
      else
      {
        if( !allowed.length )
        allowedAny = 0;
      }

      if( allowed.length ||  allowedAny )
      return varyPrefferedAny( allowed);

      if( prefferedAny )
      {
        return false;
      }

      return true;
    });
  }

  varyPreffered( preffered, allowed );

  con.thenDo( function (err, got )
  {
    if( !got )
    {
      if( selected > 0 )
      {
        logger.error( "Warning! Selected ", selected, "parameters, expected", prefferedAny )
      }
      else if( allowedSkip )
      {
        logger.error( "Warning! Nothing selected, error skipped" );
      }
      else
      {
        throw _.err( 'Nothing avaible' );
      }
    }

    return got;
  });

  return con;
}

//

function _checkForAny( src )
{
  var result = 0;

  while( 1 )
  {
    var i = src.indexOf( symbolForAny );
    if( i >= 0 )
    {
      src.splice( i, 1 );
      result++;
    }
    else
    break;
  }

  return result;
}

function _checkForSkip( src )
{
  var result = 0;

  var i = src.indexOf( symbolForSkip );
  if( i >= 0 )
  {
    src.splice( i, 1 );
    result = true;
  }

  return result;
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

  dependsOf : null,

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

  _checkForAny : _checkForAny,
  _checkForSkip : _checkForSkip,

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
