package org.jahia.modules.formbuilder.helper;

import java.util.List;
import java.util.Map;

import javax.jcr.NodeIterator;

import org.jahia.services.content.JCRNodeWrapper;
import org.slf4j.Logger;

public class FormBuilderHelper {
	private transient static Logger logger = org.slf4j.LoggerFactory.getLogger(FormBuilderHelper.class);
	
	public static String getNodeTitle(JCRNodeWrapper formNode, String fieldname) {
	    JCRNodeWrapper node = getFieldNode(formNode, fieldname);
	    if(node != null) {
	    	return node.getPropertyAsString("jcr:title");
	    }
		return fieldname;
	}
	
	public static String getNodeValue(JCRNodeWrapper formNode, Map<String, List<String>> fieldvalues, String fieldname) {
		
		try{
			List<String> values = (List<String>)fieldvalues.get(fieldname);

			if(values == null) { //special type
				JCRNodeWrapper node = getFieldNode(formNode, fieldname);
				if(node.getNodeTypes().contains("jnt:addressBlock")) { //Address
					values = fieldvalues.get("street");
					if(values != null && values.size() > 0) {
						if(values.size() == 1) {
							return getAddress(fieldvalues, 1);
						} else { //multiple address fields
							return getAddress(fieldvalues, getFieldPosition(formNode, fieldname, "jnt:addressBlock"));
						}
					}
					return "";  //Address not found
				} else if(node.getNodeTypes().contains("jnt:fileElement")) { //File
					//TODO: when attachments are implemented
					return "File Attachment currently not implemented";  
				} 
				return "";  //for instance for captcha
			}
			if(values.size() == 1) { //only one entry (single field)
				return values.get(0);
			} 
			if(values.size() > 1) {  //multiple fields 
				//just possible when you add textfields with same name as in address
				//but not possible to calculate the correct position
				logger.warn("In your form "+ formNode.getName() + " you have duplicate fields, check it and rename one field, because wrong value could appear in email: "  + fieldname);
				return values.get(0);			
			}
		}catch(Exception ex) {
			logger.error("Error when reading Fieldvalue for " + fieldname,  ex);
		}
		return "";
	}
	
	private static JCRNodeWrapper getFieldNode(JCRNodeWrapper formNode, String fieldname) {
		try{
		    NodeIterator ni = formNode.getNodes();
		    while(ni.hasNext()) {
		    	JCRNodeWrapper node = (JCRNodeWrapper)ni.next();
		    	if(node.getPath().endsWith("fieldsets")) {
		    	   NodeIterator nifieldsets = node.getNodes();  //get all Fieldsets
		    	   while(nifieldsets.hasNext()) {
		    		   JCRNodeWrapper nodefieldset = (JCRNodeWrapper)nifieldsets.next();
		    		   NodeIterator nifield = nodefieldset.getNodes(fieldname); //get field by name
		    		   if(nifield.getSize() > 0) {
		    			  JCRNodeWrapper nodefield = (JCRNodeWrapper)nifield.next();
		    		      return nodefield;
		    		   }
		    	   }
		    	}
		    }
		}catch(Exception ex) {
			logger.error("Error when try to get formfield node " + fieldname,  ex);
		}
		return null;		
	}
	
	private static int getFieldPosition(JCRNodeWrapper formNode, String fieldname, String fieldtype) {
		int position = 1;
		try{
		    NodeIterator ni = formNode.getNodes();
		    while(ni.hasNext()) {
		    	JCRNodeWrapper node = (JCRNodeWrapper)ni.next();
		    	if(node.getPath().endsWith("fieldsets")) {
		    	   NodeIterator nifieldsets = node.getNodes();  //get all Fieldsets
		    	   while(nifieldsets.hasNext()) {
		    		   JCRNodeWrapper nodefieldset = (JCRNodeWrapper)nifieldsets.next();
		    		   NodeIterator nifields = nodefieldset.getNodes(); //get all fields
		    		   while(nifields.hasNext()) {
		    			  JCRNodeWrapper nodefield = (JCRNodeWrapper)nifields.next();
		    		      if(nodefield.getNodeTypes().contains(fieldtype)) {
		    		    	 if(fieldname.equals(nodefield.getName())) {
		    		    	   return position;
		    		    	 }
		    		    	 position ++;
		    		      }
		    		   }
		    	   }
		    	}
		    }
		}catch(Exception ex) {
			logger.error("Error when try to get formfield node " + fieldname + " to analyze position",  ex);
		}	
		
		return 1;
	}
	
	private static String getAddress(Map<String, List<String>> values, int position) {
		
		StringBuffer address = new StringBuffer();
		List<String> subvalues = values.get("street");
		if(subvalues != null && subvalues.size() >= position) {
			address.append(subvalues.get(position-1));
		}
		subvalues = values.get("street2");
		if(subvalues != null && subvalues.size() >= position) {
			address.append(", ").append(subvalues.get(position-1));
		}
		subvalues = values.get("city");
		if(subvalues != null && subvalues.size() >= position) {
			address.append(", ").append(subvalues.get(position-1));
		}	
		subvalues = values.get("zip");
		if(subvalues != null && subvalues.size() >= position) {
			address.append(", ").append(subvalues.get(position-1));
		}	
		subvalues = values.get("state");
		if(subvalues != null && subvalues.size() >= position) {
			address.append(", ").append(subvalues.get(position-1));
		}
		subvalues = values.get("country");
		if(subvalues != null && subvalues.size() >= position) {
			address.append(", ").append(subvalues.get(position-1));
		}		
		return address.toString();
	}

}
