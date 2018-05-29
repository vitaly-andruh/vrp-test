/**
 * ProductDetailController
 *
 * <P>Custom APEX controller for VF Page
 *
 * <P>Manipulate with Product_Table__c 
 *
 * @author Vitaly Andruh
 * @version 1.0
 */
public class ProductDetailController {

/**
*	Constructor
*/   
	public productDetailController() {
		getDetailData();
	}

/**
*	Getting data of current product
*/
	public Product_Table__c getDetailData() {
		Product_Table__c detailData = null;
		try {
			Id curId = Id.valueOf(String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id')));
			detailData = [
				SELECT Id, Name, Image_Url__c, Product_description__c, Unit_Price__c, Product_Title__c, Units_Available__c
				FROM Product_Table__c
				WHERE Id = :curId
			];
		} catch (Exception e){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'This Product not found'));
		}
   		return detailData;
	}

/**
*	Set error variable
*/
	public Boolean getIsError() {

		if (ApexPages.hasMessages()) {
			return true;
		} else {
			return false;
		}

	}



}