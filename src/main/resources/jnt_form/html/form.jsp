<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<template:addResources type="javascript" resources="jquery.min.js,jquery.validate.js,jquery.maskedinput.js"/>
<template:addResources type="css" resources="formbuilder.css"/>
<jcr:node var="actionNode" path="${currentNode.path}/action"/>
<jcr:node var="fieldsetsNode" path="${currentNode.path}/fieldsets"/>
<jcr:node var="formButtonsNode" path="${currentNode.path}/formButtons"/>

<c:set var="writeable" value="${currentResource.workspace eq 'live'}" />
<c:if test='${not writeable}'>
    <c:set var="disabled" value='disabled="true"' scope="request" />
</c:if>
<c:if test="${not renderContext.editMode}">
    <template:addResources>
        <script type="text/javascript">
            $(document).ready(function() {
                $("\#${fn:replace(fn:replace(currentNode.name,':','_'),' ','-')}").validate({
                    rules: {
                        <c:forEach items="${fieldsetsNode.nodes}" var="fieldset">
                        <c:forEach items="${jcr:getNodes(fieldset,'jnt:formElement')}" var="formElement" varStatus="status">
                        <c:set var="validations" value="${jcr:getNodes(formElement,'jnt:formElementValidation')}"/>
                        <c:if test="${fn:length(validations) > 0}">
						<c:if test="${not empty rulesAdded}">,</c:if><c:set var="rulesAdded" value="true"/>
                        '${formElement.name}' : {
                            <c:forEach items="${jcr:getNodes(formElement,'jnt:formElementValidation')}" var="formElementValidation" varStatus="val">
                            <template:module node="${formElementValidation}" view="default" editable="true"/><c:if test="${not val.last}">,</c:if>
                            </c:forEach>
                        }
                        </c:if>
                        </c:forEach>
                        </c:forEach>
                    },formId : "${currentNode.name}"
                });
            });
        </script>
    </template:addResources>
</c:if>
<c:set var="displayCSV" value="false"/>
<c:set var="action" value="${url.base}${currentNode.path}/responses/*"/>
<c:if test="${not empty actionNode.nodes}">
    <c:if test="${fn:length(actionNode.nodes) > 1}">
        <c:set var="action" value="${url.base}${currentNode.path}/responses.chain.do"/>
        <c:set var="chainActive" value=""/>
        <c:forEach items="${actionNode.nodes}" var="node" varStatus="stat">
            <c:if test="${jcr:isNodeType(node, 'jnt:defaultFormAction')}"><c:set var="displayCSV" value="true"/></c:if>
            <c:set var="chainActive" value="${chainActive}${node.properties['j:action'].string}"/>
            <c:if test="${not stat.last}"><c:set var="chainActive" value="${chainActive},"/></c:if>
        </c:forEach>
    </c:if>
    <c:if test="${fn:length(actionNode.nodes) eq 1}">
        <c:forEach items="${actionNode.nodes}" var="node">
            <c:if test="${jcr:isNodeType(node, 'jnt:defaultFormAction')}"><c:set var="displayCSV" value="true"/></c:if>
            <c:if test="${node.properties['j:action'].string != 'default'}">
                <c:set var="action" value="${url.base}${currentNode.path}/responses.${node.properties['j:action'].string}.do"/>
            </c:if>
        </c:forEach>
    </c:if>
</c:if>

<h2><jcr:nodeProperty node="${currentNode}" name="jcr:title"/></h2>


<div class="intro">
    ${currentNode.properties['j:intro'].string}
</div>
<c:if test="${renderContext.editMode}">
    <c:forEach items="${actionNode.nodes}" var="formElement">
        <template:module node="${formElement}" editable="true"/>
    </c:forEach>
    <div class="addaction">
        <span><fmt:message key="label.form.addAction"/> : </span>
        <template:module node="${actionNode}" view="hidden.placeholder"/>
    </div>
</c:if>
<div class="Form FormBuilder">


    <c:if test="${not renderContext.editMode}">
        <template:tokenizedForm>
            <form action="<c:url value='${action}'/>" method="post" id="${fn:replace(fn:replace(currentNode.name,':','_'),' ','-')}">
                <input type="hidden" name="originUrl" value="${pageContext.request.requestURL}"/>
                <input type="hidden" name="jcrNodeType" value="jnt:responseToForm"/>
                <input type="hidden" name="jcrRedirectTo" value="<c:url value='${url.base}${renderContext.mainResource.node.path}'/>"/>
                    <%-- Define the output format for the newly created node by default html or by jcrRedirectTo--%>
                <input type="hidden" name="jcrNewNodeOutputFormat" value="html"/>
                <c:if test="${not empty chainActive}">
                    <input type="hidden" name="chainOfAction" value="${chainActive}"/>
                </c:if>
                <c:forEach items="${fieldsetsNode.nodes}" var="fieldset">
                    <template:module node="${fieldset}" editable="true"/>
                </c:forEach>

                <div class="divButton">
                    <c:forEach items="${formButtonsNode.nodes}" var="formButton">
                        <template:module node="${formButton}" editable="true"/>
                    </c:forEach>
                </div>
                <div class="validation"></div>
            </form>
        </template:tokenizedForm>
    </c:if>

    <c:if test="${renderContext.editMode}">
        <input type="hidden" name="jcrNodeType" value="jnt:responseToForm"/>
        <input type="hidden" name="jcrRedirectTo" value="<c:url value='${url.base}${renderContext.mainResource.node.path}'/>"/>
        <%-- Define the output format for the newly created node by default html or by jcrRedirectTo--%>
        <input type="hidden" name="jcrNewNodeOutputFormat" value="html"/>
        <c:if test="${not empty chainActive}">
            <input type="hidden" name="chainOfAction" value="${chainActive}"/>
        </c:if>

        <c:forEach items="${fieldsetsNode.nodes}" var="fieldset">
            <template:module node="${fieldset}" editable="true"/>
        </c:forEach>

        <div class="addfieldsets">
            <span><fmt:message key="label.form.addFieldSet"/> : </span>
            <template:module node="${fieldsetsNode}" view="hidden.placeholder"/>
        </div>

        <c:forEach items="${formButtonsNode.nodes}" var="formButton">
            <template:module node="${formButton}" editable="true"/>
        </c:forEach>
        <div class="addbuttons">
            <span><fmt:message key="label.form.addButtons"/> : </span>
            <template:module node="${formButtonsNode}" view="hidden.placeholder"/>
        </div>
    </c:if>

</div>
<br/><br/>
<c:if test="${displayCSV eq 'true'}">
    <div>
        <h2><fmt:message key="form.responses"/> : <a href="<c:url value='${url.baseLive}${currentNode.path}/responses.csv'/>" target="_blank">CSV</a> - <a href="<c:url value='${url.baseLive}${currentNode.path}/responses.html'/>" target="_blank">HTML</a></h2>
        <%--<template:list path="responses" listType="jnt:responsesList" editable="true" />--%>
    </div>
</c:if>

