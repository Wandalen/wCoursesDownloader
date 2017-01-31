( function _CoursesDownloader_s_( ) {

'use strict';

// dependencies

if( typeof module !== 'undefined' )
{
}

// constructor

var _ = wTools;
var Parent = wCoursesDownloader;
var Self = function wCoursesDownloaderEdx( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'CoursesDownloaderEdx';

// --
// inter
// --

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
}

//

var loginAct = function ()
{
  var self = this;

  self.config.options.form = self.config.payload;
}

//

var prepareHeadersAct = function()
{
  var self = this;
  var con = new wConsequence();

  function _getCSRF3( cookies )
  {
    var src =  cookies[ 0 ];
    src = src.split( ';' )[ 0 ];
    src = src.split( '=' );

    var token = src.pop();

    self.config.options.headers =
    {
      'Referer' : self.config.loginPageUrl,
      'X-CSRFToken' : token
    }

    con.give();
  }

  return self._request( self.config.loginPageUrl )
  .thenDo( function( err, got )
  {
    if( err )
    throw _.errLog( err );
    return _getCSRF3( got.response.headers[ 'set-cookie' ] );
  });

  return con;
}

//

function getUserCoursesAct()
{
  var self = this;

  throw _.err( 'now implemented edx get courses section!' );

}

// --
// relationships
// --

var Composes =
{
  verbosity : 1,
}

var Aggregates =
{
}

var Associates =
{
  _requestAct : null,
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

  loginAct : loginAct,
  prepareHeadersAct : prepareHeadersAct,
  getUserCoursesAct : getUserCoursesAct,

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


// accessor

_.accessor( Self.prototype,
{
});

// readonly

_.accessorReadOnly( Self.prototype,
{
});

_.CoursesDownloader.register( Self );

})();
