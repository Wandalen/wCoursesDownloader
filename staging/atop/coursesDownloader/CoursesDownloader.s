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
  {
    var config = require('./config.js');

    if( self.siteName  )
    self.config = config[ self.siteName ];
    else
    self.config = config[ config.default ];
  }

  if( !self.userData )
  {
    self.userData = {};
    self.userData.email = 'wcoursera@gmail.com';
    self.userData.password = '17159922';
  }

}

//

var download = function()
{
  var self = this;

  self._login()
  .ifNoErrorThen( function()
  {
    return self._getUserCourses();
  })
  .ifNoErrorThen( function ()
  {
    self._getMaterials( self.userData.courses[ 0 ] );
  });

  //need implement methods:
  //getResourseLinkById, addResourcesToDownloadList, list can be: course name->chapters->resources with links,saveLinkToHardDrive
}

var _login = function()
{
  var self = this;
  var con = new wConsequence;

  self.request = self.request.defaults({ jar: true });

  var payload = { "email": self.userData.email, "password": self.userData.password };

  if( self.config.name === 'coursera' )
  {
    payload[ "webrequest" ] = true;
  }

  self._prepareHeaders();

  self.request
  ({
      url: self.config.loginApiUrl,
      method: "POST",
      json: true,
      headers: self.config.headers,
      body: payload
  },
  function (err, res,body)
  {
    if( err )
    return con.error( _.err( err ) );

    var cookie = res.headers[ 'set-cookie' ].join( ';' );
    self._prepareHeaders( 'Cookie', cookie );
    self.userData.auth = 1;
    con.give();
  });

  return con;
}

//

var _prepareHeaders = function( name, value )
{
  var self = this;

  // if( !self.config.headers )
  // self.config.headers = src;

  // var csrftoken = _getCSRF3( src );

  if( arguments.length === 2 )
  {
    _.assert( _.strIs( name ) );
    _.assert( _.strIs( value ) );

    self.config.headers[ name ] = value;
    return;
  }

  if( self.config.name === 'edx' )
  {
    self.config.headers[ 'Referer' ] = self.config.loginPageUrl;
    self.config.headers['X-CSRFToken'] = csrftoken;
  }

  if( self.config.name === 'coursera' )
  {
    var randomstring = require("randomstring");
    var csrftoken = randomstring.generate( 20 );
    var csrf2cookie = 'csrf2_token_' + randomstring.generate( 8 );
    var csrf2token = randomstring.generate(24)
    var cookies = `csrftoken=${csrftoken}; csrf2cookie=${csrf2cookie}; csrf2token=${csrf2token};`
    self.config.headers =
    {
      'Cookie': cookies,
      'X-CSRFToken': csrftoken,
      'X-CSRF2-Cookie': csrf2cookie,
      'X-CSRF2-Token': csrf2token,
      'Connection': 'keep-alive'
    }
  }
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

  if( !self.userData.auth )
  return;

  if( self.config.name === 'edx' )
  throw _.err( "now implemented edx get courses section!" );

  var con = new wConsequence;
  console.log( 'Trying to get courses list.' );
  self.request
  ({
    url : self.config.getUserCoursesUrl,
    headers : self.config.headers
  },
  function ( err, res, body )
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
}

var Associates =
{
  config : null,
  userData : null,
  siteName : null,
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

  download : download,

  _login : _login,

  _parseCourses : _parseCourses,
  _getUserCourses : _getUserCourses,
  _getMaterials : _getMaterials,
  _prepareHeaders : _prepareHeaders,

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
