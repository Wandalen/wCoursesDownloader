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

  if( typeof wLogger === 'undefined' )
  try
  {
    require( '../include/abase/object/printer/printer/Logger.s' );
  }
  catch( err )
  {
    require( 'wLogger' );
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

function init( o )
{
  var self = this;

  _.instanceInit( self );

  if( self.Self === Self )
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

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
  }

  if( !self._requestAct )
  self._requestAct = self.Request.defaults({ jar : true });

}

var init_static = function()
{
  var self = this;

  // self.Childs.CoursesDownloaderCoursera();
}

var register = function( )
{
  _.assert( arguments.length > 0 );

  for( var a = 0 ; a < arguments.length ; a++ )
  {
    var child = arguments[ a ];
    this.Childs[ child.nameShort ] = child;
  }

  return this;
}

//

function login()
{
  var self = this;

  if( self.verbosity )
  logger.topicUp( 'Login ..' );

  var payload = { 'email' : self.config.email, 'password' : self.config.password };

  self.config.options =
  {
    url : self.config.loginApiUrl,
    method : 'POST',
    headers : null
  };

  if( self.config.name === 'coursera' )
  {
    payload[ 'webrequest' ] = true;
    self.config.options.json = true;
    self.config.options.body = payload;
  }

  if( self.config.name === 'edx' )
  {
    self.config.options.form = payload;
  }

  return self._prepareHeaders()
  .ifNoErrorThen( _.routineSeal( self,self._request,[ self.config.options ] ) )
  .thenDo( function( err,got )
  {

    if( self.verbosity )
    logger.topicDown( 'Login ' + ( err ? 'error' : 'done' ) + '.' );

    if( err )
    throw _.errLogOnce( err );

    var cookie = got.response.headers[ 'set-cookie' ].join( ';' );
    self._prepareHeaders( 'Cookie', cookie );
    self.userData.auth = 1;

    return got;
  })
}

//

function download()
{
  var self = this;

  self.login()
  .ifNoErrorThen( function()
  {
    return self._getUserCourses();
  })
  .ifNoErrorThen( function()
  {
    self._getMaterials( self.userData.courses[ 0 ] );
  })
  .thenDo( function( err,got )
  {

    if( err )
    throw _.errLogOnce( err );

  });

  //need implement methods :
  //getResourseLinkById, addResourcesToDownloadList, list can be : course name->chapters->resources with links,saveLinkToHardDrive

}

//

function login()
{
  var self = this;

  if( self.verbosity )
  logger.topicUp( 'Login ..' );

  var payload = { 'email' : self.config.email, 'password' : self.config.password };

  self.config.options =
  {
    url : self.config.loginApiUrl,
    method : 'POST',
    headers : null
  };

  if( self.config.name === 'coursera' )
  {
    payload[ 'webrequest' ] = true;
    self.config.options.json = true;
    self.config.options.body = payload;
  }

  if( self.config.name === 'edx' )
  {
    self.config.options.form = payload;
  }

  return self._prepareHeaders()
  .ifNoErrorThen( _.routineSeal( self,self._request,[ self.config.options ] ) )
  .thenDo( function( err,got )
  {

    if( self.verbosity )
    logger.topicDown( 'Login ' + ( err ? 'error' : 'done' ) + '.' );

    if( err )
    throw _.errLogOnce( err );

    var cookie = got.response.headers[ 'set-cookie' ].join( ';' );
    self._prepareHeaders( 'Cookie', cookie );
    self.userData.auth = 1;

    return got;
  })
}

//

var prepareHeadersAct = {}
prepareHeadersAct.default =
{}

function _prepareHeaders( name, value )
{
  var self = this;
  var con = new wConsequence;

  /* ? */

  if( arguments.length === 2 )
  {
    _.assert( _.strIs( name ) );
    _.assert( _.strIs( value ) );
    self.config.options.headers[ name ] = value;
    return con.give();
  }

  /* */

  if( self.config.name === 'edx' )
  {
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

  }

  /* */

  if( self.config.name === 'coursera' )
  {
    var randomstring = require( 'randomstring' );
    var csrftoken = randomstring.generate( 20 );
    var csrf2cookie = 'csrf2_token_' + randomstring.generate( 8 );
    var csrf2token = randomstring.generate( 24 )
    var cookies = `csrftoken=${csrftoken}; csrf2cookie=${csrf2cookie}; csrf2token=${csrf2token};`
    self.config.options.headers =
    {
      'Cookie' : cookies,
      'X-CSRFToken' : csrftoken,
      'X-CSRF2-Cookie' : csrf2cookie,
      'X-CSRF2-Token' : csrf2token,
      'Connection' : 'keep-alive'
    }

    con.give();
  }

  return con;
}

//

function _parseCourses( src )
{
  var self = this;
  var data = JSON.parse( src );

  self.userData.courses = data.linked[ 'courses.v1' ];
  logger.log( 'Courses list : \n' );

  self.userData.courses.forEach( function( element )
  {
    logger.log( 'element',element );
    logger.log( 'name : ', element.name, ' class_name : ', element.slug, '\n' );
  });

}

//

function _getUserCourses()
{
  var self = this;

  if( !self.userData.auth )
  return;

  if( self.config.name === 'edx' )
  throw _.err( 'now implemented edx get courses section!' );

  logger.log( 'Trying to get courses list.' );

  return self._request
  ({
    url : self.config.getUserCoursesUrl,
    headers : self.config.options.headers
  })
  .thenDo( function( err, got )
  {
    if( err )
    throw _.errLogOnce( err );

    self._parseCourses( got.body );

    return got;
  });

}

//

function _getMaterials( course )
{
  _.assert( _.objectIs( course ) );
  var self = this;

  logger.log( 'Trying to get matetials for : ', course.name );

  var postUrl = _.strReplaceAll( self.config.courseMaterials,'{class_name}', course.slug );

  return self._request( postUrl )
  .thenDo( function( err, got )
  {
    if( err )
    throw _.errLogOnce( err );

    var data = JSON.parse( got.body );
    logger.log( data.courseMaterial );

    return data
  });
}

//

function _request( o )
{
  var self = this;
  var con = new wConsequence();

  _.assert( arguments.length === 1 );

  if( _.strIs( o ) )
  o = { url : o };

  logger.log( 'request' );
  logger.log( o );
  logger.log();

  var callback = o.callback;
  if( callback )
  _.assert( callback.length === 2,'_request : callback should have 2 arguments : ( err ) and ( got )' );

  o.callback = function requestCallback( err, response, body )
  {

    var got = { response : response , body : body };

    if( callback )
    throw _.err( 'not tested' );

    if( callback )
    con.first( _.routineJoin( undefined,callback,got ) );
    else
    con.give( got );

  }

  self._requestAct( o );

  // logger.log( _.diagnosticStack() );

  return con;
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
  config : null,
  userData : null,
  siteName : null,
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
  Request : require( 'request' ),
  register : register,
  Childs : {}
}

// --
// proto
// --

var Proto =
{

  init : init,
  init_static : init_static,

  download : download,

  login : login,

  _parseCourses : _parseCourses,
  _getUserCourses : _getUserCourses,
  _getMaterials : _getMaterials,
  _prepareHeaders : _prepareHeaders,


  //

  _request : _request,


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

if( typeof module !== 'undefined' )
{
  require( './CoursesDownloaderCoursera.s' );
}

Self.prototype.init_static();

})();
