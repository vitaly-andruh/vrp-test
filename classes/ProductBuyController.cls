/**
 * ProductBuyController
 *
 * <P>Custom APEX controller for VF Page
 *
 * <P>Manipulate with sObjects Product_Table__c, Order_Table__c, Contact 
 *
 * @author Vitaly Andruh
 * @version 1.0
 */
public class ProductBuyController {

	public String contactEmail { get; set; }
	public String contactFirstName { get; set; }
	public String contactLastName { get; set; }
	public Integer contactCount { get; set; }
    public Id productId;
    public Integer productAmount;
    public Integer productPrice;
    public Boolean error { get; set; }
    public Boolean success { get; set; }
    public String productName;
    public Product_Table__c detailData;

/**
*	Constructor
*/
	public productBuyController() {		
		success = false;
		error = false;
	}

/**
*	Main method
*/ 
	public void buyProduct() {

		if (!String.isEmpty(Apexpages.currentPage().getParameters().get('pCount')) && 
			!String.isEmpty(Apexpages.currentPage().getParameters().get('pEmail'))) {
		
			initInput();
			
			if (productAmount < contactCount) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 
					'Sorry, we don`t have so much units of this product! Max available: ' + productAmount));
			} else if (contactCount < 1) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 
					'Unit count must be greather than 0!'));	
			} else {
				createNewOrder();
			}

		} else {

			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 
				'Empty count or email value!'));
		}

	initMessages();
	}

/**
*	Get current product data
*/
	public Product_Table__c getCurProduct() {

		detailData = null;

		try {

			Id curId = Id.valueOf(String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id')));
			detailData = [
				SELECT Id, Name, Image_Url__c, Product_description__c, Unit_Price__c, Product_Title__c, Units_Available__c
				FROM Product_Table__c
				WHERE Id = :curId
			];

		} catch (Exception e) {

			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'This Product not found'));
			return detailData;		
		}
		
		return detailData;
	}

/**
*	Get product price and convert to integer
*/
	public Integer getIntPrice() {
		Product_Table__c data = getCurProduct();
		return Integer.valueof(data.Unit_Price__c);
	}

/**
*	Create or update user method
*/
	public Id createUpdateUser() {

		if (contactEmail != '') {
			
			List<Contact> cnt = [
				SELECT Id, Email, FirstName, LastName
				FROM Contact
				WHERE Email = :contactEmail
				];
		
			if (!cnt.isEmpty()) {

				if (cnt[0].FirstName != contactFirstName && !String.isEmpty(contactFirstName)) cnt[0].FirstName = contactFirstName;
				if (cnt[0].LastName != contactLastName && !String.isEmpty(contactLastName)) cnt[0].LastName = contactLastName;
				
				contactFirstName = cnt[0].FirstName;
				contactLastName = cnt[0].LastName;

				update cnt;
				return cnt[0].Id;

			} else {
				
				if (String.isEmpty(contactFirstName) && String.isEmpty(contactLastName)) {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 
						'This user not exist. First Name and Last Name are required!'));
					return null;
				}

				Contact newUser = new Contact(
					FirstName = contactFirstName, 
					LastName = contactLastName, 
					Email = contactEmail
					);
				
				try {
					insert newUser;
				} catch (Exception e) {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 
						'Invalid email adress! Please, try again!'));
					return null;
				}

				return newUser.Id;
			}
		} 
		return null;
	}

/**
*	Create new order
*/
	public void createNewOrder() {

		Id newId = createUpdateUser();	

		if (newId != null) {
			Order_Table__c newOrder = new Order_Table__c(
				Product__c = productId,
				Units__c = contactCount,
				Order_Amount__c = productPrice * contactCount,
				Contact__c = newId,
				Name = 'Order by ' + contactEmail + ' - ' + Datetime.now()
				);

			insert newOrder;
			updateProductAmount();
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info, 
				'Your order was created successful!'));			
		}
	}

/**
*	Initialize state of messages (success or error)
*/
	public void initMessages() {

		if (ApexPages.hasMessages(ApexPages.Severity.Error)) {
			success = false;
			error = true;
		}

		if (ApexPages.hasMessages(ApexPages.Severity.Info)) {
			error = false;
			success = true;
		}
	}

/**
*	Get inputs data from VF page 
*/
	public void initInput() {
		contactEmail = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('pEmail'));	        
		contactFirstName = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('pFirstName'));
		contactLastName = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('pLastName'));
		contactCount = Integer.valueOf(Apexpages.currentPage().getParameters().get('pCount'));				
		productId = Id.valueOf(Apexpages.currentPage().getParameters().get('pProductId'));
		productName = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('pProductName'));
		productAmount = Integer.valueOf(Apexpages.currentPage().getParameters().get('pProductAmount'));
		productPrice = Integer.valueOf(Apexpages.currentPage().getParameters().get('pUnitPrice'));
	}

/**
*	Update product amount
*/
	public void updateProductAmount() {
		detailData.Units_Available__c = detailData.Units_Available__c - contactCount;
		update detailData;
	}
}