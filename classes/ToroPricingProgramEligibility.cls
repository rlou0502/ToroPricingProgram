public with sharing class ToroPricingProgramEligibility implements Cache.CacheBuilder {
	public static final String PricingProgramType_CorporateAccount = 'Corporate Account';
	private static List<Revvy__MnStrategy1__c> retrieveChartStatePricingProgramsForDistributor(Id distributor) {
		system.debug(logginglevel.info, ' retrieveChartStatePricingProgramsForDistributor= ' + distributor);
		List<Revvy__MnStrategy1__c> result = new List<Revvy__MnStrategy1__c>();
		List<Revvy__MnStrategy3__c> programs = [Select PricingProgram__r.IsTaxSupported__c, PricingProgram__r.IsFirstTee__c, 
													PricingProgram__r.MinimumTractionUnits__c, PricingProgram__r.OverriddenPriceList__c, 
													PricingProgram__r.AllowSupportPlus__c, PricingProgram__r.PricingProgramStyle__c, 
													PricingProgram__r.PricingProgramType__c, PricingProgram__r.ExternalId__c, PricingProgram__r.Name,
													PricingProgram__r.Exclude__c, PricingProgram__r.ApplicableProductsLong__c, PricingProgram__c
													From Revvy__MnStrategy3__c where Distributor__c = :distributor and PricingProgram__r.IsFirstTee__c = FALSE and PricingProgram__r.CORPORATE_ACCOUNT__C=null and PricingProgram__r.Status__c = 'Active'];
		system.debug(logginglevel.info, ' programs size= ' + programs.size());
		for(Revvy__MnStrategy3__c e : programs) {
			if(String.isNotBlank(e.PricingProgram__c)) {				
				result.add(new Revvy__MnStrategy1__c(Id=e.PricingProgram__c, Name=e.PricingProgram__r.Name,IsTaxSupported__c = e.PricingProgram__r.IsTaxSupported__c,
													IsFirstTee__c = e.PricingProgram__r.IsFirstTee__c,MinimumTractionUnits__c = e.PricingProgram__r.MinimumTractionUnits__c,
													OverriddenPriceList__c = e.PricingProgram__r.OverriddenPriceList__c,AllowSupportPlus__c = e.PricingProgram__r.AllowSupportPlus__c,
													PricingProgramStyle__c = e.PricingProgram__r.PricingProgramStyle__c,ExternalId__c = e.PricingProgram__r.ExternalId__c,
													Exclude__c = e.PricingProgram__r.Exclude__c));	
			}	
		}
		system.debug(logginglevel.info, ' result size= ' + result.size());
		return result;
														
	}
	private static List<Revvy__MnStrategy1__c> retrieveOtherProgramsForCustomerAccount(Account customer, List<Revvy__MnStrategy1__c> pricingPrograms) {
		system.debug(logginglevel.info, 'retrieveOtherProgramsForCustomerAccount ');
		List<Revvy__MnStrategy1__c> result = pricingPrograms;
		Id customerId = customer.Id;
		List<Revvy__MnStrategy1__c> corporateAccountPP = [select Id, Name, IsTaxSupported__c, IsFirstTee__c, MinimumTractionUnits__c,OverriddenPriceList__c, AllowSupportPlus__c, PricingProgramStyle__c, PricingProgramType__c, ExternalId__c, Exclude__c from Revvy__MnStrategy1__c where Status__c = 'Active' and Corporate_Account__c in (select CPS_Parent_Account__c from account where id =  :customerId)];
		system.debug(logginglevel.info, 'corporateAccountPP = ' + corporateAccountPP);
		result.addAll(corporateAccountPP);
		
		//add stansdard-alone pricing program
		
		List<Revvy__MnStrategy3__c> programs = [Select PricingProgram__r.IsTaxSupported__c, PricingProgram__r.IsFirstTee__c, 
													PricingProgram__r.MinimumTractionUnits__c, PricingProgram__r.OverriddenPriceList__c, 
													PricingProgram__r.AllowSupportPlus__c, PricingProgram__r.PricingProgramStyle__c, 
													PricingProgram__r.PricingProgramType__c, PricingProgram__r.ExternalId__c, PricingProgram__r.Name,
													PricingProgram__r.Exclude__c, PricingProgram__r.ApplicableProductsLong__c, PricingProgram__c
													From Revvy__MnStrategy3__c where Distributor__c = :customer.Id and PricingProgram__r.IsFirstTee__c = FALSE and PricingProgram__r.Status__c = 'Active'];
		system.debug(logginglevel.info, ' programs size= ' + programs.size());
		for(Revvy__MnStrategy3__c e : programs) {
			result.add(new Revvy__MnStrategy1__c(Id=e.PricingProgram__c, Name=e.PricingProgram__r.Name,IsTaxSupported__c = e.PricingProgram__r.IsTaxSupported__c,
													IsFirstTee__c = e.PricingProgram__r.IsFirstTee__c,MinimumTractionUnits__c = e.PricingProgram__r.MinimumTractionUnits__c,
													OverriddenPriceList__c = e.PricingProgram__r.OverriddenPriceList__c,AllowSupportPlus__c = e.PricingProgram__r.AllowSupportPlus__c,
													PricingProgramStyle__c = e.PricingProgram__r.PricingProgramStyle__c,ExternalId__c = e.PricingProgram__r.ExternalId__c,
													Exclude__c = e.PricingProgram__r.Exclude__c));		
		}
		
		List<String> criteria = new List<String>();
		String query = 'select Id, Name, IsTaxSupported__c, IsFirstTee__c, MinimumTractionUnits__c,OverriddenPriceList__c, AllowSupportPlus__c, PricingProgramStyle__c, ExternalId__c, Exclude__c from Revvy__MnStrategy1__c  ';
		if(customer.First_Tee__c) {
			criteria.add(' IsFirstTee__c = true ');
		}
		if(customer.Tax_Supported__c) {
			criteria.add(' IsTaxSupported__c = true ');
		}
		if(criteria.size() == 2) {
			query += ' where ' + criteria[0] + ' or ' + criteria[1];		
		} else if(criteria.size() == 1) {
			query += ' where ' + criteria[0];
		}
		if(criteria.size() >0) {
			List<Revvy__MnStrategy1__c> otherPricingPrograms = Database.query(query);
			if(otherPricingPrograms.size() != 0) {
				result.addAll(otherPricingPrograms);	
			}
		}
		return result;													
	}
	
	public static List<Revvy__MnStrategy1__c> retrievePricingProgramsForCustomerAccountWithId(Id customerId) {
		account customer = [select id, name, Commercial_Distributor__c, First_Tee__c, Tax_Supported__c from account where id = :customerId];
		return retrievePricingProgramsForCustomerAccount(customer);												
	}
	public static List<Revvy__MnStrategy1__c> retrievePricingProgramsForCustomerAccount(Account customer) {
		
		system.debug(logginglevel.info, 'retrievePricingProgramsForCustomerAccount.Commercial_Distributor__c --' + customer.Commercial_Distributor__c);
		List<Revvy__MnStrategy1__c> result = new List<Revvy__MnStrategy1__c>();
		if(customer.Commercial_Distributor__c != null) {
			system.debug(logginglevel.info, 'distributor =' + customer.Commercial_Distributor__c);
			Id disti = customer.Commercial_Distributor__c;
			result = retrieveChartStatePricingProgramsForDistributor(disti);			
		} else {
			Id userId = UserInfo.getUserId();
			system.debug(logginglevel.info, ' user id=' + userId);
			List<User_Distributor__c> distis = [SELECT Id, Name, User_Name__c, Distributor__c, Comm_Dist__c FROM User_Distributor__c where User_Name__c = :userId ];
			system.debug(logginglevel.info, ' disti size= ' + distis.size());
			for(User_Distributor__c disti : distis) {
				result = retrieveChartStatePricingProgramsForDistributor(disti.Distributor__c);
				break;		
			}
		}
		result = retrieveOtherProgramsForCustomerAccount(customer, result);
		
		return result;
														
	}
	public static List<Revvy__MnStrategy1__c> retrievePricingProgramsForQuote(Id quoteId) {
		Revvy__MnQuote__c quote = [select id, REVVY__Account__r.Id, REVVY__Account__r.Commercial_Distributor__c, REVVY__Account__r.First_Tee__c, REVVY__Account__r.Tax_Supported__c from revvy__MnQuote__c where id = :quoteId];
		system.debug(logginglevel.info, 'retrievePricingProgramsForQuote quote account = ' + quote);
		List<Revvy__MnStrategy1__c> result = retrievePricingProgramsForCustomerAccount(quote.REVVY__Account__r);
		Set<String> nonEligiblePricingProgram = retrieveNonEligiblePricingProgramsForQuote(quoteId);
		List<Revvy__MnStrategy1__c> returnPricingPrograms = new List<Revvy__MnStrategy1__c>();
		for(Revvy__MnStrategy1__c pp : result) {
			if(!nonEligiblePricingProgram.contains(pp.ExternalId__c)) {
				returnPricingPrograms.add(pp);	
			}	
		}
		
		return returnPricingPrograms;
	} 
	public static Set<String> retrieveNonEligiblePricingProgramsForQuote(Id quoteId) {
		system.debug(logginglevel.info, 'retrieveNonEligiblePricingProgramsForQuote ');
		Set<String> nonEligiblePricingProgram = new Set<String>();
		List<Revvy__MnStrategy4__c> quoteItems = [Select Product_Id__c from Revvy__MnStrategy4__c where Mn_Quote__c = :quoteId];
		List<String> productIds = new List<String>();
		for (Revvy__MnStrategy4__c quoteItem : quoteItems) {
			productIds.add(quoteItem.Product_Id__c);
		}
		Map<String, Set<String>> ppEligibleProduct = new Map<String, Set<String>>();
		List<REVVY__MnStrategy1__c> pricingPrograms = [SELECT Id, ApplicableProductsLong__c, ExternalId__c, Model_Eligibility__c FROM REVVY__MnStrategy1__c where Product_Eligibility_Checking__c = true and Model_Eligibility__c = 'Rigid'];
		
		boolean found = true;
		for(REVVY__MnStrategy1__c pp : pricingPrograms) {
			//system.debug(logginglevel.info, 'retrieveNonEligiblePricingProgramsForQuote pp=' + pp.Name);
			Set<String> eligibleProducts = new Set<String>();
			if(String.isNotBlank(pp.ApplicableProductsLong__c) &&  pp.ApplicableProductsLong__c != 'All') {
				eligibleProducts.addAll(pp.ApplicableProductsLong__c.split(','));
			}
			for(String p : productIds) {
				if(!eligibleProducts.contains(p)) {
					found = false;	
					nonEligiblePricingProgram.add(pp.ExternalId__c);	
					break;
				}	
			}
		}
		system.debug(logginglevel.info, 'retrieveNonEligiblePricingProgramsForQuote nonEligiblePricingProgram=' + nonEligiblePricingProgram);
		return nonEligiblePricingProgram;
	}  
	public static List<ToroSelectOption> retrievePricingProgramOptions(Id quoteId) {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		system.debug(logginglevel.info, 'retrievePricingProgramOptions');
		List<Revvy__MnStrategy1__c> ppList = retrievePricingProgramsForQuote(quoteId);
		Set<Revvy__MnStrategy1__c> uniquePP = new Set<Revvy__MnStrategy1__c>(ppList);
		for(Revvy__MnStrategy1__c pp : uniquePP) {
	        //ret.add(new ToroSelectOption(pp.name, pp.name));
	        if(String.isNotBlank(pp.name)) {
	        	system.debug(logginglevel.info, 'retrievePricingProgramOptions ' + pp.ExternalId__c + ' ' + pp.PricingProgramStyle__c + ' ' + pp.name + ' pp.PricingProgramType__c=' + pp.PricingProgramType__c);
	        	ret.add(new ToroSelectOption(pp.ExternalId__c+ ';' + pp.PricingProgramStyle__c, pp.name , pp.PricingProgramType__c == PricingProgramType_CorporateAccount));
	        }else {
	        	system.debug(logginglevel.info, 'retrievePricingProgramOptions  null------' + pp);	
	        }
        }
        ret.sort();
		return ret;
	}  
	public Object doLoad(String quoteId) {        	 
    	List<ToroSelectOption> pricingProgramOptions = ToroPricingProgramEligibility.retrievePricingProgramOptions(quoteId);  
    	return pricingProgramOptions;  
    }     
}