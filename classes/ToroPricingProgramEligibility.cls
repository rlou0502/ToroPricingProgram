public with sharing class ToroPricingProgramEligibility {
	private static List<Revvy__MnStrategy1__c> retrieveChartStatePricingProgramsForDistributor(Id distributor) {
		system.debug(logginglevel.info, ' retrieveChartStatePricingProgramsForDistributor= ' + distributor);
		List<Revvy__MnStrategy1__c> result = new List<Revvy__MnStrategy1__c>();
		List<Revvy__MnStrategy3__c> programs = [Select PricingProgram__r.IsTaxSupported__c, PricingProgram__r.IsFirstTee__c, 
													PricingProgram__r.MinimumTractionUnits__c, PricingProgram__r.OverriddenPriceList__c, 
													PricingProgram__r.AllowSupportPlus__c, PricingProgram__r.PricingProgramStyle__c, 
													PricingProgram__r.PricingProgramType__c, PricingProgram__r.ExternalId__c, PricingProgram__r.Name,
													PricingProgram__r.Exclude__c, PricingProgram__r.ApplicableProducts__c, PricingProgram__c
													From Revvy__MnStrategy3__c where Distributor__c = :distributor and PricingProgram__r.IsFirstTee__c = FALSE and PricingProgram__r.CORPORATE_ACCOUNT__C=null];
		system.debug(logginglevel.info, ' programs size= ' + programs.size());
		for(Revvy__MnStrategy3__c e : programs) {
			result.add(new Revvy__MnStrategy1__c(Id=e.PricingProgram__c, Name=e.PricingProgram__r.Name,IsTaxSupported__c = e.PricingProgram__r.IsTaxSupported__c,
													IsFirstTee__c = e.PricingProgram__r.IsFirstTee__c,MinimumTractionUnits__c = e.PricingProgram__r.MinimumTractionUnits__c,
													OverriddenPriceList__c = e.PricingProgram__r.OverriddenPriceList__c,AllowSupportPlus__c = e.PricingProgram__r.AllowSupportPlus__c,
													PricingProgramStyle__c = e.PricingProgram__r.PricingProgramStyle__c,ExternalId__c = e.PricingProgram__r.ExternalId__c,
													Exclude__c = e.PricingProgram__r.Exclude__c));		
		}
		system.debug(logginglevel.info, ' result size= ' + result.size());
		return result;
														
	}
	private static List<Revvy__MnStrategy1__c> retrieveOtherProgramsForCustomerAccount(Account customer, List<Revvy__MnStrategy1__c> pricingPrograms) {
		system.debug(logginglevel.info, 'retrieveOtherProgramsForCustomerAccount ');
		List<Revvy__MnStrategy1__c> result = pricingPrograms;
		Id customerId = customer.Id;
		List<Revvy__MnStrategy1__c> corporateAccountPP = [select Id, Name, IsTaxSupported__c, IsFirstTee__c, MinimumTractionUnits__c,OverriddenPriceList__c, AllowSupportPlus__c, PricingProgramStyle__c, ExternalId__c, Exclude__c from Revvy__MnStrategy1__c where Corporate_Account__c in (select CPS_Parent_Account__c from account where id =  :customerId)];
		system.debug(logginglevel.info, 'corporateAccountPP = ' + corporateAccountPP);
		result.addAll(corporateAccountPP);
		
		//add stansdard-alone pricing program
		
		List<Revvy__MnStrategy3__c> programs = [Select PricingProgram__r.IsTaxSupported__c, PricingProgram__r.IsFirstTee__c, 
													PricingProgram__r.MinimumTractionUnits__c, PricingProgram__r.OverriddenPriceList__c, 
													PricingProgram__r.AllowSupportPlus__c, PricingProgram__r.PricingProgramStyle__c, 
													PricingProgram__r.PricingProgramType__c, PricingProgram__r.ExternalId__c, PricingProgram__r.Name,
													PricingProgram__r.Exclude__c, PricingProgram__r.ApplicableProducts__c, PricingProgram__c
													From Revvy__MnStrategy3__c where Distributor__c = :customer.Id and PricingProgram__r.IsFirstTee__c = FALSE];
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
		system.debug(logginglevel.info, 'retrievePricingProgramsForQuote');
		return retrievePricingProgramsForCustomerAccount(quote.REVVY__Account__r);
	}  
	public static List<ToroSelectOption> retrievePricingProgramOptions(Id quoteId) {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		system.debug(logginglevel.info, 'retrievePricingProgramOptions');
		List<Revvy__MnStrategy1__c> ppList = retrievePricingProgramsForQuote(quoteId);
		
		for(Revvy__MnStrategy1__c pp : ppList) {
	        //ret.add(new ToroSelectOption(pp.name, pp.name));
	        system.debug(logginglevel.info, 'retrievePricingProgramOptions ' + pp.ExternalId__c + ' ' + pp.PricingProgramStyle__c + ' ' + pp.name);
	        ret.add(new ToroSelectOption(pp.ExternalId__c+ ';' + pp.PricingProgramStyle__c, pp.name));
        }
		return ret;
	}  
}