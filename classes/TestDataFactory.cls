@isTest
public with sharing class TestDataFactory {
	public static List<Product_Table__c> setupTestData(Integer count) {
    	
    	Org_Configuration__c periodTerm = Org_Configuration__c.getInstance();
    	periodTerm.Period_Term__c = 15;

		List<Product_Table__c> demoListPoduct = new List<Product_Table__c>();

		for (Integer i = 0; i < count; i++) {
			demoListPoduct.add(new Product_Table__c(Name = 'New Product ' + i));
		}

		return demoListPoduct;

	}
}