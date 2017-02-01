### Coursera

### Login
Login URL : https://www.coursera.org/api/login/v3

Request method : POST

What we need to make request:
1. Create json payload:

  - { 'email' : your_email, 'password' : your_password, 'webrequest' : true }

2. Prepare cookies:

  - csrftoken - random string, length : 20
  - csrf2cookie - 'csrf2_token_' + random string with 8 symbols
  - csrf2token - random string, length : 24

3. Prepare Headers :
  - 'Cookie' : cookies
  - 'X-CSRFToken' : csrftoken,
  - 'X-CSRF2-Cookie' : csrf2cookie,
  - 'X-CSRF2-Token' : csrf2token,
  - 'Connection' : 'keep-alive'

Headers example:
```
headers :
{
  Cookie : "csrftoken=P6MoCuQx64kxAqHsdhYt; csrf2cookie=csrf2_token_MCOh2fZA; csrf2token=e725inBmEfiehfgUKbL1svl0;",
  X-CSRFToken : "P6MoCuQx64kxAqHsdhYt",
  X-CSRF2-Cookie : "csrf2_token_MCOh2fZA",
  X-CSRF2-Token : "e725inBmEfiehfgUKbL1svl0",
  Connection : "keep-alive"
},
```

On success server will return body:
```
{
"errorCode": "OK",
"message": null,
"details": null
}
```
Also after login server will return `Set-Cookie` header in response.
Values of `Set-Cookie` are used to perform calls to Coursera API, so
our `Cookie` header must be replaced with value of `Set-Cookie`.

### API

List of all courses - https://www.coursera.org/api/courses.v1?start={page}

Example:https://www.coursera.org/api/courses.v1?start=0

Part of Response:
```
{
"elements":
[

  {
  "courseType":"v2.ondemand",
  "id":"0HiU7Oe4EeWTAQ4yevf_oQ",
  "slug":"missing-data",
  "name":"Dealing With Missing Data"
  },

  ...
]
}
```
