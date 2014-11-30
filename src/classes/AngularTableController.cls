global with sharing class AngularTableController {
	
	public AngularTableController() {
		
	}

	public String v_sobjectName		{get;set;}
	public String v_fieldSetName	{get;set;}
    public String v_fieldCsv        {get;set;}


    public List<String> getFields(){

    	List<String> fields = new List<String>();
    		
    	if(v_fieldSetName != null && v_fieldSetName != ''){
    		
    		Schema.FieldSet fieldSet;

    		for(Schema.FieldSet fSet : Schema.getGlobalDescribe().get(v_sobjectName).getDescribe().fieldSets.getMap().values()){
                if(fSet.getLabel().equalsIgnoreCase(v_fieldSetName)){
                    fieldSet = fSet;
                    break;
                }
            }

            if(fieldSet == null)
                throw new AngularException('Fieldset name provided is not found');

            for(Schema.FieldSetMember fm : fieldSet.getFields()){
            	fields.add(fm.getFieldPath());
            }


    	}else if(v_fieldCsv != null && v_fieldCsv != ''){
			for(String s : v_fieldCsv.split(',')){
				fields.add(s.trim());
			}

    	}else{
    		throw new AngularException('Either Fieldset or FieldCSV must be supplied');
    	}

    	return fields;
    }

    
    public Map<String,String> getfieldLabelMap(){
        return getFieldLabelMap(v_sobjectName); // returns the Map of Field Labels.
    }

    public List<String> getfieldList(){
        List<String> fields = new List<String>();
        for(String s : v_fieldCsv.split(','))
            fields.add(s.trim());

        return fields;    
    }

    /**
     * Remoting method to get the fieldLabMap for any SObject, basically would return labels to show on a Table
     * @param sobjectName - Salesforce SObjectName
     * @return Map<String,String> 
     */

    @RemoteAction
    global static Map<String,String> getFieldLabelMap(String sobjectName){
        Map<String, String> fieldLabelMap       = new Map<String, String>();
        Map<String, Schema.SObjectField> FsMap  = Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap();
        
        for(String field : FsMap.keySet()){
                fieldLabelMap.put(
                FsMap.get(field).getDescribe().getName(),
                FsMap.get(field).getDescribe().getLabel());
        }
        
        return fieldLabelMap;
    }

    /**
     * Remoting method to getAllRecords
     * @param sobjectName - Salesforce SObjectName
     * @return List<SObject>
     */

    @RemoteAction
    global static List<SObject> getAllRecords(String sobjectName, String fieldSetName, String fieldCsv){

        List<SObject> records = new List<SObject>();

        if(fieldSetName == null && fieldCsv == null){
            throw new AngularException('Either FieldSet Name or FieldCSV must be provided');
        }

        String selectorCsv = '';
        if(fieldSetName != null && fieldSetName != ''){
            
            Schema.FieldSet fieldSet;
            // Get the fieldset based on the Name 
            for(Schema.FieldSet fSet : Schema.getGlobalDescribe().get(sobjectName).getDescribe().fieldSets.getMap().values()){
                if(fSet.getLabel().equalsIgnoreCase(fieldSetName)){
                    fieldSet = fSet;
                    break;
                }
            }

            if(fieldSet == null)
                throw new AngularException('Fieldset name provided is not found');

            for(Schema.FieldSetMember fm : fieldSet.getFields()){
                selectorCsv += fm.getFieldPath() + ',';
            }
        }else{
            selectorCsv = fieldCsv;
        }

        selectorCsv = selectorCsv.removeEnd(','); 

        // Add the Id if Selector does not contain Id.
        if(!selectorCsv.containsIgnoreCase('id'))
            selectorCsv = 'Id, ' + selectorCsv; 

        records =  Database.query('Select ' + selectorCsv + ' from ' + sobjectName + ' LIMIT 2000'); 
        
        return records;
    
    }

    public class AngularException extends Exception {}

}