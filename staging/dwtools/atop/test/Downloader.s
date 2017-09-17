( function _Downloader_s_( ) {

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
}

// constructor

var _ = wTools;
var Parent = null;
var Self = function Downloader( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'Downloader';

// --
// inter
// --

function init( o )
{
  var self = this;

  _.instanceInit( self );

  // if( self.Self === Self )
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

}

//

function onAttemptFormat( variant )
{
  var self = this;

  var self = this;
  if( self.formatAvaible.indexOf( variant ) != -1 )
  {
    return true;
  }

  return false;

}

//

function onAttemptResolution( variant )
{
  var self = this;
  var i = self.resolutionAvaible.indexOf( variant );
  if( i != -1 )
  {
    self.resolutionAvaible.splice( i, 1 );
    return true;
  }

  return false;
}

//

function onAttempt( a, b )
{
  var self = this;
  // console.log(arguments);

  if( arguments.length === 1 )
  {
    if( a === Symbol.for( 'any' ) )
    {
      if( self.resolutionAvaible.length )
      {
        self.selectedVariants.push( self.resolutionAvaible.shift() );
        return true;
      }
      return false;
    }
    if( self.onAttemptResolution( a ) )
    {
      self.selectedVariants.push( a );
      return true;
    }
    if( self.onAttemptFormat( a ) )
    {
      self.selectedVariants.push( a );
      return true;
    }

  }

  if( arguments.length === 2 )
  {
    if( self.videoVaryFirst === 'resolution' )
    {
      var t = a;
      a = b;
      b = t;
    }

    if( self.resolutionAvaible.indexOf( a ) != -1 )
    {
      if( self.formatAvaible.indexOf( b ) != -1 )
      {
        self.selectedVariants.push( a + ',' + b );
        return true;
      }
    }
  }

  return false;
}


// --
// relationships
// --

var Composes =
{
  formatAvaible : [ 'mp4' ] ,
  formatAllowed : [ 'mp4', 'webm' ],
  formatPreffered :[ 'mp4','webm' ],

  resolutionAvaible : [ '720p','540p' ],
  resolutionAllowed : [ '720p', '360p', '540p' ],
  resolutionPreffered : [ '720p','360p' ],
  resolutionKnown : [ '540p','720p','360p' ],

  videoVaryFirst : 'format',
  selectedVariants : [],
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

  onAttemptFormat : onAttemptFormat,
  onAttemptResolution : onAttemptResolution,
  onAttempt : onAttempt,

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

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

return Self;

})();
