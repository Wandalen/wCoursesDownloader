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

//

function Loader( className )
{
  var self = this;

  if( className === undefined )
  {
    return self.Childs[ 'CoursesDownloaderCoursera' ]();
  }
  else
  {
    _.assert( self.Childs[ className ] );

    return self.Childs[ className ]();
  }

}

//

function registerClass()
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

  self.config.payload = { 'email' : self.config.email, 'password' : self.config.password };

  self.config.options =
  {
    url : self.config.loginApiUrl,
    method : 'POST',
    headers : null
  };

  self._loginAct();

  return self.prepareHeaders()
  .ifNoErrorThen( _.routineSeal( self,self._request,[ self.config.options ] ) )
  .thenDo( function( err,got )
  {

    if( self.verbosity )
    logger.topicDown( 'Login ' + ( err ? 'error' : 'done' ) + '.' );

    if( err )
    throw _.errLogOnce( err );

    var cookie = got.response.headers[ 'set-cookie' ].join( ';' );
    self.prepareHeaders( 'Cookie', cookie );
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
    return self.getUserCourses();
  })
  .ifNoErrorThen( function()
  {
    return self.coursesList();
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

function prepareHeaders( name, value )
{
  var self = this;
  var con = new wConsequence;

  /* */

  if( arguments.length === 2 )
  {

    /* !!! what is it for? */

    _.assert( _.strIs( name ) );
    _.assert( _.strIs( value ) );
    self.config.options.headers[ name ] = value;
    return con.give();
  }

  /* */

  con = self._prepareHeadersAct();

  return con;
}

//

function coursesList()
{
  var self = this;

  return self._coursesListAct();
}

//

function getUserCourses()
{
  var self = this;

  if( !self.userData.auth )
  return;

  return self._getUserCoursesAct();
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
  Childs : {},
  registerClass : registerClass,
  Loader : Loader,
}

// --
// proto
// --

var Proto =
{

  init : init,

  download : download,

  login : login,

  coursesList : coursesList,
  getUserCourses : getUserCourses,
  _getMaterials : _getMaterials,
  prepareHeaders : prepareHeaders,

  //Act

  _loginAct : null,
  _prepareHeadersAct : null,
  _getUserCoursesAct : null,
  _coursesListAct : null,


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
  require( './CoursesDownloaderEdx.s' );
}

Self.prototype.Loader();

})();
