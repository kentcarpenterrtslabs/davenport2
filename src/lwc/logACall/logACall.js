/* eslint-disable no-console */
import { LightningElement, api, wire, track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import ACCOUNT_FMA_ACCOUNT_FIELD from '@salesforce/schema/Account.FMA_Account__c';
import ACCOUNT_OWNER_FIELD from '@salesforce/schema/Account.OwnerId'
import ACCOUNT_ID_FIELD from '@salesforce/schema/Account.Id';
import ACCOUNT_REP_FIELD from '@salesforce/schema/Account.Rep__c';
import activityController from '@salesforce/apex/ActivityController.getTaskPicklist';
import getFinAccounts from '@salesforce/apex/HousesholdFAController.getFinAccounts';
import newCall from '@salesforce/apex/newCall.createTask';
import newFMAReview from '@salesforce/apex/FMAReviewController.createFMAReview';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



   

//import getUserInfo from '@salesforce/apex/UserDetails.getUserInfo';



var today = new Date();
var dd = String(today.getDate()).padStart(2, '0');
var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
var yyyy = today.getFullYear();

today = yyyy + '-' + mm + '-' + dd  ;


export default class LogACall extends LightningElement {
    @api recordId;
    trying;
    subject="";
    status="";
    priority="";
    userId = Id;
    user="";
    type="";
    acctId="";
    userValue=Id
    finAccounts=[];
    @track activeSections = [];
    @track includeCommentsToggle=false;
    @track finAcctValue;
    @track subjectValue="Call";
    @track statusValue="Completed";
    @track TypeValue="";
    @track callCommentsValue="";
    @track dateValue=today;
    @track error;
    @track userPickOpt="";
    //Btn group 1
    @track display1 = "hidden";
    @track naVariant1="brand";
    @track rvVariant1="neutral";
    @track chVariant1="neutral";
    @track clientValue="";
    @track clientInfoBtn="Not Applicable";
    //Btn group 2
    @track display2="hidden";
    @track naVariant2="brand";
    @track rvVariant2="neutral";
    @track chVariant2="neutral";
    @track investValue="";
    @track investInfoBtn="Not Applicable";
    //Btn group 3
    @track display3="hidden";
    @track naVariant3="brand";
    @track rvVariant3="neutral";
    @track chVariant3="neutral";
    @track timeValue="";
    @track timeInfoBtn="Not Applicable";
    //Btn group 4
    @track display4="hidden";
    @track naVariant4="brand";
    @track rvVariant4="neutral";
    @track chVariant4="neutral";
    @track inPerfValue="";
    @track inPerfInfoBtn="Not Applicable";
    //Btn group 5
    @track display5="hidden";
    @track naVariant5="brand";
    @track rvVariant5="neutral";
    @track chVariant5="neutral";
    @track conValue="";
    @track conInfoBtn="Not Applicable";
    //Btn group 6
    @track display6="hidden";
    @track naVariant6="brand";
    @track rvVariant6="neutral";
    @track chVariant6="neutral";
    @track highValue="";
    @track highInfoBtn="Not Applicable";
    //Btn group 7
    @track display7="hidden";
    @track naVariant7="brand";
    @track rvVariant7="neutral";
    @track chVariant7="neutral";
    @track unSolValue="";
    @track unSolInfoBtn="Not Applicable";
    @track value;
    @track accountData;
    @track name;
    @track FMA;
    @track accountRep;
    @track accountOwner;
    @track accountId;
   

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NAME_FIELD, ACCOUNT_FMA_ACCOUNT_FIELD, ACCOUNT_ID_FIELD, ACCOUNT_OWNER_FIELD, ACCOUNT_REP_FIELD] })
    wiredAccounts({error, data}){
        if(data){
            this.name = data.fields.Name.value;
            this.FMA =  data.fields.FMA_Account__c.value;
            this.accountRep = data.fields.Rep__c.value;
            this.accountOwner = data.fields.OwnerId.value;
            this.accountId = data.fields.Id.value;
        
        
        } else if (error){
            console.log (error);
        }
    }

    @wire(activityController)
    wiredPicklist ({error, data}){
        if(data){
            //this.getOwnerPicklistOptions(data);
            this.getPicklistOptions(data);
            this.error = undefined;
        } else if (error){
            this.error = error;
        }
    }

    @wire(getFinAccounts, { rId: '$recordId' })
    wiredFinAccount({ error, data}){
        if(data){
            this.getFinAccounts(data)
            this.error = undefined;
        } else if(error){
            this.finerror = error;
        }
    } 
    @wire(getFinAccounts, { rId: '$recordId' })
    finacctdata;


   

