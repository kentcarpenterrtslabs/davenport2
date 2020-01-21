/* eslint-disable no-unused-vars */
/* eslint-disable array-callback-return */
/* eslint-disable no-console */
import { LightningElement, track } from 'lwc';
//import getAllReps from '@salesforce/apex/RepController.getReps'
//import getHousesholds from '@salesforce/apex/RepAccountsController.getRepHouseholds'
import getDashboardData from '@salesforce/apex/FMADashboardController.getFMAReviewData'
import { NavigationMixin } from 'lightning/navigation';
import createFormData from '@salesforce/apex/FormDataController.createFormData';
import getRepLabelsData from '@salesforce/apex/RepAssignmentController.getRepLabelData';
import getHousesholdIds from '@salesforce/apex/RepNumHouseholdSearchController.getHouseholds';
import getBaseUrl from '@salesforce/apex/VfpageUrlGenerator.getBaseUrl';



// Sets variable for end of year date
let today = new Date();
const dd = String(today.getDate()).padStart(2, '0');
const mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
const yyyy = today.getFullYear();
today = yyyy + '-' + mm + '-' + dd  ;
const eoy = yyyy + '-12-31';


//Sets columns for Rep Household Dashboard
const columns = [
    {label: 'Household', fieldName: 'house', initialWidth: 500, type: 'text'},
    {label: 'Financial Accounts', fieldName: 'acctnums', type: 'text', typeAttributes: { tooltip: { fieldName: 'acctnums' } }},
    {label: 'Notes', fieldName: 'countofNotes', type: 'number', initialWidth: 75, cellAttributes: { alignment: 'right' }}, //
    {label: 'Last FMA Review', fieldName: 'lastReviewDate', type: 'date', initialWidth: 150, cellAttributes: { alignment: 'right' }}

]

export default class FmaReviewComponent extends NavigationMixin(LightningElement){
    

    @track selectedRep;
    @track startDateRange = yyyy+'-01-01';
    @track endDateRange = eoy;
    @track columns = columns;
    @track error;
    @track reps= [];
    @track fmaData;
    @track repHouseholds;
    @track tableLoadingState = true;
    @track noHouseholds = false;
    @track sortedDirection;
    @track sortedBy;
    @track selectedHouseholdsForFinal;
    @track finalReview = false;
    @track finalReviewFormatData;
    @track formatedStart = "01-01-" + yyyy;
    @track formatedEnd = "12-31-" + yyyy;
    @track continueButtonDisable = false
    @track forms=[];
    @track uniqueUsers;
    @track selectedRepName="Select Rep"
    @track repNumbers;
    @track repLabel = "Select a Rep";
    //@track userList; // never used
    @track domRepNumbers;
    @track repDataList;
    @track vbBaseUrl="";
    @track repLabel;

    

    
    //Lifecycle Hook at page load to get Reps for RepSelector
    connectedCallback(){
        getRepLabelsData()
        .then(data =>{
            this.createRepDropdownValues(data)
        }).catch(error=>{
            this.error = error
        });

        getBaseUrl()
        .then(data =>{
                this.vbBaseUrl = data
        }).catch( error =>{
            this.error = error
        });
    }

    //Formats date for functions
    formatedDate(date){
       const splitDate = date.split("-");
       const year = splitDate[0];
       const month = splitDate[1];
       const day = splitDate[2]
       return month + "-" + day + "-" + year
    }

