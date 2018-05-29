/**
 * ProductDetailController
 *
 * <P>Custom APEX controller for VF Page
 *
 * <P>Get data from Product_Table__c and Order_Table__c
 *
 * @author Vitaly Andruh
 * @version 1.0
 */
public with sharing class ProductTableController {

    public List<Product_Table__c> productsTable { get; set; }
    public List<Wrapper> wrapTable { get; set; }

//  Lenght of short description
    public static final Integer DESCR_LENGTH = 100;
//  Maximum rows 
    public static final Integer MAX_ROWS = 50;

    public productTableController() {

    }

/**
*   Getting data of product list
*/
    public List<Wrapper> getProductTable() {

        Set<Id> productIds = new Set<Id>();
        Map<Id, Integer> ordersCount = new Map<Id, Integer>(); 
        Integer curCount;

        productsTable = [
        	SELECT Id, Name, Image_Url__c, Product_description__c, Unit_Price__c, Product_Title__c
        	FROM Product_Table__c
        	LIMIT :MAX_ROWS
        ];

        for (Product_Table__c  prdT: productsTable) {
            productIds.add(prdT.Id);
        }

        List<Order_Table__c> orders = [
            SELECT Id, Product__c
            FROM Order_Table__c
            WHERE Product__c IN :productIds
        ];

        for (Order_Table__c order : orders) {
            if (ordersCount.get(order.Product__c) != null) {
                curCount = ordersCount.get(order.Product__c)+1;
                ordersCount.put(order.Product__c, curCount);
            } else {
                ordersCount.put(order.Product__c, 1);
            }
        }

        for (Product_Table__c tbl : productsTable) {
        	if(wrapTable == null) {
            	wrapTable = new List<Wrapper>();
            }
			wrapTable.add(new Wrapper(tbl, ordersCount));
        }

        return wrapTable;
    }

/**
*   Wraper Class for product list
*/
    public class Wrapper {

        public Id id { get; set; }
        public String name { get; set; }
        public String imageUrl { get; set; }
        public String unitPrice { get; set; }       
        public String productTitle { get; set; }
        public String productDescription { get; set; }
        public String productDescriptionShort { get; set; }
        public Integer ordersCount { get; set; }
        public Integer descrLimit { get; set; }

        public wrapper(Product_Table__c prd, Map<Id, Integer> orders) {

			this.id = prd.id;
            this.name = prd.Name;
        	this.imageUrl = prd.Image_Url__c;
        	this.unitPrice = '$ ' + (Integer)prd.Unit_Price__c; 
            this.productDescription = prd.Product_description__c;  
        	this.productTitle = prd.Product_Title__c;
            this.ordersCount = 0;
            this.descrLimit = DESCR_LENGTH;

//          Adding orders to product 
            if (orders.get(prd.id) != null) {
                this.ordersCount = orders.get(prd.id);
            }

            if (prd.Product_description__c != null && prd.Product_description__c.length() > DESCR_LENGTH) {
                this.productDescriptionShort = prd.Product_description__c.substring(0, DESCR_LENGTH) + '...';
            } else {
                this.productDescriptionShort = prd.Product_description__c;
            }
        
        }
    }

}