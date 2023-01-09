/* eslint-disable no-console */
import {LightningElement, api, wire, track} from 'lwc';
import getAddress from '@salesforce/apex/LtngMapController.getAddress';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

export default class PropertyMap extends LightningElement {
    @api recordId;
    @api street;
    @api city;
    @api state;
    @api country;
    @api postcode;
    @api geolocation;
    @api zoomLevel;
    @api margin;
    @api marginTitle = '';
    @api recordName = '';
    @api recordDesc = '';
    

    @track propertyLocs;
    @track error;
    @track error1 = ''
    @track error2 = ''
    wiredPropertyResult;

    @wire(getAddress, {recId: '$recordId', street: '$street', city: '$city', state: '$state', country: '$country', postcode: '$postcode', recordName: '$recordName', recordDesc: '$recordDesc', geo: '$geolocation'})
    wiredProperties(value){
        this.wiredPropertyResult = value;
        const {data, error} = value;
        
        if (data) {
            //console.log(JSON.stringify(data, null, '\t'));
            this.propertyLocs = data;
        } else if (error) {
            // console.log('error');
            // console.log(JSON.stringify(error, null, '\t'));
            this.error1 = 'Error: No access to specified mapping fields.'
            this.error2 = 'Please consult with your Salesforce Administrator'
            this.error = error;
        }
    }

    FIELDS = ['Id'];

    @wire(getRecord, { recordId: '$recordId', fields: '$FIELDS' })
    wiredRecord({error, data}){
        if(error){
            console.log(error);
        }else {
            console.log('Hello');
            refreshApex(this.wiredPropertyResult);
        }
    }

}