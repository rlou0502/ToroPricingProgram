public with sharing class ToroPricingMethodData {
	public decimal percentOfMSRP {get; set;}
	public decimal percentOfDNet {get; set;}
	public decimal rebatePercent {get; set;}
	public decimal grossProfitPercent {get; set;}  
	public decimal awardPrice {get; set;}
	public decimal grossProfit {get; set;}  
	public decimal dnet { get; set; }
	public decimal msrp { get; set; }
	public ToroPricingMethodData(decimal percentOfMSRP, decimal percentOfDNet, decimal rebatePercent, decimal grossProfitPercent, decimal dnet) {
		this.percentOfMSRP = percentOfMSRP;
		this.percentOfDNet = percentOfDNet;
		this.rebatePercent = rebatePercent;
		this.grossProfitPercent = grossProfitPercent;
		if(percentOfDNet != null && dnet != null) {
			this.awardPrice = dnet * percentOfDNet/100;
		}
		if(dnet != null) {
			decimal rebate = dnet * rebatePercent/100;
			this.grossProfit = dnet * percentOfDNet/100 - dnet + rebate;
		}	
	}
	
	
	public ToroPricingMethodData() {
		
	}
	
}