handleClick() {
    
       let finarray = []
       for(let i=0; i < this.finAccounts.length; i++){
           finarray.push(this.finAccounts[i].value) ;
            
       }
       //console.log(finarray)
       
        let acctparams = {
           rId: this.recordId,
           uId: this.userValue,
           subject: this.subjectValue,
           status: this.statusValue,
           comments: this.callCommentsValue,
           dueDate: this.dateValue
   
         };

        
        

         let fmaFormParms = {
            AccountRep: this.accountRep,
            financialAcctsIds: finarray,
            personClientComments: this.clientValue,
            personClientBtn: this.clientInfoBtn,
            InvestObjComments: this.investValue,
            InvestObjBtn: this.investInfoBtn,
            TimeHorzonComments: this.timeValue,
            TimeHorizonBtn: this.timeInfoBtn,
            InvestPerfComment: this.inPerfValue,
            InvestPerfBtn: this.inPerfInfoBtn,
            ConcenPositionsComments: this.conValue,
            ConcenPositionsBtn: this.conInfoBtn,
            HighCashComments: this.highValue,
            HighCashBtn: this.highInfoBtn,
            TradingComments: this.unSolInfo,
            TradingBtn: this.unSolInfoBtn,
            AccountId: this.accountId,
            CallNotes: (this.includeCommentsToggle ? this.callCommentsValue : ""),
            Subject: this.subjectValue,
         }
      


        // eslint-disable-next-line no-undef
        
    if(
            this.clientInfoBtn === "Not Applicable" &&
            this.investInfoBtn === "Not Applicable" &&
            this.timeInfoBtn === "Not Applicable" &&
            this.highInfoBtn === "Not Applicable" &&
            this.unSolInfoBtn === "Not Applicable" &&
            this.inPerfInfoBtn === "Not Applicable" &&
            this.conInfoBtn === "Not Applicable" &&
            this.includeCommentsToggle === false
    ){
            newCall(acctparams)
        // eslint-disable-next-line no-unused-vars
        .then(result => {
            const evt = new ShowToastEvent({
                title: "Call Log Saved",
                message: "Call log has been created",
                variant: "success",
            });
            this.dispatchEvent(evt);
    
        })
        .catch(error => {
            console.log(error);
        })
     } else {
            newCall(acctparams)
            // eslint-disable-next-line no-unused-vars
            .then(result => {
               
            })
            .catch(error => {
                console.log(error);
            })
            newFMAReview(fmaFormParms)
        // eslint-disable-next-line no-unused-vars
            .then(result =>{
                console.log("New FMA Review");
               
                const evt = new ShowToastEvent({
                    title: "Form Created",
                    message: "FMA review has been created",
                    variant: "success",
                });
                this.dispatchEvent(evt); 
            })
            .catch(error => {
                console.log(error)
            })
    }

    this.activeSections = [];
    this.subjectValue="Call";
    this.statusValue="Completed";
    this.typeValue="";
    this.callCommentsValue="";
    this.dateValue=today;
    this.includeCommentsToggle=false;
    this.subjectValue="Call";
    this.statusValue="Completed";
    this.callValue="";
    this.callCommentsValue="";
    this.dateValue=today;
    this.userPickOpt="";
    //Btn group 1
    this.display1 = "hidden";
    this.naVariant1="brand";
    this.rvVariant1="neutral";
    this.chVariant1="neutral";
    this.clientValue="";
    this.clientInfoBtn="Not Applicable";
    //Btn group 2
    this.display2="hidden";
    this.naVariant2="brand";
    this.rvVariant2="neutral";
    this.chVariant2="neutral";
    this.investValue="";
    this.investInfoBtn="Not Applicable";
    //Btn group 3
    this.display3="hidden";
    this.naVariant3="brand";
    this.rvVariant3="neutral";
    this.chVariant3="neutral";
    this.timeValue="";
    this.timeInfoBtn="Not Applicable";
    //Btn group 4
    this.display4="hidden";
    this.naVariant4="brand";
    this.rvVariant4="neutral";
    this.chVariant4="neutral";
    this.inPerfValue="";
    this.inPerfInfoBtn="Not Applicable";
    //Btn group 5
    this.display5="hidden";
    this.naVariant5="brand";
    this.rvVariant5="neutral";
    this.chVariant5="neutral";
    this.conValue="";
    this.conInfoBtn="Not Applicable";
    //Btn group 6
    this.display6="hidden";
    this.naVariant6="brand";
    this.rvVariant6="neutral";
    this.chVariant6="neutral";
    this.highValue="";
    this.highInfoBtn="Not Applicable";
    //Btn group 7
    this.display7="hidden";
    this.naVariant7="brand";
    this.rvVariant7="neutral";
    this.chVariant7="neutral";
    this.unSolValue="";
    this.unSolInfoBtn="Not Applicable";
        
    }




    

    
