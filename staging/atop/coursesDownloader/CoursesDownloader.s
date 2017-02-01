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
    self.userData.resources = [];
  }

  if( !self._requestAct )
  self._requestAct = self.Request.defaults({ jar : true });

  if( !self._sync )
  self._sync = new wConsequence().give();

}

// --
// make
// --

function make()
{
  var self = this;

  self._sync
  .ifNoErrorThen( function()
  {
    return self._make();
  });

  return self;
}

//

function _make()
{
  var self = this;

  self.config.payload = { 'email' : self.config.email, 'password' : self.config.password };

  self.config.options =
  {
    url : self.config.loginApiUrl,
    method : 'POST',
    headers : null
  };

  self._makeAct();

  self._makePrepareHeadersForLogin();

  self._make.completed = true;

  return new wConsequence().give();
}

_make.completed =  false;

//

function _makePrepareHeadersForLogin()
{
}

// --
// login
// --

function login()
{
  var self = this;

  self._sync
  .ifNoErrorThen( function()
  {
    return self._login();
  });

  return self;
}

//

function _login()
{
  var self = this;
  var con = new wConsequence().give();

  if( self.verbosity )
  logger.topicUp( 'Login ..' );

  if( !self.config.options )
  con = self._make();

  con.ifNoErrorThen( _.routineSeal( self,self._request,[ self.config.options ] ) )
  .thenDo( function( err,got )
  {
    if( err )
    err = _.err( err );
    // throw _.errLogOnce( err );

    if( got.response.statusCode !== 200 )
    err = _.err( "Login failed. StatusCode: ", got.response.statusCode, "Server response: ", got.body );

    if( self.verbosity )
    logger.topicDown( 'Login ' + ( err ? 'error' : 'done' ) + '.' );

    if( err )
    return con.error( err );

    var cookie = got.response.headers[ 'set-cookie' ].join( ';' );
    self.updateHeaders( 'Cookie', cookie );
    _login.completed = true;

    return got;
  });

  return con;
}

_login.completed = false;

// --
// download
// --

function download( course )
{
  var self = this;

  self._sync
  .ifNoErrorThen( function()
  {
    return self._download( course );
  })

  return self;
}

//

function _download( course )
{
  var self = this;

  var con = new wConsequence().give();

  if( !_login.completed )
  con = self._login();

  con.ifNoErrorThen( function()
  {
    return self._coursesList();
  })
  .ifNoErrorThen( function( courses )
  {
    if( course === undefined )
    course = courses[ 0 ];

    return self._resourcesList( course );
  })
  .thenDo( function( err,got )
  {
    if( err )
    throw _.errLogOnce( err );
  });

  return self;
}

// --
// courses
// --

function coursesList()
{
  var self = this;

  self._sync
  .ifNoErrorThen( function()
  {
    return self._coursesList();
  });

  return self;
}

//

function _coursesListAct()
{
  var con = new wConsequence().give();
  return con;
}
_coursesListAct.completed = false;

//

function _coursesList()
{
  var self = this;

  if( !_login.completed )
  return new wConsequence().error( _.err( 'User is not logged in, cant get courses list ' ) );

  return self._coursesListAct();
}

// --
// resources
// --

function resourcesList( course )
{
  var self = this;

  self._sync
  .ifNoErrorThen( function()
  {
    return self._resourcesList( course );
  })

}

//

function _resourcesList( course )
{
  var con = new wConsequence().give();
  return con;
}

// --
// etc
// --

function updateHeaders( name, value )
{
  /* !!! what is it for? */
  var self = this;
  _.assert( _.strIs( name ) );
  _.assert( _.strIs( value ) );
  self.config.options.headers[ name ] = value;
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
  logger.log( _.toStr( o,{ levels : 1 } ) );
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

//

function makeCompleted()
{
  var self = this;
  return Boolean( self._make.completed );
}

//

function loginCompleted()
{
  var self = this;
  return Boolean( self._login.completed );
}

//

function coursesListCompleted()
{
  var self = this;
  return Boolean( self._coursesListAct.completed );
}




// --
// class
// --

function Loader( className )
{
  var self = this;

  if( className === undefined )
  {
    return self.Classes[ 'CoursesDownloaderCoursera' ]();
  }
  else
  {
    _.assert( self.Classes[ className ] );

    return self.Classes[ className ]();
  }

}

//

function registerClass()
{
  _.assert( arguments.length > 0 );

  for( var a = 0 ; a < arguments.length ; a++ )
  {
    var child = arguments[ a ];
    this.Classes[ child.nameShort ] = child;
  }

  return this;
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
  Classes : {},
  registerClass : registerClass,
  Loader : Loader,
}

// --
// proto
// --

var Proto =
{

  init : init,

  // download

  download : download,
  _download : _download,

  // make

  make : make,
  _make : _make,
  _makeAct : null,
  _makePrepareHeadersForLogin : _makePrepareHeadersForLogin,

  // login

  _login : _login,
  login : login,

  // courses

  coursesList : coursesList,
  _coursesList : _coursesList,
  _coursesListAct : _coursesListAct,

  // resources

  resourcesList : resourcesList,
  _resourcesList : _resourcesList,


  // etc

  updateHeaders : updateHeaders,
  _request : _request,

  //flags

  makeCompleted : makeCompleted,
  loginCompleted : loginCompleted,
  coursesListCompleted : coursesListCompleted,

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
