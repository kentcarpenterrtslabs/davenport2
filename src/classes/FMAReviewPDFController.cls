public with sharing class FMAReviewPDFController {
    
    public FormData__c formData = [SELECT Forms_For_VF_Page__c, RepUserName__c FROM FormData__c WHERE Id=:ApexPages.currentPage().getParameters().get('formDataId') LIMIT 1];
    private final List<FMA_Review_Form__c> reviewList;
    private final List<Id> reviewIds;
    private final Boolean isDraft;
    private final String REVIEW_CHANGES = 'Review Changes as Follows';
    private final String NO_CHANGES = 'Reviewed, No Change';
    public List<HouseholdWrapper> households = new List<HouseholdWrapper>();
    
    public FMAReviewPDFController() {
        //system.debug(formData);
        isDraft = ('true' == ApexPages.currentPage().getParameters().get('isDraft'));
        
        reviewIds = formData.Forms_For_VF_Page__c.split(',');
        
        reviewList = [
            SELECT 
				Account__c, 
				Rep__c, 
				Current_Review__c , 
				Account__r.Name, 
				Rep__r.Name, 
				Rep__r.Rep_Number__c,
				Account__r.AccountNumber,
				Concentrated_Positions_pl__c, 
				Concentrated_Positions_Comments__c,
				High_Cash_Balance_pl__c,
				High_Cash_Balance_Comments__c,
				Investment_and_Performance_pl__c,
				Investment_and_Performance_Comments__c,
				Investment_Objective_and_Risk_comments__c,
				Investment_Objective_and_Risk_pl__c,
				Personal_Client_Info_pl__c,
				Personal_Client_Info_co__c,
				Time_Horizon_pl__c,
				Time_Horizon_and_Liquidity_Needs_Comment__c,
				Trading_Low_Trading_pl__c,
				Trading_Low_Trading_Comments__c,
				Call_Notes__c,
				CreatedDate,
				IsDeleted,
				(
					SELECT
						Financial_Account__r.Name,
						Financial_Account__r.Plan_ID__c
					FROM FMA_Account_Review_Associations__r
				)
				FROM FMA_Review_Form__c 
				WHERE Id IN :reviewIds
            ORDER BY Account__c ];
        
        //households = getHouseholdReviews();
    }
    
    public Boolean getIsDraft() {
        return isDraft;
    }
    
    public List<FMA_Review_Form__c> getReviews() {
        system.debug('formData: ' + formData);
        system.debug('reviewList: ' + reviewList.size());
        system.debug('reviewIds: ' + reviewIds);
        system.debug('household wrappers: ' + households);
        return reviewList;
    }
    
    public List<HouseholdWrapper> getHouseholdReviews() {
        List<String> hhIds = new List<String>();
        for (FMA_Review_Form__c review : reviewList) {
            if (0 == hhIds.size() || !hhIds.contains(review.Account__r.Name)) {
                hhIds.add(review.Account__r.Name);
            }
        }
        system.debug('hhIds: ' + hhIds);
        system.debug('number of hhIds: ' + hhIds.size());
        
        
        for (String accName : hhIds) {
            HouseholdWrapper hhWrapper = new HouseholdWrapper();
            hhWrapper.name = accName;
            hhWrapper.isBlank = true;
            hhWrapper.repName = formData.RepUserName__c;
            
            TopicWrapper concentratedPositions = new TopicWrapper();
            concentratedPositions.name = 'Concentrated Positions';
            concentratedPositions.answer = 'Not Applicable';
            
            TopicWrapper highCash = new TopicWrapper();
            highCash.name = 'High Cash Balance';
            highCash.answer = 'Not Applicable';
            
            TopicWrapper investPerformance = new TopicWrapper();
            investPerformance.name = 'Investment and Performance';
            investPerformance.answer = 'Not Applicable';
            
            TopicWrapper objectiveRisk = new TopicWrapper();
            objectiveRisk.name = 'Investment Objective and Risk Tolerance';
            objectiveRisk.answer = 'Not Applicable';
            
            TopicWrapper clientInfo = new TopicWrapper();
            clientInfo.name = 'Personal Client Info';
            clientInfo.answer = 'Not Applicable';
            
            TopicWrapper timeHorizon = new TopicWrapper();
            timeHorizon.name = 'Time Horizon and Liquidity Needs';
            timeHorizon.answer = 'Not Applicable';
            
            TopicWrapper trading = new TopicWrapper();
            trading.name = 'Trading/Low Trading';
            trading.answer = 'Not Applicable';
            for (FMA_Review_Form__c review : reviewList) {
                if (review.Account__r.Name == accName) {

					String financialAccountNames = '';
					for (FMA_Account_Review_Association__c assoc : review.FMA_Account_Review_Associations__r) {
						financialAccountNames += (financialAccountNames.length() > 0 ? ', ' : '') + assoc.Financial_Account__r.Name + (String.isBlank(assoc.Financial_Account__r.Plan_ID__c) ? '' : '-' + assoc.Financial_Account__r.Plan_ID__c);
					}

					String newline = '<br/>';
					String newlineIndent = newline + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
                    
                    if (REVIEW_CHANGES == review.Concentrated_Positions_pl__c || (NO_CHANGES == review.Concentrated_Positions_pl__c && REVIEW_CHANGES != concentratedPositions.answer) ) {
                        concentratedPositions.answer = review.Concentrated_Positions_pl__c;
                        if (null != review.Concentrated_Positions_Comments__c && null == concentratedPositions.comment) {
                            concentratedPositions.comment = financialAccountNames + ':' + newlineIndent + review.Concentrated_Positions_Comments__c;
                        } else if (null != review.Concentrated_Positions_Comments__c && null != concentratedPositions.comment) {
                            concentratedPositions.comment += newline + financialAccountNames + ':' + newlineIndent + review.Concentrated_Positions_Comments__c;
                        }
                        hhWrapper.isBlank = false;
                    }
                    
                    if (REVIEW_CHANGES == review.High_Cash_Balance_pl__c || (NO_CHANGES == review.High_Cash_Balance_pl__c && REVIEW_CHANGES != highCash.answer) ) {
                        highCash.answer = review.High_Cash_Balance_pl__c;
                        if (null != review.High_Cash_Balance_Comments__c && null == highCash.comment) {
                            highCash.comment = financialAccountNames + ':' + newlineIndent +  review.High_Cash_Balance_Comments__c;
                        } else if (null != review.High_Cash_Balance_Comments__c && null != highCash.comment) {
                            highCash.comment += newline + financialAccountNames + ':' + newlineIndent + review.High_Cash_Balance_Comments__c;
                        }
                        hhWrapper.isBlank = false;
                    }
                    
                    if (REVIEW_CHANGES == review.Investment_and_Performance_pl__c || (NO_CHANGES == review.Investment_and_Performance_pl__c && REVIEW_CHANGES != investPerformance.answer) ) {
                        investPerformance.answer = review.Investment_and_Performance_pl__c;
                        if (null != review.Investment_and_Performance_Comments__c && null == investPerformance.comment) {
                            investPerformance.comment = financialAccountNames + ':' + newlineIndent + review.Investment_and_Performance_Comments__c;
                        } else if (null != review.Investment_and_Performance_Comments__c && null != investPerformance.comment) {
                            investPerformance.comment += newline + financialAccountNames + ':' + newlineIndent + review.Investment_and_Performance_Comments__c;
                        }
                        hhWrapper.isBlank = false;
                    }
                    
                    if (REVIEW_CHANGES == review.Investment_Objective_and_Risk_pl__c || ('Reviewe' == review.Investment_Objective_and_Risk_pl__c && REVIEW_CHANGES != objectiveRisk.answer) ) {
                        objectiveRisk.answer = review.Investment_Objective_and_Risk_pl__c;
                        if (null != review.Investment_Objective_and_Risk_comments__c && null == objectiveRisk.comment) {
                            objectiveRisk.comment = financialAccountNames + ':' + newlineIndent + review.Investment_Objective_and_Risk_comments__c;
                        } else if (null != review.Investment_Objective_and_Risk_comments__c && null != objectiveRisk.comment) {
                            objectiveRisk.comment += newline + financialAccountNames + ':' + newlineIndent + review.Investment_Objective_and_Risk_comments__c;
                        }
                        hhWrapper.isBlank = false;
                    }
                    
                    if (REVIEW_CHANGES == review.Personal_Client_Info_pl__c || (NO_CHANGES == review.Personal_Client_Info_pl__c && REVIEW_CHANGES != clientInfo.answer) ) {
                        clientInfo.answer = review.Personal_Client_Info_pl__c;
                        if (null != review.Personal_Client_Info_co__c && null == clientInfo.comment) {
                            clientInfo.comment = financialAccountNames + ':' + newlineIndent + review.Personal_Client_Info_co__c;
                        } else if (null != review.Personal_Client_Info_co__c && null != clientInfo.comment) {
                            clientInfo.comment += newline + financialAccountNames + ':' + newlineIndent + review.Personal_Client_Info_co__c;
                        }
                        hhWrapper.isBlank = false;
                    }
                    
                    if (REVIEW_CHANGES == review.Time_Horizon_pl__c || (NO_CHANGES == review.Time_Horizon_pl__c && REVIEW_CHANGES != timeHorizon.answer) ) {
                        timeHorizon.answer = review.Time_Horizon_pl__c;
                        if (null != review.Time_Horizon_and_Liquidity_Needs_Comment__c && null == timeHorizon.comment) {
							timeHorizon.comment = financialAccountNames + ':' + newlineIndent + review.Time_Horizon_and_Liquidity_Needs_Comment__c;
                        } else if (null != review.Time_Horizon_and_Liquidity_Needs_Comment__c && null != timeHorizon.comment) {
                            timeHorizon.comment += newline + financialAccountNames + ':' + newlineIndent + review.Time_Horizon_and_Liquidity_Needs_Comment__c;
                        }
                        hhWrapper.isBlank = false;
                    }
                    
                    if (REVIEW_CHANGES == review.Trading_Low_Trading_pl__c || (NO_CHANGES == review.Trading_Low_Trading_pl__c && REVIEW_CHANGES != trading.answer) ) {
                        trading.answer = review.Trading_Low_Trading_pl__c;
                        if (null != review.Trading_Low_Trading_Comments__c && null == trading.comment) {
                            trading.comment = financialAccountNames + ':' + newlineIndent + review.Trading_Low_Trading_Comments__c;
                        } else if (null != review.Trading_Low_Trading_Comments__c && null != trading.comment) {
                            trading.comment += newline + financialAccountNames + ':' + newlineIndent + review.Trading_Low_Trading_Comments__c;
                        }
                        hhWrapper.isBlank = false;
                    }
                    
                   if (null != review.Call_Notes__c) {
                       if (null == hhWrapper.additionalComments) {
                          hhWrapper.additionalComments = financialAccountNames + ':' + newlineIndent + review.Call_Notes__c;
                       } else if (null != hhWrapper.additionalComments) {
                           hhWrapper.additionalComments += newline + financialAccountNames + ':' + newlineIndent + review.Call_Notes__c;
                       }
                       hhWrapper.isBlank = false;
                   }
                    
                }
            }
            
            List<TopicWrapper> topics = new List<TopicWrapper>();
            topics.add(concentratedPositions);
            topics.add(highCash);
            topics.add(investPerformance);
            topics.add(objectiveRisk);
            topics.add(clientInfo);
            topics.add(timeHorizon);
            topics.add(trading);
            
            hhWrapper.topics = topics;
            
            system.debug('*******ADDING HOUSEHOLD WRAPPER NOW FOR ACCOUNT: ' + accName);
            system.debug('*******TOPIC LIST SIZE FOR ACCOUNT: ' + topics.size());
            system.debug('*******TOPIC LIST FOR ACCOUNT: ' + topics);
            households.add(hhWrapper);
            
        }
        system.debug('number of households: ' + households.size());
        for (HouseholdWrapper hh : households) {
            system.debug('HOUSEHOLD ' + hh.name + ': ' + hh.isBlank);
            for (TopicWrapper topic : hh.topics) {
                //system.debug('HOUSEHOLD ' + hh.name + ' - ' + topic.name + ': ' + topic);
            }
        } 
        //delete formData;
        return households;
    }
    
    public class HouseholdWrapper {
        public String name {get;set;}
        public List<TopicWrapper> topics {get;set;}
        public String additionalComments {get;set;}
        public Boolean isBlank {get;set;}
         public String repName {get;set;}
        
        public HouseholdWrapper(String householdName, List<TopicWrapper> reviewTopics, String callNotes, Boolean blank , string theRepName) {
          
            name = householdName;
            topics = reviewTopics;
            additionalComments = callNotes;
            isBlank = blank;
            repName = theRepName;
        }
        
        public HouseholdWrapper() {
            
        }
    }
    
    public class TopicWrapper {
        public String name {get; set;}
        public String answer {get; set;}
        public String comment {get; set;}
        public String financialAccountNames {get; set;}
        
        public TopicWrapper(String topicName, String topicAnswer, String topicComment, String topicFinancialAccountNames) {
            name = topicName;
            answer = topicAnswer;
            comment = topicComment;
			financialAccountNames = topicFinancialAccountNames;
        }
        public TopicWrapper () {}
    }
    
}