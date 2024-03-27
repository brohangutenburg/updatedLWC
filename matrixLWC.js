// reportResource.js
import { LightningElement, wire, track } from 'lwc';
import createCrossTabData from '@salesforce/apex/reportResource.createCrossTabData';

export default class ReportResource extends LightningElement {
    @track runListW;
    @track runListS;
    @track counts;
    @track workgroupTotals;
    @track stageTotals;
    @track total;
    @track error;

    // Variables for each combination of work group and stage
    @track medXqual = 0;
    @track medXprop = 0;
    @track medXcw = 0;
    @track medXcl = 0;
    // ... repeat for all combinations ...

    @wire(createCrossTabData)
    wiredData({ error, data }) {
        if (data) {
            this.runListW = data.runListW;
            this.runListS = data.runListS;
            this.counts = data.counts;
            this.workgroupTotals = data.workgroupTotals;
            this.stageTotals = data.stageTotals;
            this.total = data.total;
            this.error = undefined;

            // Calculate totals for each combination of work group and stage
            this.calculateTotals();
        } else if (error) {
            this.error = error;
            this.runListW = undefined;
            this.runListS = undefined;
            this.counts = undefined;
            this.workgroupTotals = undefined;
            this.stageTotals = undefined;
            this.total = undefined;
        }
    }

    calculateTotals() {
        // Iterate over runListW and runListS
        for (let run of [...this.runListW, ...this.runListS]) {
            // Calculate totals based on work group and stage
            switch (run.workgroup) {
                case 'medical':
                    switch (run.stage) {
                        case 'qualification':
                            this.medXqual += run.amount;
                            break;
                        case 'proposal':
                            this.medXprop += run.amount;
                            break;
                        case 'closed won':
                            this.medXcw += run.amount;
                            break;
                        case 'closed lost':
                            this.medXcl += run.amount;
                            break;
                    }
                    break;
                // ... repeat for all work groups ...
            }
        }
    }
}