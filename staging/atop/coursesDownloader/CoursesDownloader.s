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

  require( 'wConsequence' )

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

  if( !self.config )
  self.config  = require('./config.js');

  if( !self.userData )
  {
    self.userData = {};
    self.userData.email = 'wcoursera@gmail.com';
    self.userData.password = '17159922';
  }

}

//

var _login = function()
{
  var self = this;
  self.request = self.request.defaults({ jar: true });
  var config = self.config;

  var _getCSRF3 = function( cookies )
  {
    var src =  cookies[ 0 ];
    src = src.split( ';' )[ 0 ];
    src = src.split( '=' );

    var token = src.pop();

    console.log("CSRF3 Token : ", token );

    return token;
  }

  self.request( config.loginPageUrl, function ( err, res, body )
  {
    var cookies = res.headers['set-cookie'];
    var csrf3_token = _getCSRF3( cookies );

    self.request.post
    ({
      url: config.loginApiUrl +'v3Ssr?csrf3-token=' + csrf3_token,
      form:
      {
        email : self.userData.email,
        password : self.userData.password
      }
     },
     function( err, res, body)
     {
       if( !err )
       self._getUserCourses( body )
       .ifNoErrorThen( function ()
       {
         self._getMaterials( self.userData.courses[ 0 ] );
       })
     })
    });
}

//

var _parseCourses = function( src )
{
  var self = this;
  var data = JSON.parse( src );
  self.userData.courses = data.linked['courses.v1'];
  console.log( "Courses list: \n" );
  self.userData.courses .forEach( function( element )
  {
    console.log( 'name: ', element.name, ' class_name : ', element.slug, '\n' );
  });
}

//

var _getUserCourses = function()
{
  var self = this;
  var con = new wConsequence;
  console.log( 'Trying to get courses list.' );
  self.request( self.config.getUserCoursesUrl, function ( err, res, body )
  {
    if( !err )
    {
      self._parseCourses( body );
      con.give();
    }
    else
    con.error( _.err( err ) );
  });

  return con;
}

//

var _getMaterials = function ( course )
{
  _.assert( _.objectIs( course ) );
  var self = this;
  console.log( 'Trying to get matetials for: ', course.name );
  var postUrl = _.strReplaceAll( self.config.courseMaterials,'{class_name}', course.slug );
  self.request( postUrl, function ( err, res, body )
  {
    var data = JSON.parse( body );
    console.log( data.courseMaterial );
  });
}

// --
// relationships
// --

var Composes =
{
  request : null,
  config : null,
}

var Associates =
{
  userData : null,
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

  _parseCourses : _parseCourses,
  _getUserCourses : _getUserCourses,
  _getMaterials : _getMaterials,

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
