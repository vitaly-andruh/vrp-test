@isTest
private class TestProductBuyController {
	
	static final Integer PERIOD_CONST = 15;

    @testSetup static void setup() {
		
		Org_Configuration__c periodTerm = Org_Configuration__c.getInstance();
        periodTerm.Period_Term__c = PERIOD_CONST;
        insert periodTerm;

		List<Product_Table__c> testProduct = TestDataFactory.setupTestData(1);
		insert testProduct;




	}


	@isTest static void testProductBuyController() {

//		Create ProductBuyController Instance
		ProductBuyController prdCtrl = new ProductBuyController();

//		Construct Class without parameters must set error message and return null
		System.assertEquals(prdCtrl.getCurProduct(), null);
		System.assert(ApexPages.hasMessages(ApexPages.Severity.Error));

//		Set product Id in page
		Product_Table__c myPrd = [SELECT Id, Name, Units_Available__c, Unit_Price__c FROM Product_Table__c LIMIT 1];
		ApexPages.currentPage().getParameters().put('id', myPrd.id);

//		Construct Class with Id parameter	

		ProductBuyController prdCtrl2 = new ProductBuyController();
		ApexPages.currentPage().setRedirect(true);
		Product_Table__c myCurPrd = prdCtrl2.getCurProduct();

//		Construct Class without parameters must return Product_Table__c		
		System.assert(myCurPrd.Name != null);

//		Test method to get integer value of price. Must return Integer value;	
		Integer price = prdCtrl2.getIntPrice();
		System.assertEquals(Integer.valueOf(myCurPrd.Unit_Price__c), price);

//		Run method to buy product without parameters
		prdCtrl2.buyProduct();
//		Must set error variable to true
		System.assert(prdCtrl2.error);

//		Run method to buy product with count parameter
		ApexPages.currentPage().getParameters().put('pCount', '1');
		prdCtrl2.buyProduct();
//		Must set error variable to true
		System.assert(prdCtrl2.error);

		Apexpages.currentPage().getParameters().put('pEmail','');	        
		Apexpages.currentPage().getParameters().put('pFirstName','');
		Apexpages.currentPage().getParameters().put('pLastName','');
		Apexpages.currentPage().getParameters().put('pCount','');				
		Apexpages.currentPage().getParameters().put('pProductId', myPrd.Id);
		Apexpages.currentPage().getParameters().put('pProductName', myPrd.Name);
		Apexpages.currentPage().getParameters().put('pProductAmount', String.valueOf(myPrd.Units_Available__c));
		Apexpages.currentPage().getParameters().put('pUnitPrice', String.valueOf(myPrd.Unit_Price__c));

//		myPrd.Units_Available__c = 1 --- must set error
		ApexPages.currentPage().getParameters().put('pCount', '2');
		ApexPages.currentPage().getParameters().put('pEmail', 'test@myemail.com');
		prdCtrl2.buyProduct();
// 		Must set error variable to true
		System.assert(prdCtrl2.error);

//		Count required greather that 0 --- must set error
		ApexPages.currentPage().getParameters().put('pCount', '0');
		ApexPages.currentPage().getParameters().put('pEmail', 'test@myemail.com');
		prdCtrl2.buyProduct();
		System.assert(prdCtrl2.error);

//		Missing user data --- must set error
		ApexPages.currentPage().getParameters().put('pCount', '1');
		ApexPages.currentPage().getParameters().put('pEmail', 'test@myemail.com');
		prdCtrl2.buyProduct();
		System.assert(prdCtrl2.error);

//		Must create user and order
		ApexPages.currentPage().getParameters().put('pCount', '1');
		ApexPages.currentPage().getParameters().put('pEmail', 'test@smyemail.com');
		Apexpages.currentPage().getParameters().put('pFirstName', 'TestFirstName');
		Apexpages.currentPage().getParameters().put('pLastName', 'TestLastName');
		prdCtrl2.buyProduct();
		System.assert(!prdCtrl2.error);
		List<Order_Table__c> orders = [SELECT Product__c FROM Order_Table__c WHERE Product__c = :myPrd.Id];
		
//		Wrong email. Must set error
		ApexPages.currentPage().setRedirect(true);
		ApexPages.currentPage().getParameters().put('pCount', '1');
		ApexPages.currentPage().getParameters().put('pEmail', 'testmyemail');
		Apexpages.currentPage().getParameters().put('pFirstName', 'TestFirstName');
		Apexpages.currentPage().getParameters().put('pLastName', 'TestLastName');
		prdCtrl2.buyProduct();

		prdCtrl2.contactEmail = '';
		prdCtrl2.createUpdateUser();

		Contact newUser = [SELECT FirstName, LastName, Email FROM Contact WHERE Email = 'test@smyemail.com'];
		System.assertEquals(newUser.FirstName, 'TestFirstName');
		System.assertEquals(newUser.LastName, 'TestLastName');

		Order_Table__c order = [SELECT Product__c FROM Order_Table__c WHERE Product__c = :myPrd.Id];
		System.assertEquals(order.Product__c, myPrd.Id);
		
		orders = [SELECT Product__c FROM Order_Table__c WHERE Product__c = :myPrd.Id];
		myPrd = [SELECT Id, Name, Units_Available__c, Unit_Price__c FROM Product_Table__c LIMIT 1];
		ApexPages.currentPage().getParameters().put('pCount', '1');
		ApexPages.currentPage().getParameters().put('pEmail', 'test@myemail.com');
		Apexpages.currentPage().getParameters().put('pFirstName', '');
		Apexpages.currentPage().getParameters().put('pLastName', '');
		Apexpages.currentPage().getParameters().put('pProductAmount', String.valueOf(myPrd.Units_Available__c));
		prdCtrl2.buyProduct();
		System.assert(!prdCtrl2.error);
		
		orders = [SELECT Product__c FROM Order_Table__c WHERE Product__c = :myPrd.Id];
		myPrd = [SELECT Id, Name, Units_Available__c, Unit_Price__c FROM Product_Table__c LIMIT 1];
		ApexPages.currentPage().setRedirect(true);
		ApexPages.currentPage().getParameters().put('pCount', '1');
		Apexpages.currentPage().getParameters().put('pProductAmount', String.valueOf(myPrd.Units_Available__c));
		ApexPages.currentPage().getParameters().put('pEmail', 'test@myemail.com');
		Apexpages.currentPage().getParameters().put('pFirstName', '');
		Apexpages.currentPage().getParameters().put('pLastName', '');
		prdCtrl2.buyProduct();
		System.assertEquals(orders.size(), 1);


		System.assert(!prdCtrl2.error);
		ApexPages.currentPage().setRedirect(true);

	}
	
	
}