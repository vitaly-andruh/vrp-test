@isTest
private class TestProduct {

static final Integer PERIOD_CONST = 15;

    @testSetup static void setup() {

        Org_Configuration__c periodTerm = Org_Configuration__c.getInstance();
        periodTerm.Period_Term__c = PERIOD_CONST;
        insert periodTerm;

        Date addedDate = Date.today();

        Warehouse__c newWarehouse = new Warehouse__c(
            Name = 'Warehouse',
            Period_Start__c = addedDate,
            Period_End__c = addedDate.addDays(PERIOD_CONST)
        );
        
        insert newWarehouse;

    }

    @isTest static void testAdd200Products() {
        
        List<Product_Table__c> productTables = TestDataFactory.setupTestData(200);

        List<Database.SaveResult> result = Database.insert(productTables, false);

        System.assert(result[0].isSuccess());

    }

    @isTest static void testWarehouses() {

        Org_Configuration__c periodTerm = Org_Configuration__c.getInstance();
        Integer periodInt = (Integer)periodTerm.Period_Term__c;

        Date addedDate = Date.today();
        Product_Table__c productTable = new Product_Table__c(Name = 'New Product', Added_Date__c = addedDate);


        Database.SaveResult result = Database.insert(productTable, false);
                
        System.assert(result.isSuccess());


        List<Product_Table__c> productTableList = new List<Product_Table__c>();

            productTableList.add(new Product_Table__c(
                Name = 'For Existing Warehouse + half-period', 
                Added_Date__c = addedDate.addDays(Math.mod(periodInt, 2))
                ));

            productTableList.add(new Product_Table__c(
                Name = 'For Existing Warehouse + period', 
                Added_Date__c = addedDate.addDays(periodInt)
                ));

            productTableList.add(new Product_Table__c(
                Name = 'For Non-Existing Warehouse -period*2', 
                Added_Date__c = addedDate.addDays(-(periodInt*2))
                ));

            productTableList.add(new Product_Table__c(
                Name = 'For Non-Existing Warehouse +period*2', 
                Added_Date__c = addedDate.addDays(periodInt*2)
                ));


        List<Database.SaveResult> resultList = Database.insert(productTableList, false);
        
//      Assert full request
        System.assert(resultList[0].isSuccess());

//      Assert trigger for Existing Warehouse + half-period
        Product_Table__c testProduct = [SELECT Id, Warehouse__c 
            FROM Product_Table__c
            WHERE Id = :productTableList[0].Id
            ];          

        Warehouse__c testWarehouse = [SELECT Id 
            FROM Warehouse__c
            WHERE Name = 'Warehouse'
            ];

        System.assertEquals(testProduct.Warehouse__c, testWarehouse.id);    

//      Assert trigger for Existing Warehouse + period
        Product_Table__c testProduct1 = [SELECT Id, Warehouse__c 
            FROM Product_Table__c
            WHERE Id = :productTableList[1].Id
            ];          

        Warehouse__c testWarehouse1 = [SELECT Id 
            FROM Warehouse__c
            WHERE Name = 'Warehouse'
            ];

        System.assertEquals(testProduct1.Warehouse__c, testWarehouse1.id);  


//      Assert trigger for New Warehouse -period x 2
        Product_Table__c testProduct2 = [SELECT Id, Warehouse__c 
            FROM Product_Table__c
            WHERE Id = :productTableList[2].Id
            ];          

        String nameOfWarehouse = 'Warehouse ' + addedDate.addDays(-(periodInt*2)).format() + ' ' + addedDate.addDays(-periodInt).format(); 

        Warehouse__c testWarehouse2 = [SELECT Id 
            FROM Warehouse__c
            WHERE Name = :nameOfWarehouse
            ];

        System.assertEquals(testProduct2.Warehouse__c, testWarehouse2.id);  

//      Assert trigger for New Warehouse +period x 2
        Product_Table__c testProduct3 = [SELECT Id, Warehouse__c 
            FROM Product_Table__c
            WHERE Id = :productTableList[3].Id
            ];          

        String nameOfWarehouse3 = 'Warehouse ' + addedDate.addDays(periodInt*2).format() + ' ' + addedDate.addDays(periodInt*3).format();   

        Warehouse__c testWarehouse3 = [SELECT Id 
            FROM Warehouse__c
            WHERE Name = :nameOfWarehouse3
            ];

        System.assertEquals(testProduct3.Warehouse__c, testWarehouse3.id);  
    
    }   
    
}