@isTest
private class TestProductTableController {

	static final Integer PERIOD_CONST = 15;

    @testSetup static void setup() {
		
		Org_Configuration__c periodTerm = Org_Configuration__c.getInstance();
        periodTerm.Period_Term__c = PERIOD_CONST;
        insert periodTerm;

        Date addedDate = Date.today();

//		Add test products
		List<Product_Table__c> testProduct = TestDataFactory.setupTestData(2);
		insert testProduct;

//		Preparing orders with long description		
		insert new Product_Table__c(Name = 'Long Descr', 
			Product_description__c = '«У меня есть Note 4, у меня Redmi 4. БУМ! Redmi Note 4X». Возможно, именно это мурлыкали себе под нос маркетологи Xiaomi, строя планы по выпуску нового смартфона. Официально Redmi Note 4X был анонсирован в феврале этого года. Заявленная на родине цена — от $144 (за 32 ГБ) до $188 (за 64 ГБ). Однако по дороге к нам устройство подорожало'); 	

//		Preparing orders
		insert new Order_Table__c(Name = 'Test_Order', Product__c = testProduct[0].Id); 	
		insert new Order_Table__c(Name = 'Test_Order3', Product__c = testProduct[0].Id); 
		insert new Order_Table__c(Name = 'Test_Order2', Product__c = testProduct[1].Id); 	

    }
	
	@isTest static void testProductTableController() {

		List<Product_Table__c> testProduct = [
			SELECT Id, Name, Image_Url__c, Product_description__c, Unit_Price__c, Product_Title__c 
			FROM Product_Table__c 
			LIMIT 2
			];

		Map<Id, Integer> orders = new Map<Id, Integer>();
		ProductTableController productController = new ProductTableController();

		for (Product_Table__c testPrd : testProduct) {
			ProductTableController.Wrapper wrapper = new ProductTableController.Wrapper(testPrd, orders);
		}
		
		orders.put(testProduct[0].Id, 1);
		ProductTableController.Wrapper wrapper2 = new ProductTableController.Wrapper(testProduct[0], orders);

		List<ProductTableController.Wrapper> productList = productController.getProductTable();

	}
	

}