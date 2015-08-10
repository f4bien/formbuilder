<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${jcr:hasChildrenOfType(currentNode, 'jnt:required')}">
    <c:set target="${moduleMap}" property="required" value="required"/>
</c:if>