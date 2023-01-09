/* eslint-disable no-console */
import { LightningElement, api } from 'lwc';


export default class RecordMapWrap extends LightningElement {
    @api recordId;
    @api street = '';
    @api city = '';
    @api state = '';
    @api country = '';
    @api postcode = '';
    @api geolocation = '';
    @api zoomLevel;
    @api margin;
    @api marginTitle = '';
    @api recordName = '';
    @api recordDesc = '';
    @api iconColour;

    get colour(){
        return 'background:' + this.iconColour;
    }
}