    //Handle change function for rep select
    handleChange(event){
       
        //For Rep selctor onchange
        if(event.target.name === 'repSelector'){
            this.selectedRep = event.detail.value;


            const repData = this.repDataList;
            const selectedRep = this.selectedRep;
           
            for(let i=0; i < repData.length; i++){
                if(repData[i].repId === selectedRep){
                   this.repLabel = repData[i].repName;
                   //console.log('rep label: ' + this.repLabel);
                    const repIdsArray = repData[i].repNumberIds
                    let newRepArray = []
                    for (let j=0; j<  repIdsArray.length; j++){
                        newRepArray.push(repIdsArray[j])
                    }
                    getHousesholdIds({repNumbers: newRepArray})
                        .then(hhdata =>{
                            this.repHouseholds = hhdata;
                            this.noHouseholds = hhdata.length === 0 ? true : false
                            getDashboardData({households: this.repHouseholds, startDateRange: this.startDateRange, endDateRange: this.endDateRange})
                            .then(hdata =>{
                                this.populateDataTable(hdata);
                            })
                            .catch(error => {
                                this.error = error
                            })  
                        })
                        .catch(error => {
                            this.error = error
                        })
                }
            }
        
        } else if(event.target.name === 'startDateRange'){
            this.startDateRange = event.target.value;
            this.formatedStart = this.formatedDate(this.startDateRange)
            getDashboardData({households: this.repHouseholds, startDateRange: this.startDateRange, endDateRange: this.endDateRange})
                .then(hdata =>{
                    this.populateDataTable(hdata);
                })
                .catch(error => {
                    this.error = error
                })
        } else if(event.target.name === 'endDateRange'){
            this.endDateRange = event.target.value;
            this.formatedEnd = this.formatedDate(this.endDateRange)
            getDashboardData({households: this.repHouseholds, startDateRange: this.startDateRange, endDateRange: this.endDateRange})
                .then(hdata =>{
            
                    this.populateDataTable(hdata);
                })
                .catch(error => {
                    this.error = error
                })
        }
    }


// Called at page loading to populate the rep pull down list
    createRepDropdownValues(data){
        
        let repDataList = []
        let createUniqueRepList = {}
        let uniqueUsersList = []

        createUniqueRepList = data.map(user => {
			if (typeof user.User__r !== "undefined") {
				let userId = user.User__r.Id;
				if (uniqueUsersList.indexOf(userId) === -1){
					uniqueUsersList.push(userId);
            
					let sObj = {
						repName: user.User__r.Name,
						repId: user.User__r.Id,
						repNumbers: [user.Rep__r.Rep_Number__c],
						repNumberIds: [user.Rep__r.Id]
					};
					repDataList.push(sObj);
				}
				else {
					for (let i=0; i<repDataList.length; i++){
						let numArray = repDataList[i].repNumbers;
						let idArray = repDataList[i].repNumberIds;
						if (repDataList[i].repName === user.User__r.Name){
							numArray.push(user.Rep__r.Rep_Number__c);
							idArray.push(user.Rep__r.Id); 
						}
					}
				}
			}
        })
     
        this.repDataList = repDataList;

		//
		// the field userListis is not used anywhere else in this file
		//
        //this.userList = repDataList
        const rList = repDataList.map(rep => {
            
            let sObj = {
                         label: rep.repName,
                         value: rep.repId}
                 return sObj       
                })
            
        ;
        this.reps = rList.sort((a,b) =>{
            if (a.label < b.label) {
                return -1;
              }
              if (a.label > b.label) {
                return 1;
              }
            
              // names must be equal
              return 0;
           //a.label.localeCompare(b.label) 
        })
     
      
    }



    populateDataTable(data){

        const houses =  this.repHouseholds;
    
        const tableData = houses.map(house => {
            let sObj;
            let id = house.Id;
            let forms = data[id]
            let numberOfForms = (typeof forms === "undefined" ? 0 : data[id].length);
            let houseName = house.Name;
            let houseAcctNums = house.Account_Numbers__c;
            let reviewDate = house.Last_FMA_Form_Created__c;
    
            if(numberOfForms > 0 || reviewDate > this.startDateRange || reviewDate < '2019-01-01' || reviewDate === ""){

				let financialAccountNames = [];
				forms.forEach(function(form) {
					if (typeof form.FMA_Account_Review_Associations__r !== "undefined") {
						form.FMA_Account_Review_Associations__r.forEach(function(association) {
							if (! financialAccountNames.includes(association.Financial_Account__r.Name)) {
								financialAccountNames.push(association.Financial_Account__r.Name + ("undefined" === typeof(association.Financial_Account__r.Plan_ID__c) ? '' : '-' + association.Financial_Account__r.Plan_ID__c));
							}
						});
					}
				});

                sObj ={
                    id: id,
                    house: houseName,
                    acctnums: financialAccountNames.join(', '),
                    countofNotes: numberOfForms,
                    lastReviewDate: reviewDate === undefined ? "No Review Conducted" : reviewDate,
                    forms: forms
                }
            } 
            else{
                sObj = undefined;
            } 
            
            return sObj;
        })
   
        const filterList = this.filterArray(tableData)
        const sortedTable = filterList.sort((a,b)=>{
            if(a.lastReviewDate < b.lastReviewDate){
                return -1;
            }
            if(a.lastReviewDate > b.lastReviewDate){
                return 1;
            }
            return 0
        })

        this.fmaData = sortedTable;
        this.tableLoadingState = false;
    }