//Check box group
    getFinAccounts(data){
        let optArray = [];
        // eslint-disable-next-line no-unused-vars
        const newmap = data.map(field => {
            let sObj = {};
            sObj = {
                label:field.Name + " - " + field.FinServ__FinancialAccountNumber__c,
                value:field.Id
            }
            optArray.push(sObj);
            return optArray
        })
       //Set Value for checkbox, this is required
        this.finAcctValue = optArray[0].value
        //Set options for checkbox group
        
        
        
        this.finAccounts = optArray;
     
    
        return optArray
    }

    getPicklistOptions(data){
        let subjectArray = [];
        let priorityArray = [];
        let statusArray = [];
        let typeArray = [];
        let userArray = [];
     


        // eslint-disable-next-line no-unused-vars
        const submap = data.Subject.map(field => {
            let sObj = {};
            sObj = {
                label: field,
                value: field
            }
            subjectArray.push(sObj);
            return subjectArray;
         })
         this.subject = subjectArray;


         // eslint-disable-next-line no-unused-vars
        const primap = data.Priority.map(field => {
            let sObj = {};
            sObj = {
                label: field,
                value: field
            }
            priorityArray.push(sObj);
            return priorityArray;
         })
         this.priority = priorityArray;

         // eslint-disable-next-line no-unused-vars
         const statmap = data.Status.map(field => {
            let sObj = {};
            sObj = {
                label: field,
                value: field
            }
            statusArray.push(sObj);
            return statusArray;
         })
         this.status = statusArray;

         // eslint-disable-next-line no-unused-vars
         const callmap = data.Type.map(field => {
            let sObj = {};
            sObj = {
                label: field,
                value: field
            }
            typeArray.push(sObj);
          
            return typeArray;
         })
         this.type = typeArray;

         
         // eslint-disable-next-line no-unused-vars
         const ownermap = data.Owner.map(owners => {
             let sObj = {};
             sObj = {
                 label: owners.Name,
                 value: owners.Id
             }
             userArray.push(sObj);
             return userArray
          })
          this.user = userArray;
    }
    

