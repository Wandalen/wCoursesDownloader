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
    courseBlocksUrl : 'https://courses.edx.org/api/courses/v1/blocks/?course_id={course_id}&username={username}&depth=all&requested_fields=children&return_type=list',
    // courseInfo : 'https://courses.edx.org/api/courses/v1/courses/{course_id}',

    email : 'wcoursera@gmail.com',
    password : '17159922',

    // "blocks" : 'http://edx.readthedocs.io/projects/edx-platform-api/en/latest/courses/blocks.html'
    // get blocks
    // https://courses.edx.org/api/courses/v1/blocks/?course_id={course_id}&username={username}&depth=all
    // https://courses.edx.org/api/courses/v1/blocks/?course_id={course_id}&username={username}&depth=all&all_blocks=true
    // &student_view_data=video to get some links
    // get with childrens
    // https://courses.edx.org/api/courses/v1/blocks/?course_id={course_id}&username={username}&depth=all&all_blocks=true&student_view_data=video,html,problem&requested_fields=children
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