    handleClick(event){
  
        if(event.target.name === "continue"){
            this.finalReview = true
        } else if (event.target.name === "back"){
            this.finalReview = false
        } else if (event.target.name === "draft"){
            const formsIds = this.forms;
            const repLabel = this.repLabel;
            createFormData({formIds:formsIds, repLabel:repLabel})
            .then(data =>{


                window.open(this.vbBaseUrl + ".visual.force.com/apex/FMAReviewPDF?isDraft=" + true + "&formDataId=" + data,"_blank")
              
            })
            .catch(error => {
                this.error = error
            })
        } else if (event.target.name === "final"){
            const formsIds = this.forms;
            const repLabel = this.repLabel;
            createFormData({formIds:formsIds, repLabel:repLabel})
            .then(data =>{
                window.open(this.vbBaseUrl + ".visual.force.com/apex/FMAReviewPDF?isDraft=" + false + "&formDataId=" + data,"_blank")
            })
            .catch(error => {
                this.error = error
            })
        }
        
    }

    onRowSelection(event){
    
        this.selectedHouseholdsForFinal = event.detail.selectedRows
        if(this.selectedHouseholdsForFinal.length !== 0){
            this.formatReviewData(event.detail.selectedRows)
        }else {
            this.selectedHouseholdsForFinal= undefined;
        }
        
        
        
    }
    onSort(event){
        const fieldName = event.detail.fieldName
        const sortDirection = event.detail.sortDirection
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        
    }

    reviewButtonFilter(btnArray){
        let btnLabel = "Not Applicable";
        const reviewed = "Review Changes as Follows";
        const nochange = "Reviewed, No Change";
    
        //const na = "Not Applicable"
          if(btnArray.indexOf(reviewed) !== -1){
              btnLabel = reviewed  
          } else if (btnArray.indexOf(nochange) !== -1){
            btnLabel = nochange
            }
  
          return btnLabel
      }


    filterArray(testArray) {
        let index = -1,
            arrLength = testArray ? testArray.length : 0,
            resIndex = -1,
            result = [];
    
        while (++index < arrLength) {
            let value = testArray[index];
    
            if (value) {
                result[++resIndex] = value;
            }
        }
    
        return result;
    }

