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

  var con = new wConsequence();

  var allowed = self.target[ self.allowedName ];
  var preffered = self.target[ self.prefferedName ];
  var known = self.target[ self.knownName ];

  var count = 0;

  function _isTried()
  {
    if( self.current != symbolForAny )
    {
      if( self.triedArray.indexOf( self.current ) != -1 )
      return true;

      self.triedArray.push( self.current );
    }

    return false;
  }

  function _select( src,current )
  {
    if( !src.length )
    return con.error( _.err( current,' is empty!' ) );

    for( var i = 0, l = src.length; i < l; ++i )
    {
      self.current = src[ i ];

      if( _isTried() )
      continue;

      if( self.current === symbolForAny )
      {
        if( current === 'preffered' )
        return _select( allowed, 'allowed' );
        if( current === 'allowed' )
        return _select( known, 'known' );
      }
      else
      {
        if( current === 'preffered' )
        if( allowed.indexOf( self.current ) === -1  )
        continue;

        if( self.onAttempt.call( self.target, self.current ) )
        {
          count++;
          if( count == preffered.length )
          break;
        }
      }
    }

    if( current === 'preffered' )
    if( count != preffered.length )
    return _select( allowed, 'allowed' );

    if( !count )
    if( current != 'known' )
    return con.error( "Nothing available" );
  }

  _select( preffered,'preffered' );

  if( count )
  con.give( true );

  return con;
}

// function _attempt()
// {
//   var self = this;
//
//   var con = new wConsequence();
//
//   var allowed = self.target[ self.allowedName ];
//   var preffered = self.target[ self.prefferedName ];
//   var known = self.target[ self.knownName ];
//
//   var count = 0;
//   var allowedAnyUsed = false;
//
//   function _isTried( src, i )
//   {
//     self.current = src[ i ];
//
//     if( self.current != symbolForAny )
//     {
//       if( self.triedArray.indexOf( self.current ) != -1 )
//       return true;
//
//       self.triedArray.push( self.current );
//     }
//
//     return false;
//   }
//
//   function _isAvaible()
//   {
//     return  self.onAttempt.call( self.target, self.current );
//   }
//
//   function _tryAllowed()
//   {
//     for( var j = 0, k = allowed.length; j < k; ++j )
//     {
//       if( _isTried( allowed, j ) )
//       continue;
//
//       if( self.current === symbolForAny )
//       {
//         if( allowedAnyUsed )
//         continue;
//
//         allowedAnyUsed = true;
//         if( _tryKnown() )
//         {
//           count++;
//           break;
//         }
//       }
//       else
//       {
//         if( _isAvaible() )
//         {
//           count++;
//           break;
//         }
//       }
//
//
//       if( j === k - 1 && !count )
//       con.error( "Nothing available" );
//     }
//   }
//
//   function _tryKnown()
//   {
//     for( var j = 0, k = known.length; j < k; ++j )
//     {
//       if( _isTried( known, j ) )
//       continue;
//
//       if( _isAvaible() )
//       {
//         count++;
//         return true;
//       }
//
//       if( j === k - 1 && !count )
//       con.error( "Nothing available" );
//     }
//   }
//
//   for( var i = 0, l = preffered.length; i < l; ++i )
//   {
//     if( _isTried( preffered, i ) )
//     continue;
//
//     if( self.current === symbolForAny )
//     _tryAllowed();
//     else
//     {
//       if( allowed.indexOf( self.current ) != -1 )
//       if( _isAvaible() )
//       {
//         count++;
//         break;
//       }
//
//       if( i === l - 1 && !count )
//       _tryAllowed();
//     }
//   }
//
//   if( count )
//   con.give( true );
//
//   return con;
// }

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
  knownName : null,

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
  current : null,
  triedArray : [],
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

_.classMake
({
  cls : Self,
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
