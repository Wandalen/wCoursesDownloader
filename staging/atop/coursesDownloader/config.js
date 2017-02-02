module.exports =
{
  Edx :
  {
    name : 'Edx',

    loginPageUrl : 'https://courses.edx.org/login',
    loginApiUrl : 'https://courses.edx.org/user_api/v1/account/login_session/',
    dashboardUrl : 'https://courses.edx.org/dashboard',
    enrollmentUrl : 'https://courses.edx.org/api/enrollment/v1/enrollment',
    courseUrl : 'https://courses.edx.org/courses/{course_id}/info',

    email : 'wcoursera@gmail.com',
    password : '17159922',
  },
  Coursera :
  {
    /*
    source:
    https://github.com/coursera-dl/coursera-dl/blob/master/coursera/define.py
    */
    name : 'Coursera',

    getUserCoursesUrl : 'https://www.coursera.org/api/memberships.v1?fields=courseId,enrolledTimestamp,grade,id,lastAccessedTimestamp,onDemandSessionMembershipIds,onDemandSessionMemberships,role,v1SessionId,vc,vcMembershipId,courses.v1(courseStatus,display,partnerIds,photoUrl,specializations,startDate,v1Details,v2Details),partners.v1(homeLink,name),v1Details.v1(sessionIds),v1Sessions.v1(active,certificatesReleased,dbEndDate,durationString,hasSigTrack,startDay,startMonth,startYear),v2Details.v1(onDemandSessions,plannedLaunchDate,sessionsEnabledAt),specializations.v1(logo,name,partnerIds,shortName)&includes=courseId,onDemandSessionMemberships,vcMembershipId,courses.v1(partnerIds,specializations,v1Details,v2Details),v1Details.v1(sessionIds),v2Details.v1(onDemandSessions),specializations.v1(partnerIds)&q=me&showHidden=true&filter=current,preEnrolled',
    loginApiUrl :'https://www.coursera.org/api/login/v3',
    courseMaterials: 'https://www.coursera.org/api/opencourse.v1/course/{class_name}?showLockedItems=true',
    getVideoApi : 'https://www.coursera.org/api/opencourse.v1/video/{id}',

    email : 'wcoursera@gmail.com',
    password : '17159922',
  },
  defaultPlatform : 'Coursera'
}
