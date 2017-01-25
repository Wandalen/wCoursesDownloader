( function _CoursesDownloader_s_( ) {

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

  if( typeof wCopyable === 'undefined' )
  try
  {
    require( '../../mixin/Copyable.s' );
  }
  catch( err )
  {
    require( 'wCopyable' );
  }

}

// constructor

var _ = wTools;
var Parent = null;
var Self = function wCoursesDownloader( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'CoursesDownloader';

// --
// inter
// --

var init = function( o )
{
  var self = this;

  _.instanceInit( self );

  if( self.Self === Self )
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

  if( !self.request )
  self.request = require('request');

}

//

var _login = function()
{
  var self = this;
  var request = self.request.defaults({ jar: true });

  var _getCSRF3 = function( cookies )
  {
    var src =  cookies[ 0 ];
    src = src.split( ';' )[ 0 ];
    src = src.split( '=' );

    var token = src.pop();

    console.log("CSRF3 Token : ", token );

    return token;
  }

  request('https://www.coursera.org/?authMode=login', function ( err, res, body )
  {
  var cookies = res.headers['set-cookie'];
  var csrf3_token = _getCSRF3( cookies );
  request.post
  ({
    url:'https://www.coursera.org/api/login/v3Ssr?csrf3-token=' + csrf3_token,
    form:
    {
      email : self.email,
      password : self.password
    }
   },
   function( err, res, body)
   {
     if( !err )
     request( 'https://www.coursera.org/account/profile', function ( err, res, body )
     {
       console.log( body );
     });
   })
  });


}

// --
// relationships
// --

var Composes =
{
  request : null
}

var Associates =
{
  email : 'wcoursera@gmail.com',
  password : '17159922',
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

  _login : _login,

  // relationships

  constructor : Self,
  Composes : Composes,
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
