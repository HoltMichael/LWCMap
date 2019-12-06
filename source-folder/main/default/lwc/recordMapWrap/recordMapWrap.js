import { LightningElement, api } from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader'
import iconBackground from '@salesforce/resourceUrl/ltngMapCSS';

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
        loadStyle(this,iconBackground);
        this.changeColour();
    }

    changeColour(){
        this.template.host.style.setProperty('--mapColour', this.iconColour);
    }
}