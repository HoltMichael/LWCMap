/* eslint-disable no-console */
import { LightningElement, api } from 'lwc';

export default class RecordMapWrap extends LightningElement {
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
    @api iconColour;

    connectedCallback(){
        //Nothing to do here anymore. Formerly loaded the colours in from CSS file
    }

    get colour(){
        return 'background:' + this.iconColour;
    }
}