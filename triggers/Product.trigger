/**
 * Before insertion trigger
 *
 * <P>Automatic selecting or create new Warehouse for
 * Product table Item
 *
 * See {@link CreateProductHandler Class} for more information.
 *
 * @author Vitaly Andruh
 * @version 1.0
 */

trigger Product on Product_Table__c (before insert) {

	ProductHandler.attributionToWarehouse(Trigger.new);

}