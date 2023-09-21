# Tomcat CorsFilter test

Displays the behavior of Tomcat's CORS filter for same-origin (aka non-CORS) requests.

Aims to demonstrate the issue mentioned in [Bug 67472](https://bz.apache.org/bugzilla/attachment.cgi?id=39049).

## Server configuration

To reproduce this issue, you need the following setup: a Tomcat server (tested with 10.1.13), and a reverse proxy (tested with nginx 1.24). Setup installed on an Ubuntu 22.04 server VM, in an Openstack infrastructure.

### nginx proxy config

```
    location /api/ {
        proxy_pass http://localhost:8080/;
        proxy_cookie_path ~*^/([^/]+) /api/$1;
        proxy_set_header host $http_host;
        proxy_set_header X-real-ip $remote_addr;
        proxy_set_header X-forwarded-for $proxy_add_x_forwarded_for;
    }
```

On my VM, nginx also provides HTTPS support -> requests to the webapp start with http://VM_IP:8080/testcors/ to query Tomcat directly, and with https://VM_IP/api/testcors/ to query it through the proxy.

### Tomcat CorsFilter config

To be included at server level, in `conf/web.xml`.

```xml
<filter>
  <filter-name>CorsFilter</filter-name>
  <filter-class>org.apache.catalina.filters.CorsFilter</filter-class>
  <init-param>
    <param-name>cors.allowed.origins</param-name>
    <param-value>https://another.origin.than.that.of.the.proxy</param-value>
  </init-param>
  <init-param>
    <param-name>cors.allowed.methods</param-name>
    <param-value>GET,POST,PUT,DELETE,OPTIONS</param-value>
  </init-param>
  <init-param>
    <param-name>cors.allowed.headers</param-name>
    <param-value>Content-Type,X-Requested-With,accept,Origin,Access-Control-Request-Method,Access-Control-Request-Headers,Auth
orization</param-value>
  </init-param>
  <init-param>
    <param-name>cors.exposed.headers</param-name>
    <param-value>Access-Control-Allow-Origin,Access-Control-Allow-Credentials,Authorization</param-value>
  </init-param>
  <init-param>
    <param-name>cors.support.credentials</param-name>
    <param-value>true</param-value>
  </init-param>
</filter>
<filter-mapping>
  <filter-name>CorsFilter</filter-name>
  <url-pattern>/*</url-pattern>
</filter-mapping>
```

## Installation & deployment

- Java version >= 17
- `mvn package`
- deploy war on Tomcat's `webapps` dir
- request webapp at context `/testcors`

## Observed behavior

- Regardless of traversing the proxy or not, the first request to the app returns the `index.html` page, with the following headers:

```
vary: Origin
Access-Control-Allow-Credentials: true
Access-Control-Expose-Headers: Authorization,Access-Control-Allow-Origin,Access-Control-Allow-Credentials
```

- Clicking on the link (provokes a GET request) also succeeds, since the client does not send an `Origin` header. However, it behaves differently: behind a proxy, it adds a `sec-fetch-site` header to force non-cors behavior; this header is not present in direct queries.
- Clicking on the button (provokes a POST request) causes the client to send an `Origin` header. If this origin is not in the `cors.allowed.origins` config parameter, Tomcat somehow guesses when it corresponds to its direct base URL and explicitely accepts it with an `Access-Control-Allow-Origin` header (strange behavior), but as it is unable to "recognize" the proxy's origin, it blocks it (logical behavior, but buggy regarding the spec, IMHO).
