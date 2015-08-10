<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>

<template:include view="hidden.inputs"/>

<template:addResources type="inlinejavascript">
    <script type="text/javascript">
        $(function () {
            $('.form-group-address input')
                    .on('change', function () {
                        var address = null;
                        <c:forTokens items="${moduleMap.inputNames}" var="inputName" delims="," varStatus="status">
                        address += ${not status.first ? "' ' + " : ""}$('input[name="${inputName}"]').val();
                        </c:forTokens>
                        $('\#${currentNode.name}').val(address);
                    }
            );
        });
    </script>
</template:addResources>

<template:include view="hidden.required"/>
<c:set var="requiredClassValue" value="${not empty moduleMap.requiredAttr ? 'required':''}"/>

<div class="form-group-address">
    <input ${disabled}
            type="text"
            id="${currentNode.name}"
            name="${currentNode.name}"
            value="${sessionScope.formDatas[currentNode.name][0]}"
    ${moduleMap.requiredAttr}
            readonly="readonly"/>

    <c:forTokens items="${moduleMap.inputNames}" var="inputName" delims=",">
        <div class="form-group">
            <c:set var="fieldName" value="inputName"/>
            <c:set var="fieldId" value="${fieldName}${currentNode.identifier}"/>
            <label for="${fieldId}"><fmt:message key="address.${fieldName}"/></label>
            <input ${disabled} type="text" class="form-control" id="${fieldId}" name="${fieldName}">
        </div>
    </c:forTokens>
</div>