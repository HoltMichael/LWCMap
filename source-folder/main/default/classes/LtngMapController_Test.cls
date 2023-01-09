@isTest
public with sharing class LtngMapController_Test {
    @TestSetup
    static void makeData(){
        Account acc = new Account(name='My Account', billingStreet='Billing Street', billingCity='Billing City', billingState='billingState', billingCountry='billing Country',billingPostalCode='Billing Postal Code');
        insert acc;
        Contact cont = new Contact(accountid = acc.id, firstName='My Contact', lastName='My Contact', mailingStreet='mailing Street', mailingCity='mailing City', mailingState='mailingState', mailingCountry='mailingCountry',mailingPostalCode='Mailing Postal Code');
        insert cont;
    }

    /*
        getAddress_Error
        Tests the creation of an error if the address details don't work
    */
    @isTest
    static void getAddress_Error(){
        Contact cont = [SELECT firstname, lastName, mailingStreet, mailingCity ,mailingState ,mailingCountry,mailingPostalCode FROM Contact][0];

        test.startTest();
            List<LtngMapController.MapMarker> mapMarkers1 = LtngMapController.getAddress(cont.id, 'abc', 'def', 'hij', 'klm', 'nop', 'qrs', 'tuv', '');   
        test.stopTest();

        ltngMap__Map_Error__c mapError = [SELECT id, ltngMap__Record_ID__c, 
            ltngMap__Mapping_Query__c, 
            ltngMap__Inaccessible_Fields__c,
            ltngMap__Exception_Type__c,
            ltngMap__Exception_Message__c FROM ltngMap__Map_Error__c][0];

        system.assert(mapError.ltngMap__Mapping_Query__c.contains('abc'));
        system.assert(mapError.ltngMap__Mapping_Query__c.contains('def'));
        system.assert(mapError.ltngMap__Mapping_Query__c.contains('hij'));
        system.assert(mapError.ltngMap__Exception_Type__c.contains('System.NullPointerException'));
        system.assert(mapError.ltngMap__Exception_Type__c.contains('System.QueryException'));
        system.assert(mapError.ltngMap__Exception_Message__c.contains('Attempt to de-reference a null object'));
        system.assert(mapError.ltngMap__Exception_Message__c.contains('No such column'));

        //Re-create the exact same error immediately after, it should not create a second identical error message
        List<LtngMapController.MapMarker> mapMarkers2 = LtngMapController.getAddress(cont.id, 'abc', 'def', 'hij', 'klm', 'nop', 'qrs', 'tuv', 'wxy');         
        List<ltngMap__Map_Error__c> mapErrors = [SELECT id, ltngMap__Record_ID__c, 
            ltngMap__Mapping_Query__c, 
            ltngMap__Inaccessible_Fields__c,
            ltngMap__Exception_Type__c,
            ltngMap__Exception_Message__c FROM ltngMap__Map_Error__c];
        system.assertEquals(mapErrors.size(),1);
    }

    /*
        getAddress_Contact
        Tests that the method works when Contact details are passed in
    */
    @isTest
    static void getAddress_Contact(){
        Contact cont = [SELECT firstname, lastName, mailingStreet, mailingCity ,mailingState ,mailingCountry,mailingPostalCode FROM Contact][0];
        test.startTest();
            List<LtngMapController.MapMarker> mapMarkers = LtngMapController.getAddress(cont.id, 'mailingStreet', 'mailingCity', 'mailingState', 'mailingCountry', 'mailingPostalCode', 'FirstName', 'LastName', '');         
        test.stopTest();

        system.assertEquals(mapMarkers.size(),1);
        LtngMapController.MapMarker mapper = mapMarkers[0]; 
        system.assertEquals(mapper.icon, 'icon');
        system.assertEquals(mapper.title, cont.FirstName);
        system.assertEquals(mapper.description, cont.LastName);

        LtngMapController.Location loc = mapper.Location;
        system.assertEquals(loc.Street, cont.mailingStreet);
        system.assertEquals(loc.City, cont.mailingCity);
        system.assertEquals(loc.State, cont.mailingState);
        system.assertEquals(loc.Country, cont.mailingCountry);
        system.assertEquals(loc.PostalCode, cont.mailingPostalCode);
    }


    /*
        getAddress_Account
        Tests that the method works when Account details are passed in
    */
    @isTest
    static void getAddress_Account(){
        Account acc = [SELECT name, description, billingStreet, billingCity, billingState, billingCountry,billingPostalCode FROM Account][0];

        test.startTest();
            List<LtngMapController.MapMarker> mapMarkers = LtngMapController.getAddress(acc.id, 'billingStreet', 'billingCity', 'billingState', 'billingCountry', 'billingPostalCode', 'Name', 'description', '');
        test.stopTest();

        system.assertEquals(mapMarkers.size(),1);
        LtngMapController.MapMarker mapper = mapMarkers[0]; 
        system.assertEquals(mapper.icon, 'icon');
        system.assertEquals(mapper.title, acc.name);
        system.assertEquals(mapper.description, acc.description);

        LtngMapController.Location loc = mapper.Location;
        system.assertEquals(loc.Street, acc.billingStreet);
        system.assertEquals(loc.City, acc.billingCity);
        system.assertEquals(loc.State, acc.billingState);
        system.assertEquals(loc.Country, acc.billingCountry);
        system.assertEquals(loc.PostalCode, acc.billingPostalCode);
    }
}