// handle input handle
    handleChange(event) {
        const name = event.target.name;
    
        if(name === "User"){
            this.userValue = event.target.value;
        } else if (name === "Date"){
            this.dateValue = event.target.value;
        } else if(name === "Subject"){
            this.subjectValue = event.target.value;
        } else if (name === "Status"){
            this.statusValue = event.target.value;
        } else if (name === "comments"){
            this.callCommentsValue = event.target.value;
        } else if (name === "Type"){
            this.typeValue = event.target.value;
        } else if (name === "clientInfo"){
            this.clientValue = event.target.value;
        } else if (name === "investInfo"){
            this.investValue = event.target.value;
        } else if (name === "timeInfo"){
            this.timeValue = event.target.value;
        } else if (name === "inPerfInfo"){
            this.inPerfValue = event.target.value;
        } else if (name === "conInfo"){
            this.conValue = event.target.value;
        } else if (name === "highInfo"){
            this.highValue = event.target.value;
        } else if (name === "unSolInfo"){
            this.unSolInfo = event.target.value;
        } else if (name === "FinAccountCheckbox"){
            this.finAcctValue = event.target.value;
        } else if (name === "includeToggle")
           this.includeCommentsToggle = event.target.checked;
           //this.activeSections = (event.target.checked ? ["FMAReview"] : [])
           this.activeSections = ["FMAReview"]
}


