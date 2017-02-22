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

  _.assert( _.strIs( self.prefferedName ) );
  _.assert( _.strIs( self.allowedName ) );

  var result = [];
  var isEmpty;

  var allowedA  = _.arrayUnique( self.target[ self.allowedName ] );
  var prefferedA = _.arrayUnique( self.target[ self.prefferedName ] );

  _.assert( _.arrayIs( prefferedA ) && _.arrayIs( allowedA ) )


  if( self.dependsOf )
  {
    _.assert( _.objectIs( self.dependsOf ) );
    _.assert( _.strIs( self.dependsOf.prefferedName ) && _.strIs( self.dependsOf.allowedName ));

    var allowedB = _.arrayUnique( self.target[ self.dependsOf.allowedName ] );
    var prefferedB= _.arrayUnique( self.target[ self.dependsOf.prefferedName ] );

    _.assert( _.arrayIs( prefferedB ) && _.arrayIs( allowedB ) );

    if( !prefferedB.length || !allowedB.length )
    isEmpty = true;
  }

  if( !isEmpty )
  if( !prefferedA.length || !allowedA.length )
  isEmpty = true;

  if( isEmpty )
  return new wConsequence().give( result );

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

  var prefferedAnyA = _checkForAny( prefferedA );
  var allowedAnyA = _checkForAny( allowedA ) ;

  if( self.dependsOf )
  {
    var prefferedAnyB = _checkForAny( prefferedB );
    var allowedAnyB = _checkForAny( allowedB );
  }

  _.assert( _.routineIs( self.onAttempt ) );

  function _selectFormat( src )
  {
    for( var i = 0; i < src.length; i++ )( function ()
    {
      var format = src[ i ];
      if( allowedA.indexOf( format ) != -1 )
      con.doThen( _.routineSeal( self.target, self.onAttempt, [ format ] ) )
      .doThen( function( err,got )
      {
        if( got )
        result.push( format );

        if( format === src[ src.length - 1 ] )
        return result;
      });
    })();
  }

  //

  function _selectFormatVary( prefferedA, prefferedB )
  {
    for( var i = 0; i < prefferedA.length; i++ )( function ()
    {
      var formatA = prefferedA[ i ];
      if( allowedA.indexOf( formatA ) != -1 )
      for( var j = 0; j < prefferedB.length; j++ )( function ()
      {
        var formatB = prefferedB[ j ];

        if( allowedB.indexOf( formatB ) != -1 )
        con.doThen( _.routineSeal( self.target, self.onAttempt, [ formatA,formatB ] ) )
        .doThen( function( err,got )
        {
          if( got )
          {
            var res = {};
            res[ formatB ] = formatA;
            result.push( res );
          }

          if( i === prefferedA.length - 1 && j === prefferedB.length - 1)
          return result;
        });
      })();
    })();
  }

  if( self.dependsOf )
  {
    _selectFormatVary( prefferedA, prefferedB );

    if( !result.length )
    {
      if( prefferedAnyA && prefferedAnyB )
      _selectFormatVary( allowedA, allowedB );
      else if( prefferedAnyA  )
      _selectFormatVary( allowedA, prefferedB );
      else if( prefferedAnyB )
      _selectFormatVary( prefferedA, allowedB );
    }
  }
  else
  {
    if( prefferedA.length && allowedA.length )
    _selectFormat( prefferedA );

    if( !result.length && prefferedAny )
    _selectFormat( allowedA );
  }

  var allowedAny = allowedAnyA;

  if( self.dependsOf )
  {
    allowedAny = allowedAnyA && allowedAnyB;
  }

  if( !result.length && allowedAny )
  {
    con.doThen( _.routineSeal( self.target, self.onAttempt, [] ) )
    .doThen( function( err,got )
    {
      result = got;
    });
  }

  //

  con.doThen( function()
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
