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
		this.percentOfMSRP = percentOfMSRP/100;
		this.percentOfDNet = percentOfDNet/100;
		this.rebatePercent = rebatePercent/100;
		this.grossProfitPercent = grossProfitPercent/100;
		if(percentOfDNet != null && dnet != null) {
			this.awardPrice = dnet * percentOfDNet/100;
		}
		decimal rebate = dnet * rebatePercent/100;
		this.grossProfit = dnet * percentOfDNet/100 - dnet + rebate;	
	}
	
	public ToroPricingMethodData(decimal percentOfDNet, decimal dnet, decimal msrp) {
		this.percentOfDNet = percentOfDNet/100;
		this.dnet = dnet;
		this.msrp = msrp;		
	}
	
	public ToroPricingMethodData() {
		
	}
	
}