//Button Group code

    notesBtnGroup(num){
        if(num === 1){
            this.naVariant1="Neutral";
            this.rvVariant1="Neutral";
            this.chVariant1="Brand";
            this.display1="display";    
        } else if (num === 2){
            this.naVariant2="Neutral";
            this.rvVariant2="Neutral";
            this.chVariant2="Brand";
            this.display2="display"; 
        } else if (num === 3){
            this.naVariant3="Neutral";
            this.rvVariant3="Neutral";
            this.chVariant3="Brand";
            this.display3="display"; 
        } else if (num === 4){
            this.naVariant4="Neutral";
            this.rvVariant4="Neutral";
            this.chVariant4="Brand";
            this.display4="display"; 
        } else if (num === 5){
            this.naVariant5="Neutral";
            this.rvVariant5="Neutral";
            this.chVariant5="Brand";
            this.display5="display"; 
        } else if (num === 6){
            this.naVariant6="Neutral";
            this.rvVariant6="Neutral";
            this.chVariant6="Brand";
            this.display6="display"; 
        } else if (num === 7){
            this.naVariant7="Neutral";
            this.rvVariant7="Neutral";
            this.chVariant7="Brand";
            this.display7="display"; 
        }
        
    }

    nochangeBtnGroup(num){
        if(num === 1){
            this.display1="hidden";
            this.naVariant1="Neutral";
            this.rvVariant1="Brand";
            this.chVariant1="Neutral";
        } else if (num === 2){
            this.display2="hidden";
            this.naVariant2="Neutral";
            this.rvVariant2="Brand";
            this.chVariant2="Neutral";
        }  else if (num === 3){
            this.display3="hidden";
            this.naVariant3="Neutral";
            this.rvVariant3="Brand";
            this.chVariant3="Neutral";
        }  else if (num === 4){
            this.display4="hidden";
            this.naVariant4="Neutral";
            this.rvVariant4="Brand";
            this.chVariant4="Neutral";
        }  else if (num === 5){
            this.display5="hidden";
            this.naVariant5="Neutral";
            this.rvVariant5="Brand";
            this.chVariant5="Neutral";
        }  else if (num === 6){
            this.display6="hidden";
            this.naVariant6="Neutral";
            this.rvVariant6="Brand";
            this.chVariant6="Neutral";
        }  else if (num === 7){
            this.display7="hidden";
            this.naVariant7="Neutral";
            this.rvVariant7="Brand";
            this.chVariant7="Neutral";
        }

    }

    naBtnGroup(num){
        if(num === 1){
            this.display1="hidden";
            this.naVariant1="Brand";
            this.rvVariant1="Neutral";
            this.chVariant1="Neutral";
        } else if (num === 2){
            this.display2="hidden";
            this.naVariant2="Brand";
            this.rvVariant2="Neutral";
            this.chVariant2="Neutral";
        }  else if (num === 3){
            this.display3="hidden";
            this.naVariant3="Brand";
            this.rvVariant3="Neutral";
            this.chVariant3="Neutral";
        }  else if (num === 4){
            this.display4="hidden";
            this.naVariant4="Brand";
            this.rvVariant4="Neutral";
            this.chVariant4="Neutral";
        }  else if (num === 5){
            this.display5="hidden";
            this.naVariant5="Brand";
            this.rvVariant5="Neutral";
            this.chVariant5="Neutral";
        }  else if (num === 6){
            this.display6="hidden";
            this.naVariant6="Brand";
            this.rvVariant6="Neutral";
            this.chVariant6="Neutral";
        }  else if (num === 7){
            this.display7="hidden";
            this.naVariant7="Brand";
            this.rvVariant7="Neutral";
            this.chVariant7="Neutral";
        }
    }


    handleBGroup1Click(event) {
        const buttonLabel= event.target.label;
       
        if(buttonLabel==="Not Applicable"){
            if(this.clientValue === undefined || this.clientValue === ""){
                this.naBtnGroup(1);
                this.clientInfoBtn=buttonLabel;
            } else{
               this.notesBtnGroup(1);
               this.clientInfoBtn="Review Changes as Follows";
            }
        } else if (buttonLabel==="Review Changes as Follows"){
                this.notesBtnGroup(1);
                this.clientInfoBtn=buttonLabel;

        } else if (buttonLabel==="Reviewed, No Change"){

                if(this.clientValue === undefined || this.clientValue === ""){
                    this.nochangeBtnGroup(1);
                    this.clientInfoBtn="Reviewed, No Change"
                } else{
                    this.notesBtnGroup(1);
                    this.clientInfoBtn="Review Changes as Follows";
                }
        }
    }
           
        handleBGroup2Click(event) {
            const buttonLabel= event.target.label;
        
            if(buttonLabel==="Not Applicable"){
                if(this.investValue === undefined || this.investValue === ""){
                    this.naBtnGroup(2);
                    this.investInfoBtn=buttonLabel;
                } else{
                   this.notesBtnGroup(2);
                   this.investInfoBtn="Review Changes as Follows";
                }
            } else if (buttonLabel==="Review Changes as Follows"){
                    this.notesBtnGroup(2);
                    this.investInfoBtn=buttonLabel;
    
            } else if (buttonLabel==="Reviewed, No Change"){
    
                    if(this.investValue === undefined || this.investValue === ""){
                        this.nochangeBtnGroup(2);
                        this.investInfoBtn="Reviewed, No Change"
                    } else{
                        this.notesBtnGroup(2);
                        this.investInfoBtn="Review Changes as Follows";
                    }   
            }
        }
        handleBGroup3Click(event) {
            const buttonLabel= event.target.label;
            if(buttonLabel==="Not Applicable"){
                if(this.timeValue === undefined || this.timeValue === ""){
                    this.naBtnGroup(3);
                    this.timeInfoBtn=buttonLabel;
                } else{
                   this.notesBtnGroup(3);
                   this.timeInfoBtn="Review Changes as Follows";
                }
            } else if (buttonLabel==="Review Changes as Follows"){
                    this.notesBtnGroup(3);
                    this.timeInfoBtn=buttonLabel;
    
            } else if (buttonLabel==="Reviewed, No Change"){
    
                    if(this.timeValue === undefined || this.timeValue === ""){
                        this.nochangeBtnGroup(3);
                        this.timeInfoBtn="Reviewed, No Change"
                    } else{
                        this.notesBtnGroup(3);
                        this.timeInfoBtn="Review Changes as Follows";
                    }   
            }
        }
        handleBGroup4Click(event) {
            const buttonLabel= event.target.label;
        
            if(buttonLabel==="Not Applicable"){
                if(this.inPerfValue === undefined || this.inPerfValue === ""){
                    this.naBtnGroup(4);
                    this.inPerfInfoBtn=buttonLabel;
                } else{
                   this.notesBtnGroup(4);
                   this.inPerfInfoBtn="Review Changes as Follows";
                }
            } else if (buttonLabel==="Review Changes as Follows"){
                    this.notesBtnGroup(4);
                    this.inPerfInfoBtn=buttonLabel;
    
            } else if (buttonLabel==="Reviewed, No Change"){
    
                    if(this.inPerfValue === undefined || this.inPerfValue === ""){
                        this.nochangeBtnGroup(4);
                        this.inPerfInfoBtn="Reviewed, No Change"
                    } else{
                        this.notesBtnGroup(4);
                        this.inPerfInfoBtn="Review Changes as Follows";
                    }   
            }
        }
        handleBGroup5Click(event) {
            const buttonLabel= event.target.label;
    
            if(buttonLabel==="Not Applicable"){
                if(this.conValue === undefined || this.conValue === ""){
                    this.naBtnGroup(5);
                    this.conInfoBtn=buttonLabel;
                } else{
                   this.notesBtnGroup(5);
                   this.conInfoBtn="Review Changes as Follows";
                }
            } else if (buttonLabel==="Review Changes as Follows"){
                    this.notesBtnGroup(5);
                    this.conInfoBtn=buttonLabel;
    
            } else if (buttonLabel==="Reviewed, No Change"){
    
                    if(this.conValue === undefined || this.conValue === ""){
                        this.nochangeBtnGroup(5);
                        this.conInfoBtn="Reviewed, No Change"
                    } else{
                        this.notesBtnGroup(5);
                        this.conInfoBtn="Review Changes as Follows";
                    }   
            }
        }
        handleBGroup6Click(event) {
            const buttonLabel= event.target.label;
            if(buttonLabel==="Not Applicable"){
                if(this.highValue === undefined || this.highValue === ""){
                    this.naBtnGroup(6);
                    this.highInfoBtn=buttonLabel;
                } else{
                   this.notesBtnGroup(6);
                   this.highInfoBtn="Review Changes as Follows";
                }
            } else if (buttonLabel==="Review Changes as Follows"){
                    this.notesBtnGroup(6);
                    this.highInfoBtn=buttonLabel;
    
            } else if (buttonLabel==="Reviewed, No Change"){
    
                    if(this.highValue === undefined || this.highValue === ""){
                        this.nochangeBtnGroup(6);
                        this.highInfoBtn="Reviewed, No Change"
                    } else{
                        this.notesBtnGroup(6);
                        this.highInfoBtn="Review Changes as Follows";
                    }   
            }
        }
        handleBGroup7Click(event) {
            const buttonLabel= event.target.label;
            if(buttonLabel==="Not Applicable"){
                if(this.unSolValue === undefined || this.unSolValue === ""){
                    this.naBtnGroup(7);
                    this.unSolInfoBtn=buttonLabel;
                } else{
                   this.notesBtnGroup(7);
                   this.unSolInfoBtn="Review Changes as Follows";
                }
            } else if (buttonLabel==="Review Changes as Follows"){
                    this.notesBtnGroup(7);
                    this.unSolInfoBtn=buttonLabel;
    
            } else if (buttonLabel==="Reviewed, No Change"){
    
                    if(this.unSolValue === undefined || this.unSolValue === ""){
                        this.nochangeBtnGroup(7);
                        this.unSolInfoBtn="Reviewed, No Change"
                    } else{
                        this.notesBtnGroup(7);
                        this.unSolInfoBtn="Review Changes as Follows";
                    }   
            }
        }
       
        // if(testdiv.style.display==="none"){
        //     testdiv.style.display = "block";
        // } else {
        //     testdiv.style.display = "none";
        // }
       
        //  Handle clicks
        
    


    
}