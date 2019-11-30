public with sharing class LtngMapController {

    @AuraEnabled(cacheable=true)
    public static List<MapMarker> getPropertyAddress(id recId, String street, String city, String state, String country, String postcode, String recordName, String recordDesc) {
        system.debug(recId);
        String mapName = ' ';
        String mapDesc = ' ';
        String objType = recId.getsobjecttype() + '';
        String fields = street + ',' + city + ',' + state + ',' + country + ',' + postcode;
        
        if(notNullOrBlank(recordName)){
            fields += ',' + recordName;
        }else{
            recordName = '';
        }
        if(notNullOrBlank(recordDesc)){
            fields += ',' + recordDesc;
        } 

        if(hasAccess(objType, fields.split(','))){
            String query = 'SELECT ' + fields + ' FROM ' + objType + ' WHERE id = ' + '\'' + recId + '\'';
            system.debug(query);
            SObject recordDetail = Database.query(query);
            Location loc = new Location((string)recordDetail.get(street), (string)recordDetail.get(city), (string)recordDetail.get(state), (string)recordDetail.get(country), (string)recordDetail.get(postcode));
            if(notNullOrBlank(recordName)){
                mapName = (string)recordDetail.get(recordName);
            }
            if(notNullOrBlank(recordDesc)){
                mapDesc = (string)recordDetail.get(recordDesc);
            }
            MapMarker mark = new MapMarker('icon', mapName, mapDesc, loc);
            system.debug(mark);
            List<MapMarker> locs = new List<MapMarker>{mark};
            return locs;
        }else{
            return null;
        }
    }

    public static boolean notNullOrBlank(String fieldName){
        return (fieldName != null && fieldName != '');
    }

    @AuraEnabled(cacheable=true)
    public static boolean hasAccess(String SObj, List<String> fields){
        SObjectType objType = Schema.getGlobalDescribe().get(SObj);
        Map<String,Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();

        boolean access = true;
        for(String field : fields){
            system.debug(fieldMap);
            system.debug(fields);
            system.debug(field);
            if (!fieldMap.get(field).getDescribe().isAccessible()) {
                access = false;
                system.debug('Field: ' + field);
                system.debug('Access: ' + access);
                throw new System.NoAccessException();
            }
        }
        return access;
    }

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

        public Location(String strt, String cit, String stat, String pc, String ctry){
            Street = strt;
            City = cit;
            State = stat;
            PostalCode = pc;
            Country = ctry;
        }
    }
}