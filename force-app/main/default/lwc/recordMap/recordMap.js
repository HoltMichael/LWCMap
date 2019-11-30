/* eslint-disable no-console */
import {LightningElement, api, wire, track} from 'lwc';
import getPropertyAddress from '@salesforce/apex/LtngMapController.getPropertyAddress';


export default class PropertyMap extends LightningElement {
    @api recordId;
    @api street;
    @api city;
    @api state;
    @api country;
    @api postcode;
    @api zoomLevel;
    @api margin;
    @api marginTitle = '';
    @api recordName = '';
    @api recordDesc = '';

    @track propertyLocs;
    @track error;

    @wire(getPropertyAddress, {recId: '$recordId', street: '$street', city: '$city', state: '$state', country: '$country', postcode: '$postcode', recordName: '$recordName', recordDesc: '$recordDesc'})
    wiredProperties({error,data}) {
        if (data) {
            this.propertyLocs = data;
            console.log(JSON.stringify(data, null, '\t'));
        } else if (error) {
            console.log('error');
            console.log(JSON.stringify(error, null, '\t'));
            this.error = error;
        }
    }
}