public with sharing class LtngMapController {

    //Holds all the fields for an error to be inserted in the @future method.
    //Doesn't actually get directly inserted
    public static ltngMap__Map_Error__c mapError = new ltngMap__Map_Error__c();

    /*
        getPropertyAddress
        Retrieves the values for the specified fields on the record the component is currently sitting on
        Uses the Location and MapMarker inner classes to hold the data and returns them to the component for display
        If the user does not have permission, sends null to the component
    */
    @AuraEnabled(cacheable=true)
    public static List<MapMarker> getAddress(id recId, String street, String city, String state, String country, String postcode, String recordName, String recordDesc, String geo) {
        String mapName = ' ';
        String mapDesc = ' ';
        String objType = recId.getsobjecttype() + '';
        String fields = '';
        Boolean geoField = false;
        if(!notNullOrBlank(geo.trim())){
            fields = street + ',' + city + ',' + state + ',' + country + ',' + postcode;
        }else{
            geo = geo.left(geo.length()-1).trim(); //Remove the c from __c so it can be replace with lat and long
            fields = geo + 'latitude__s,' + geo + 'longitude__s';
            geoField = true;
        }


        if(notNullOrBlank(recordName)){
            fields += ',' + recordName;
        }else{
            recordName = '';
        }
        if(notNullOrBlank(recordDesc)){
            fields += ',' + recordDesc;
        } 

        String query = 'SELECT ' + fields + ' FROM ' + objType + ' WHERE id = ';
        query = String.escapeSingleQuotes(query);
        query += '\'' + recId + '\'';
        setCoreErrorFields(query, objType, recId);

        if(hasAccess(objType, fields.split(','))){
            try{
                SObject recordDetail = Database.query(query);

                Location loc = new Location();
                if(geoField){
                    loc.setLocation((Decimal)recordDetail.get(geo + 'latitude__s'), (Decimal)recordDetail.get(geo + 'longitude__s'));
                }else{
                    loc.setLocation((string)recordDetail.get(street), (string)recordDetail.get(city), (string)recordDetail.get(state), (string)recordDetail.get(postcode), (string)recordDetail.get(country));
                }
                if(notNullOrBlank(recordName)){
                    mapName = (string)recordDetail.get(recordName);
                }
                if(notNullOrBlank(recordDesc)){
                    mapDesc = (string)recordDetail.get(recordDesc);
                }
                MapMarker mark = new MapMarker('icon', mapName, mapDesc, loc);
                List<MapMarker> locs = new List<MapMarker>{mark};
                return locs;
            }catch(Exception e){
                mapError.ltngMap__Exception_Type__c += e.getTypeName();
                mapError.ltngMap__Exception_Message__c += e.getMessage();
            }
        }
        insertError(
            mapError.ltngMap__Record_ID__c,
            mapError.ltngMap__Object_Name__c,
            mapError.ltngMap__Mapping_Query__c,
            mapError.ltngMap__Inaccessible_Fields__c,
            mapError.ltngMap__Exception_Type__c,
            mapError.ltngMap__Exception_Message__c,
            userInfo.getUserId());
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<MapMarker> getAddressFromLatLong(String lat, String lon){
        return null;


    }

    @AuraEnabled(cacheable=true)
    public static List<MapMarker> getAddressFromAddressFields(id recId, String street, String city, String state, String country, String postcode, String recordName, String recordDesc){
        return null;
    }

    /*
        insertError
        If an error has occurred which doesn't already match an error created today, 
        insert an error record to let the sys admin know. 
        In all likelihood, the executing user doesn't have access to the error object
        but we should insert the error object anyway, for the admin.
        Needs to be @Future due to @AuraEnabled method being cacheable.
        @Future only takes primative types
    */
    @future
    public static void insertError(String id, String obj, String query, String fields, String type, String msg, id usr){
        boolean createdToday = false;
        List<ltngMap__Map_Error__c> errors = [SELECT id, 
            ltngMap__Record_ID__c, 
            ltngMap__Mapping_Query__c, 
            ltngMap__Inaccessible_Fields__c,
            ltngMap__Exception_Type__c,
            ltngMap__Exception_Message__c,
            createdById FROM ltngMap__Map_Error__c WHERE CreatedDate = TODAY];
        for(ltngMap__Map_Error__c error : errors){
            if(error.ltngMap__Inaccessible_Fields__c == null){
                error.ltngMap__Inaccessible_Fields__c = '';
            }
            if(error.ltngMap__Record_ID__c == id &&
                error.ltngMap__Mapping_Query__c == query &&
                error.ltngMap__Inaccessible_Fields__c == fields &&
                error.ltngMap__Exception_Type__c == type &&
                error.ltngMap__Exception_Message__c == msg &&
                error.createdById == usr){
                    createdToday = true;
                }
        }
        if(!createdToday){
            insert new ltngMap__Map_Error__c(
                ltngMap__Record_ID__c = id,
                ltngMap__Object_Name__c = obj,
                ltngMap__Mapping_Query__c = query,
                ltngMap__Inaccessible_Fields__c = fields,
                ltngMap__Exception_Type__c = type,
                ltngMap__Exception_Message__c = msg);
        }
    }

    /*
        setCoreErrorFields
        Set up the error record with the record details in case we need
        to insert the record due to an error 
    */
    public static void setCoreErrorFields(String query, String objType, String id){
        mapError.ltngMap__Record_ID__c = id;
        mapError.ltngMap__Object_Name__c = objType;
        mapError.ltngMap__Mapping_Query__c = query;
        mapError.ltngMap__Inaccessible_Fields__c = '';
        mapError.ltngMap__Exception_Type__c= '';
        mapError.ltngMap__Exception_Message__c= '';
    }

    /*
        notNullOrBlank
        Returns true if a given string is either a null value or empty String
    */
    public static boolean notNullOrBlank(String fieldName){
        return (fieldName != null && fieldName != '');
    }

    /*
        hasAccess
        Determins whether a given list of strings are accessible to the current user, for a given object
    */
    public static boolean hasAccess(String SObj, List<String> fields){
        SObjectType objType = Schema.getGlobalDescribe().get(SObj);
        Map<String,Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();

        boolean access = true;
        for(String field : fields){
            try{
                if (!fieldMap.get(field).getDescribe().isAccessible()) {
                    access = false;
                    mapError.ltngMap__Inaccessible_Fields__c += field + ', ';
                }
            }catch(Exception e){
                mapError.ltngMap__Exception_Type__c += e.getTypeName() + ' | ';
                mapError.ltngMap__Exception_Message__c += e.getMessage() + ' | ';   
            }
        }
        if(!access){
            mapError.ltngMap__Exception_Type__c += new System.NoAccessException().getTypeName() + ', ';
        }
        return access;
    }

    /*
        MapMarker
        Holds the data structure for the lightning-map component
    */
    public class MapMarker{
        @AuraEnabled 
        public String icon;  
        @AuraEnabled 
        public String title;  
        @AuraEnabled
        public String description;
        @AuraEnabled 
        public Location location;

        public MapMarker(String i, String t, String d, Location l){
            icon = i;
            title = t;
            description = d;
            location = l;
        }
    }

    /*
        Location
        Holds the data structure for inside the lightning-map component
    */
    public class Location{
        @AuraEnabled 
        public String Street;
        @AuraEnabled 
        public String PostalCode;
        @AuraEnabled 
        public String City;
        @AuraEnabled 
        public String State; 
        @AuraEnabled 
        public String Country; 
        @AuraEnabled
        public Decimal Latitude;
        @AuraEnabled
        public Decimal Longitude;

        public void setLocation(String strt, String cit, String stat, String pc, String ctry){
            Street = strt;
            City = cit;
            State = stat;
            PostalCode = pc;
            Country = ctry;
        }

        public void setLocation(Decimal lat, Decimal lon){
            Latitude = lat;
            Longitude = lon;
        }

        public Location(){

        }
    }
}