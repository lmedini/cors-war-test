<%@ page pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CORS Filter test - headers</title>
</head>
<body>
<h1>Test CorsFilter headers</h1>

<p>This webapp will behave nicely when directly queried on the Tomcat server, but POST requests will fail when behind an nginx proxy.</p>

<h2>HTTP Headers Received from <%= request.getMethod() %> request</h2>
<table>
    <c:forEach items="${header}" var="h">
        <tr>
            <td>
                <c:out value="${h.key}"/>
            </td>
            <td>
                <c:out value="${h.value}"/>
            </td>
        </tr>
    </c:forEach>
</table>

<p><strong>
    <c:if test="${pageContext.request.method == \"GET\"}">
        Notice the <code>sec-fetch-site</code> header when behind a proxy (no CORS headers when Tomcat is queried directly).
    </c:if>
    <c:if test="${pageContext.request.method == \"POST\"}">
        Notice the <code>Origin: <c:out value="${header.origin}"/></code> header when NOT behind a proxy (this origin is accepted by the server).
    </c:if>
</strong></p>
</body>
</html>