/**
 * CreateProductHandler Class
 *
 * <P>Realese logic on Product_Table__c insertion
 * 
 * <P>When Warehouse.Period Start <= Product Table.Added Date and 
 * Warehouse.Period End <= Product Table.Added Date  at least return
 * one Warehouse -  return the first Warehouse from list. 
 * Else create and return new Warehouse.
 *
 * @author Vitaly Andruh
 * @version 1.0
 */

public class ProductHandler {
    public static void attributionToWarehouse(List<Product_Table__c> newProducts) {

//      Get config variable of period from settings
        Org_Configuration__c periodTerm = Org_Configuration__c.getInstance();
        Integer addDays = (Integer)periodTerm.Period_Term__c;
        
        Warehouse__c newWarehouse = new Warehouse__c();
        List<Warehouse__c> warehouses = new List<Warehouse__c>();
        List<Warehouse__c> newWarehouses = new List<Warehouse__c>();
        List<Warehouse__c> uniqueWarehouses = new List<Warehouse__c>();
        Set<Warehouse__c> uniqueWarehousesSet = new Set<Warehouse__c>(); 

        Date min;
        Date max;

        for (Product_Table__c prdDates : newProducts) {

            if (prdDates.Added_Date__c > max || max == null) {
                max = prdDates.Added_Date__c;
            }

            if (prdDates.Added_Date__c < min || min == null) {
                min = prdDates.Added_Date__c;
            }
        
        }

        if (min <> null && max <> null) {
            String wareSOQL = 'SELECT Id, Name, Period_Start__c, Period_End__c FROM Warehouse__c WHERE Period_Start__c >= ' + string.valueOf(min) + ' AND Period_End__c <= ' + string.valueOf(max.addDays(addDays));
            warehouses = Database.query(wareSOQL);
        } else {
            warehouses = [
                SELECT Id, Name, Period_Start__c, Period_End__c
                FROM Warehouse__c
                LIMIT 100
                ];            
        }

        for (Product_Table__c prd : newProducts) {

//          Rerlacing exist data in field
            prd.Warehouse__c = null;

//          When date is null - setting today
            if (prd.Added_Date__c == null) {
                prd.Added_Date__c = Date.today();
            }

            attachWarehouse(warehouses, prd);
            
            if (prd.Warehouse__c == null) {

                newWarehouse = new Warehouse__c(
                    Name = ('Warehouse ' + prd.Added_Date__c.format() + ' ' + prd.Added_Date__c.addDays(addDays).format()),
                    Period_Start__c = prd.Added_Date__c,
                    Period_End__c = prd.Added_Date__c.addDays(addDays)
                );
                    
                newWarehouses.add(newWarehouse);
            }
        }

        if (newWarehouses.size() > 0) {
//          Create uniqie List by converting List -> Set -> List
            uniqueWarehousesSet.addAll(newWarehouses);
            uniqueWarehouses.addAll(uniqueWarehousesSet);
            insert uniqueWarehouses;
        }

        for (Product_Table__c prd : newProducts) {
            attachWarehouse(uniqueWarehouses, prd);
        }

    }

//  Attach warehouse to product
    private static void attachWarehouse(List<Warehouse__c> warehouses, Product_Table__c prd) {
        if (warehouses != null) {
            for (Warehouse__c ware: warehouses) {
                if (ware.Period_Start__c <= prd.Added_Date__c && ware.Period_End__c >= prd.Added_Date__c) {
                    prd.Warehouse__c = ware.id;
                } 
            }
        } 
    }

}