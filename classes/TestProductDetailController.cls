@isTest
private class TestProductDetailController {

	static final Integer PERIOD_CONST = 15;

    @testSetup static void setup() {
		
		Org_Configuration__c periodTerm = Org_Configuration__c.getInstance();
        periodTerm.Period_Term__c = PERIOD_CONST;
        insert periodTerm;

		List<Product_Table__c> testProduct = TestDataFactory.setupTestData(1);
		insert testProduct;
	}

	@isTest static void testProductDetailController() {
		
		Product_Table__c myPrd = [SELECT Id FROM Product_Table__c LIMIT 1];
		ApexPages.currentPage().getParameters().put('id', myPrd.id);
		ApexPages.currentPage().setRedirect(true);
		ProductDetailController detailControllerWP = new ProductDetailController();
		detailControllerWP.getIsError();	
		
		ApexPages.currentPage().setRedirect(true);
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'TestError'));
		ApexPages.currentPage().getParameters().put('id', '');
		ProductDetailController detailController = new ProductDetailController();	
		detailControllerWP.getIsError();	

	}
	
}