    formatReviewData(selectedRowData){
        this.forms = []
        let formsArray = [];
       
           //Each topic is visble or not visble, if visble button, topic always (optional comments) 

		const selectedDataArray = selectedRowData.map(house =>{
			let highCashComments = [];
			let highCashBtn = [];
			let conPositionsComments = [];
			let conPositionsBtn = [];
			let investPerfComments = [];
			let investPerfBtn = [];
			let investObjComments = [];
			let investObjBtn = [];
			let clientInfoComments = [];
			let clientInfoBtn = [];
			let timeHorzComments = [];
			let timeHorzBtn = [];
			let tradingComments = [];
			let tradingBtn = [];
			let additionalComments = [];
			let formsdata = house.forms;
       
       

			// eslint-disable-next-line array-callback-return
			// eslint-disable-next-line no-unused-vars
			let formArray = formsdata.map(form =>{
				let financialAccountNames = [];
				form.FMA_Account_Review_Associations__r.forEach(association =>
					financialAccountNames.push(
						association.Financial_Account__r.Name
						+ ("undefined" === typeof(association.Financial_Account__r.Plan_ID__c) ? '' : '-' + association.Financial_Account__r.Plan_ID__c))
				);
				if ("undefined" !== typeof(form.High_Cash_Balance_Comments__c)) { highCashComments.push(financialAccountNames + '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + form.High_Cash_Balance_Comments__c + '<br/>'); }
				highCashBtn.push(form.High_Cash_Balance_pl__c);

				if ("undefined" !== typeof(form.Concentrated_Positions_Comments__c)) { conPositionsComments.push(financialAccountNames + '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + form.Concentrated_Positions_Comments__c + '<br/>'); }
				conPositionsBtn.push(form.Concentrated_Positions_pl__c);

				if ("undefined" !== typeof(form.Investment_and_Performance_Comments__c)) { investPerfComments.push(financialAccountNames + '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + form.Investment_and_Performance_Comments__c + '<br/>'); }
				investPerfBtn.push(form.Investment_and_Performance_pl__c);

				if ("undefined" !== typeof(form.Investment_Objective_and_Risk_comments__c)) { investObjComments.push(financialAccountNames + '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + form.Investment_Objective_and_Risk_comments__c + '<br/>'); }
				investObjBtn.push(form.Investment_Objective_and_Risk_pl__c);

				if ("undefined" !== typeof(form.Personal_Client_Info_co__c)) { clientInfoComments.push(financialAccountNames + '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + form.Personal_Client_Info_co__c + '<br/>'); }
				clientInfoBtn.push(form.Personal_Client_Info_pl__c);

				if ("undefined" !== typeof(form.Time_Horizon_and_Liquidity_Needs_Comment__c)) { timeHorzComments.push(financialAccountNames + '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + form.Time_Horizon_and_Liquidity_Needs_Comment__c + '<br/>'); }
				timeHorzBtn.push(form.Time_Horizon_pl__c);

				if ("undefined" !== typeof(form.Trading_Low_Trading_Comments__c)) { tradingComments.push(financialAccountNames + '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + form.Trading_Low_Trading_Comments__c + '<br/>'); }
				tradingBtn.push(form.Trading_Low_Trading_pl__c);

				if ("undefined" !== typeof(form.Call_Notes__c)) { additionalComments.push(financialAccountNames + '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + form.Call_Notes__c + '<br/>'); }

				formsArray.push(form.Id)

				return form
			})
       
			const addComments = this.filterArray(additionalComments)
       

			const fObj = [
				{
					display: this.reviewButtonFilter(clientInfoBtn) === "Not Applicable" ? 'hidden' : 'display', 
					topic: 'Personal Client Info', 
					button: this.reviewButtonFilter(clientInfoBtn), 
					displayComments: this.reviewButtonFilter(clientInfoBtn) === "Review Changes as Follows" ? 'slds-p-horizontal_small display slds-box' : 'slds-p-horizontal_small hidden',
					comments: this.filterArray(clientInfoComments)
				},
				{
					display: this.reviewButtonFilter(investObjBtn) === "Not Applicable" ? 'hidden' : 'display', 
					topic: 'Investment Objective and Risk Tolerance', 
					button: this.reviewButtonFilter(investObjBtn), 
					displayComments: this.reviewButtonFilter(investObjBtn) === "Review Changes as Follows" ? 'slds-p-horizontal_small display slds-box' : 'slds-p-horizontal_small hidden', 
					comments: this.filterArray(investObjComments)
				},
				{
					display: this.reviewButtonFilter(timeHorzBtn) === "Not Applicable" ? 'hidden' : 'display', 
					topic: 'Time Horizon and Liquidity Needs', 
					button: this.reviewButtonFilter(timeHorzBtn), 
					displayComments: this.reviewButtonFilter(timeHorzBtn) === "Review Changes as Follows" ? 'slds-p-horizontal_small display slds-box' : 'slds-p-horizontal_small hidden', 
					comments: this.filterArray(timeHorzComments)
				},
				{
					display: this.reviewButtonFilter(investPerfBtn) === "Not Applicable" ? 'hidden' : 'display', 
					topic: 'Investment and Performance', 
					button: this.reviewButtonFilter(investPerfBtn), 
					displayComments: this.reviewButtonFilter(investPerfBtn) === "Review Changes as Follows" ? 'slds-p-horizontal_small display slds-box' : 'slds-p-horizontal_small hidden', 
					comments: this.filterArray(investPerfComments)
				},
				{
					display: this.reviewButtonFilter(conPositionsBtn) === "Not Applicable" ? 'hidden' : 'display', 
					topic: 'Concentrated Positions', 
					button: this.reviewButtonFilter(conPositionsBtn), 
					displayComments: this.reviewButtonFilter(conPositionsBtn) === "Review Changes as Follows" ? 'slds-p-horizontal_small display slds-box' : 'slds-p-horizontal_small hidden', 
					comments: this.filterArray(conPositionsComments)
				},
				{
					display: this.reviewButtonFilter(highCashBtn) === "Not Applicable" ? 'hidden' : 'display', 
					topic: 'High Cash Balance', 
					button: this.reviewButtonFilter(highCashBtn), 
					displayComments: this.reviewButtonFilter(highCashBtn) === "Review Changes as Follows" ? 'slds-p-horizontal_small display slds-box' : 'slds-p-horizontal_small hidden', 
					comments: this.filterArray(highCashComments)
				},
				{
					display: this.reviewButtonFilter(tradingBtn) === "Not Applicable" ? 'hidden' : 'display', 
					topic: 'Trading/Low Trading', 
					button: this.reviewButtonFilter(tradingBtn), 
					displayComments: this.reviewButtonFilter(tradingBtn) === "Review Changes as Follows" ? 'slds-p-horizontal_small display slds-box' : 'slds-p-horizontal_small hidden', 
					comments: this.filterArray(tradingComments)
				},
				{
					display: addComments[0] === "-" ? 'hidden' : 'display', 
					topic: 'Additional Comments',  
					displayComments: addComments[0] === "-" ? 'slds-p-horizontal_small hidden' : 'slds-p-horizontal_small display slds-box', 
					comments: this.filterArray(additionalComments)
				},

			]
        
    
			//Make array of topic, button and possible comments
			let sObj ={
				name: house.house,
				forms: fObj
			}
     
       
			return sObj;
		})

		this.finalReviewFormatData = selectedDataArray   
		this.forms = formsArray.toString()

    }

}