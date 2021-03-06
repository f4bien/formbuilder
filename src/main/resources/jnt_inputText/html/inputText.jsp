<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<c:if test="${not empty props.mask}">
    <template:addResources>
        <script type="text/javascript">
            $(function() {
                $("\#${currentNode.name}").mask("${currentNode.properties.mask.string}");
            });
        </script>
    </template:addResources>
</c:if>

<c:set var="required" value=""/>
<c:if test="${jcr:hasChildrenOfType(currentNode, 'jnt:required')}">
    <c:set var="required" value="required"/>
</c:if>

<div class="form-group">
<label for="${currentNode.name}">${fn:escapeXml(currentNode.properties['jcr:title'].string)}</label>
<input ${disabled} type="text" ${required} class="form-control ${required}" id="${currentNode.name}" name="${currentNode.name}" maxlength="${currentNode.properties.maxLength.long}" size="${currentNode.properties.size.long}"
                   value="<c:if test="${not empty sessionScope.formError}">${sessionScope.formDatas[currentNode.name][0]}</c:if><c:if test="${empty currentNode.properties.mask and empty sessionScope.formError}">${currentNode.properties.defaultValue.string}</c:if>"/>
<c:if test="${renderContext.editMode}">
    <div class="formMarginLeft">
        <fmt:message key="label.listOfValidation"/>
        <ol>
            <c:forEach items="${jcr:getNodes(currentNode,'jnt:formElementValidation')}" var="formElement" varStatus="status">
                <li><template:module node="${formElement}" view="edit"/></li>
            </c:forEach>
        </ol>
        <div class="addvalidation">
            <span><fmt:message key="label.addValidation"/></span>
            <template:module path="*"/>
        </div>
    </div>
</c:if>
</div>
