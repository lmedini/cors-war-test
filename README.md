# cors-war-test

Displays the behavior of Tomcat's CORS filter for non-CORS requests.

## CorsFilter config

To be included in `conf/web.xml`

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

## nginx proxy config

Nginx especially provides HTTPS support.

```
    location /api/ {
        proxy_pass http://localhost:8080/;
        proxy_cookie_path ~*^/([^/]+) /api/$1;
        proxy_set_header host $http_host;
        proxy_set_header X-real-ip $remote_addr;
        proxy_set_header X-forwarded-for $proxy_add_x_forwarded_for;
    }
```
