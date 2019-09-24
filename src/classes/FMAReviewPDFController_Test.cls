@isTest
public class FMAReviewPDFController_Test {
    
    private static Id createReview(Integer type) {
        FMA_Review_Form__c review = new FMA_Review_Form__c();
        if (1 == type) {
            review.Concentrated_Positions_pl__c = 'Review Changes as Follows';
            review.Concentrated_Positions_Comments__c = 'test comment';
            review.High_Cash_Balance_pl__c = 'Reviewed, No Change';
            review.High_Cash_Balance_Comments__c = '';
            review.Investment_and_Performance_pl__c = 'Review Changes as Follows';
            review.Investment_and_Performance_Comments__c = 'test comment';
            review.Investment_Objective_and_Risk_pl__c = 'Reviewed, No Change';
            review.Investment_Objective_and_Risk_comments__c = '';
            review.Personal_Client_Info_pl__c = 'Review Changes as Follows';
            review.Personal_Client_Info_co__c = 'test comment';
            review.Time_Horizon_pl__c = 'Reviewed, No Change';
            review.Time_Horizon_and_Liquidity_Needs_Comment__c = '';
            review.Trading_Low_Trading_pl__c = 'Review Changes as Follows';
            review.Trading_Low_Trading_Comments__c = 'test comment';
            review.Call_Notes__c = '';
        } else {
            review.Concentrated_Positions_pl__c = 'Reviewed, No Change';
            review.Concentrated_Positions_Comments__c = '';
            review.High_Cash_Balance_pl__c = 'Review Changes as Follows';
            review.High_Cash_Balance_Comments__c = 'test comment';
            review.Investment_and_Performance_pl__c = 'Reviewed, No Change';
            review.Investment_and_Performance_Comments__c = '';
            review.Investment_Objective_and_Risk_pl__c = 'Review Changes as Follows';
            review.Investment_Objective_and_Risk_comments__c = 'test comment';
            review.Personal_Client_Info_pl__c = 'Reviewed, No Change';
            review.Personal_Client_Info_co__c = '';
            review.Time_Horizon_pl__c = 'Review Changes as Follows';
            review.Time_Horizon_and_Liquidity_Needs_Comment__c = 'test comment';
            review.Trading_Low_Trading_pl__c = 'Reviewed, No Change';
            review.Trading_Low_Trading_Comments__c = '';
            review.Call_Notes__c = 'more comments';
        }
        insert review;
        return review.Id;
    }
    
    private static Id getFormDataId() {
        String formsForVFPage = '';
        formsForVFPage += createReview(1);
        formsForVFPage += ',' + createReview(2);
        formsForVFPage += ',' + createReview(2);
        formsForVFPage += ',' + createReview(1);
        
        FormData__c formData = new FormData__c();
        formData.Forms_For_VF_Page__c = formsForVFPage;
        insert formData;
        
        return formData.Id;
    }
    
    @isTest private static void testOne() {
        PageReference FMAReviewPDF = new PageReference('/apex/FMAReviewPDF?formDataId=' + getFormDataId());
        Test.setCurrentPage(FMAReviewPDF);
        //ApexPages.currentPage().getParameters().put('formDataId', getFormDataId());
        FMAReviewPDFController inst = new FMAReviewPDFController();
        system.assertNotEquals(null, inst.formData);
        system.assertEquals(false, inst.getIsDraft());
        system.assertNotEquals(null, inst.getReviews());
        system.assertNotEquals(null, inst.getHouseHoldReviews());
        //system.assertNotEquals(null, inst.formData);
    }
    
}