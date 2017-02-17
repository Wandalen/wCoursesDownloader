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
  if( self.resolutionAvaible.indexOf( variant ) != -1 )
  {
    return true;
  }

  return false;
}

//

function onAttempt( a, b )
{
  var self = this;

  return _.timeOut( 100 )
  .thenDo( function()
  {

    if( arguments.length === 1 )
    if( self.onAttemptResolution( a ) || onAttemptFormat( a ) )
    {
      self.selectedVariants.push( a );
      return true;
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
  });
}



// --
// relationships
// --

var Composes =
{
  formatAvaible : [ 'mp4' ] ,
  formatAllowed : [ 'mp4', 'webm' ],
  formatPreffered :[ 'webm' ],

  resolutionAvaible : [ '720p','540p' ],
  resolutionAllowed : [ '720p', '360p', '540p' ],
  resolutionPreffered : [ '720p','360p' ],

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

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

return Self;

})();
